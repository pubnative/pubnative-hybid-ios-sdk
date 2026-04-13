//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation
import XCTest
import WebKit

#if canImport(OMSDK_Pubnativenet)
import OMSDK_Pubnativenet

typealias OMIDSDKType = OMIDPubnativenetSDK
typealias OMIDPartnerType = OMIDPubnativenetPartner
typealias OMIDAdSessionType = OMIDPubnativenetAdSession
typealias OMIDAdSessionContextType = OMIDPubnativenetAdSessionContext
typealias OMIDAdSessionConfigurationType = OMIDPubnativenetAdSessionConfiguration

#elseif canImport(OMSDK_Smaato)
import OMSDK_Smaato

typealias OMIDSDKType = OMIDSmaatoSDK
typealias OMIDPartnerType = OMIDSmaatoPartner
typealias OMIDAdSessionType = OMIDSmaatoAdSession
typealias OMIDAdSessionContextType = OMIDSmaatoAdSessionContext
typealias OMIDAdSessionConfigurationType = OMIDSmaatoAdSessionConfiguration

#else
// OMSDK is not available in this build/test target.
// Tests that require a real OMID ad session will be skipped.
#endif

@preconcurrency @testable import HyBid

// Helper wrapper to satisfy Swift 6 concurrency checks in GCD closures.
final class UncheckedSendableBox<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) { self.value = value }
}

final class HyBidOMSDKTest: XCTestCase {

    // Keeps UIWindows alive for the duration of each test so WKWebView navigation
    // callbacks fire reliably in headless CI simulators (no rendering context otherwise).
    private var windows: [UIWindow] = []

    // MARK: - XCTest lifecycle

    override func setUp() {
        super.setUp()

        // Reset cached singleton state before each test to avoid leakage.
        guard let viewabilityManager = HyBidViewabilityManager.sharedInstance() else {
            preconditionFailure("HyBidViewabilityManager.sharedInstance() returned nil")
        }
        viewabilityManager.adEvents = nil
        viewabilityManager.omidAdSession = nil
    }

    override func tearDown() {
        windows.removeAll()
        super.tearDown()
    }

    // MARK: - Helpers
    
    private final class WebViewWaiter: NSObject, WKNavigationDelegate {
        let onFinish: () -> Void
        init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onFinish()
        }
    }

    private func makeViewabilityManager() -> HyBidViewabilityManager {
        // `sharedInstance()` is imported as optional in Swift interface
        guard let viewabilityManager = HyBidViewabilityManager.sharedInstance() else {
            preconditionFailure("HyBidViewabilityManager.sharedInstance() returned nil")
        }
        return viewabilityManager
    }

    private func makeAdSessionWrapper(with session: AnyObject?) -> HyBidOMIDAdSessionWrapper {
        let wrapper = HyBidOMIDAdSessionWrapper()
        wrapper.adSession = session
        return wrapper
    }
    
    private func makePreseededViewabilityManager(cachedAdEvents: AnyObject, sessionObject: AnyObject) -> (HyBidViewabilityManager, HyBidOMIDAdSessionWrapper) {
        let viewabilityManager = makeViewabilityManager()
        let wrapper = makeAdSessionWrapper(with: sessionObject)

        // Pre-seed the cache so `getAdEvents` returns without constructing OMSDK AdEvents.
        viewabilityManager.adEvents = cachedAdEvents
        viewabilityManager.omidAdSession = wrapper

        return (viewabilityManager, wrapper)
    }

    private func currentIntegrationType() -> SDKIntegrationType {
        HyBid.getIntegrationType()
    }

    private func isHyBidIntegration() -> Bool {
        currentIntegrationType() == .hyBid
    }

    private func isSmaatoIntegration() -> Bool {
        currentIntegrationType() == .smaato
    }

    private func skipIfUnknownIntegrationType() throws {
        switch currentIntegrationType() {
        case .hyBid, .smaato: return
        @unknown default:
            throw XCTSkip(
                "Unknown integration type: \(currentIntegrationType()). " +
                "Update test handling if new enum cases are added."
            )
        }
    }
    
    // MARK: - OMID session helpers

    /**
     Real OMSDK session bootstrap used by integration tests.

     The flow implemented here follows the official IAB OMSDK iOS integration steps:

     1. Activate OMID SDK before creating any session objects.
     2. Create OMIDPartner.
     3. Load a WKWebView.
     4. Inject OMID JS service into the webView BEFORE creating the ad session.
     5. Create OMIDAdSessionContext.
     6. Create OMIDAdSessionConfiguration.
     7. Create OMIDAdSession.

     References:
     - OMIDSDK.activate():
       https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDSDK.html
     - OMIDPartner:
       https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDPartner.html
     - OMIDAdSessionContext:
       https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDAdSessionContext.html
     - OMIDAdSessionConfiguration:
       https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDAdSessionConfiguration.html
     - OMIDAdSession:
       https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDAdSession.html
     */

    @MainActor
    private func prepareWebViewAndPartner() throws -> (partner: OMIDPartnerType, webView: WKWebView) {
        // OM SDK must be used on the main thread.
        #if !(canImport(OMSDK_Pubnativenet) || canImport(OMSDK_Smaato))
        throw XCTSkip("OMSDK is not linked into this test target.")
        #endif

        // 1) Activate OMID SDK (must be done before creating contexts/sessions).
        // Per IAB OMSDK docs: OMIDSDK.activate() must be called before creating
        // OMIDAdSessionContext or OMIDAdSession objects.
        // https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDSDK.html
        let sdk = OMIDSDKType.shared
        if !sdk.isActive {
            XCTAssertTrue(sdk.activate(), "OMIDSDK.activate() returned false")
        }

        // 2) Partner (name/version mandatory).
        guard let partner = OMIDPartnerType(name: "HyBid", versionString: "Tests") else {
            throw XCTSkip("OMSDK returned nil partner instance; cannot create OMID ad session.")
        }

        // 3) WebView load — create a UIWindow per call and keep it alive via
        // the windows array so WKWebView navigation callbacks fire in headless
        // CI simulators (no rendering context without an attached window).
        let window = UIWindow(frame: UIScreen.main.bounds)
        let webView = WKWebView(frame: window.bounds)
        window.addSubview(webView)
        window.makeKeyAndVisible()
        windows.append(window)

        let didFinish = expectation(description: "WKWebView didFinish")
        var waiter: WebViewWaiter?
        waiter = WebViewWaiter(onFinish: { didFinish.fulfill() })
        webView.navigationDelegate = waiter

        webView.loadHTMLString("<html><body>OMID Test</body></html>", baseURL: nil)
        wait(for: [didFinish], timeout: 5.0)

        // 4) Inject OMID JS service into the webView BEFORE creating OMIDAdSession.
        // The OMID JS service must be present in the web environment prior to
        // session creation for proper measurement.
        // https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDAdSession.html
        let viewabilityManager = makeViewabilityManager()
        let omidJS = viewabilityManager.getOMIDJS() ?? ""
        if omidJS.isEmpty {
            throw XCTSkip("OMID JS service is empty/unavailable from HyBidViewabilityManager.getOMIDJS().")
        }

        let injected = expectation(description: "OMID JS injected")
        var jsError: Error?
        webView.evaluateJavaScript(omidJS) { _, error in
            jsError = error
            injected.fulfill()
        }
        wait(for: [injected], timeout: 5.0)
        if let jsError {
            XCTFail("Failed injecting OMID JS: \(jsError)")
        }

        return (partner: partner, webView: webView)
    }

    @MainActor
    private func makeRealOMIDAdSession(configurationBuilder: (OMIDAdSessionContextType) throws -> OMIDAdSessionConfigurationType) throws -> (adSession: OMIDAdSessionType, webView: WKWebView) {
        let prepared = try prepareWebViewAndPartner()

        // 5) Context (HTML webView context).
        // OMIDAdSessionContext binds the partner + webView to the measurement session.
        // https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDAdSessionContext.html
        let context = try OMIDAdSessionContextType(
            partner: prepared.partner,
            webView: prepared.webView,
            contentUrl: nil,
            customReferenceIdentifier: "HyBidOMSDKTest"
        )

        // 6) Configuration (caller-defined).
        let configuration = try configurationBuilder(context)

        // 7) Session.
        // OMIDAdSession is created with configuration + context and represents
        // the measurable ad lifecycle.
        // https://docs.iabtechlab.com/omsdk-1.5/ios/Classes/OMIDAdSession.html
        let adSession = try OMIDAdSessionType(configuration: configuration, adSessionContext: context)

        // Provide a main view (helpful for OMID expectations).
        // OMID keeps a weak reference to mainAdView, so we must strongly own it.
        // Attach it to the webView (which we return) to keep it alive.
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        prepared.webView.addSubview(mainView)
        adSession.mainAdView = mainView

        return (adSession: adSession, webView: prepared.webView)
    }

    /// Creates a REAL OMIDAdSession + keeps the WKWebView alive by returning it too.
    /// Uses `mediaEventsOwner: .noneOwner`, which makes `getMediaEvents(...)` legitimately return nil.
    @MainActor
    private func makeRealOMIDAdSession() throws -> (adSession: OMIDAdSessionType, webView: WKWebView) {
        try makeRealOMIDAdSession { _ in
            try OMIDAdSessionConfigurationType(
                creativeType: .htmlDisplay,
                impressionType: .beginToRender,
                impressionOwner: .nativeOwner,
                mediaEventsOwner: .noneOwner,
                isolateVerificationScripts: false
            )
        }
    }

    /// Creates a REAL OMIDAdSession configured to allow MediaEvents (video-style events).
    @MainActor
    private func makeRealOMIDAdSessionAllowingMediaEvents() throws -> (adSession: OMIDAdSessionType, webView: WKWebView) {
        try makeRealOMIDAdSession { _ in
            try OMIDAdSessionConfigurationType(
                creativeType: .video,
                impressionType: .beginToRender,
                impressionOwner: .nativeOwner,
                mediaEventsOwner: .nativeOwner,
                isolateVerificationScripts: false
            )
        }
    }

    @MainActor
    private func createAdEventsAndReturnTypeName(using viewabilityManager: HyBidViewabilityManager) throws -> String {
        let session = try makeRealOMIDAdSession()
        defer { session.adSession.finish() }

        // Keep WKWebView alive for the duration of AdEvents initialization.
        _ = session.webView

        let wrapper = makeAdSessionWrapper(with: session.adSession as AnyObject)
        let adEvents = viewabilityManager.getAdEvents(wrapper)

        XCTAssertNotNil(adEvents)
        let adEventsObject = try XCTUnwrap(adEvents as AnyObject?)
        return String(describing: type(of: adEventsObject))
    }

    // MARK: - Core behavior tests

    func test_getAdEvents_returnsNil_whenAdSessionIsNil() {
        let viewabilityManager = makeViewabilityManager()
        let wrapper = makeAdSessionWrapper(with: nil)

        let adEvents = viewabilityManager.getAdEvents(wrapper)

        XCTAssertNil(adEvents, "Expected nil AdEvents when OMIDAdSessionWrapper.adSession is nil.")
    }

    func test_getAdEvents_returnsCachedInstance_whenCalledWithSameSession() {
        // Arrange
        let cachedAdEvents = NSObject()
        let sessionObject = NSObject()
        let (viewabilityManager, wrapper) = makePreseededViewabilityManager(cachedAdEvents: cachedAdEvents, sessionObject: sessionObject)

        // Act
        let first = viewabilityManager.getAdEvents(wrapper) as AnyObject?
        let second = viewabilityManager.getAdEvents(wrapper) as AnyObject?

        // Assert
        XCTAssertNotNil(first)
        XCTAssertTrue(first === cachedAdEvents)
        XCTAssertTrue(first === second)
    }

    func test_getAdEvents_returnsCachedInstance_whenWrapperChangesButSessionIsSame() {
        // Arrange
        let cachedAdEvents = NSObject()
        let sharedSessionObject = NSObject()
        let (viewabilityManager, firstWrapper) = makePreseededViewabilityManager(cachedAdEvents: cachedAdEvents, sessionObject: sharedSessionObject)

        // A different wrapper instance, but pointing to the same underlying session object.
        let secondWrapper = makeAdSessionWrapper(with: sharedSessionObject)

        // Act
        let first = viewabilityManager.getAdEvents(firstWrapper) as AnyObject?
        let second = viewabilityManager.getAdEvents(secondWrapper) as AnyObject?

        // Assert
        XCTAssertNotNil(first)
        XCTAssertTrue(first === cachedAdEvents)
        XCTAssertTrue(first === second)
    }

    @MainActor
    func test_getAdEvents_recreates_whenSessionChanges_requiresRealOMIDAdSession() throws {
        // Arrange
        let viewabilityManager = makeViewabilityManager()

        let firstSession = try makeRealOMIDAdSession()
        defer { firstSession.adSession.finish() }
        let secondSession = try makeRealOMIDAdSession()
        defer { secondSession.adSession.finish() }

        // Keep WKWebViews alive for the duration of this test.
        _ = firstSession.webView
        _ = secondSession.webView

        let firstWrapper = makeAdSessionWrapper(with: firstSession.adSession as AnyObject)
        let secondWrapper = makeAdSessionWrapper(with: secondSession.adSession as AnyObject)

        // Act
        let firstEvents = viewabilityManager.getAdEvents(firstWrapper) as AnyObject?
        let secondEvents = viewabilityManager.getAdEvents(secondWrapper) as AnyObject?

        // Assert
        XCTAssertNotNil(firstEvents)
        XCTAssertNotNil(secondEvents)
        XCTAssertFalse(firstEvents === secondEvents)
    }

    func test_getAdEvents_returnsSameCachedInstance_underConcurrentAccess() {
        let cachedAdEvents = NSObject()
        let sessionObject = NSObject()
        let (viewabilityManager, wrapper) = makePreseededViewabilityManager(cachedAdEvents: cachedAdEvents, sessionObject: sessionObject)

        let viewabilityManagerBox = UncheckedSendableBox(viewabilityManager)
        let wrapperBox = UncheckedSendableBox(wrapper)

        let lock = NSLock()
        let resultsBox = UncheckedSendableBox(NSMutableArray())

        DispatchQueue.concurrentPerform(iterations: 50) { _ in
            if let result = viewabilityManagerBox.value.getAdEvents(wrapperBox.value) as AnyObject? {
                lock.lock()
                resultsBox.value.add(result)
                lock.unlock()
            }
        }

        let results = resultsBox.value.compactMap { $0 as AnyObject }
        XCTAssertFalse(results.isEmpty)
        let first = results[0]
        for item in results {
            XCTAssertTrue(item === first)
        }
    }

    // MARK: - Integration type tests (iOS 12+)

    @MainActor
    func test_getAdEvents_createsPubnativenetAdEvents_whenIntegrationTypeIsHyBid() throws {
        try skipIfUnknownIntegrationType()
        try XCTSkipIf(!isHyBidIntegration(), "This test only applies when integration type is HyBid.")
        try XCTSkipIf(NSClassFromString("OMIDPubnativenetAdEvents") == nil, "OMIDPubnativenetAdEvents is not linked in this build.")

        let viewabilityManager = makeViewabilityManager()
        let typeName = try createAdEventsAndReturnTypeName(using: viewabilityManager)
        XCTAssertEqual(typeName, "OMIDPubnativenetAdEvents")
    }

    @MainActor
    func test_getAdEvents_createsSmaatoAdEvents_whenIntegrationTypeIsSmaato() throws {
        try skipIfUnknownIntegrationType()
        try XCTSkipIf(!isSmaatoIntegration(), "This test only applies when integration type is Smaato.")
        try XCTSkipIf(NSClassFromString("OMIDSmaatoAdEvents") == nil, "OMIDSmaatoAdEvents is not linked in this build.")

        let viewabilityManager = makeViewabilityManager()
        let typeName = try createAdEventsAndReturnTypeName(using: viewabilityManager)
        XCTAssertEqual(typeName, "OMIDSmaatoAdEvents")
    }

    func test_sharedInstance_returnsSameInstance() {
        let first = HyBidViewabilityManager.sharedInstance()
        let second = HyBidViewabilityManager.sharedInstance()
        XCTAssertTrue(first === second)
    }

    func test_init_setsViewabilityMeasurementEnabled_trueByDefault() {
        let manager = HyBidViewabilityManager()
        XCTAssertTrue(manager.viewabilityMeasurementEnabled)
    }


    func test_getOMIDJS_returnsStringOrNil_withoutCrashing() {
        let manager = makeViewabilityManager()
        _ = manager.getOMIDJS()
        XCTAssertTrue(true)
    }

    func test_isViewabilityMeasurementActivated_returnsFalse_whenDisabled() {
        let manager = makeViewabilityManager()
        manager.viewabilityMeasurementEnabled = false
        XCTAssertFalse(manager.isViewabilityMeasurementActivated)
    }

    func test_reportEvent_doesNotCrash() {
        let manager = makeViewabilityManager()
        manager.reportEvent("unit_test_event")
        XCTAssertTrue(true)
    }

    func test_getMediaEvents_returnsNil_whenWrapperSessionIsNil() {
        let manager = makeViewabilityManager()
        let wrapper = makeAdSessionWrapper(with: nil)

        let mediaEvents = manager.getMediaEvents(wrapper)
        XCTAssertNil(mediaEvents, "Expected nil MediaEvents when OMIDAdSessionWrapper.adSession is nil.")
    }

    @MainActor
    func test_getMediaEvents_returnsNonNil_withRealAdSession_whenOMSDKAvailable() throws {
        try skipIfUnknownIntegrationType()

        let manager = makeViewabilityManager()
        let session = try makeRealOMIDAdSessionAllowingMediaEvents()
        defer { session.adSession.finish() }

        _ = session.webView // keep alive

        let wrapper = makeAdSessionWrapper(with: session.adSession as AnyObject)
        let mediaEvents = manager.getMediaEvents(wrapper)

        XCTAssertNotNil(mediaEvents)
    }

    @MainActor
    func test_isViewabilityMeasurementActivated_returnsTrue_whenSDKActiveAndEnabled() throws {
        try skipIfUnknownIntegrationType()

        let viewabilityManager = makeViewabilityManager()
        viewabilityManager.viewabilityMeasurementEnabled = true

        // Ensure OMSDK becomes active by creating a real session (helper activates SDK).
        let session = try makeRealOMIDAdSession()
        defer { session.adSession.finish() }
        _ = session.webView

        XCTAssertTrue(viewabilityManager.isViewabilityMeasurementActivated)
    }

    @MainActor
    func test_partner_isNonNil_whenOMSDKIsActive() throws {
        try skipIfUnknownIntegrationType()

        let viewabilityManager = makeViewabilityManager()

        // Ensure OMID SDK is active (and partner gets initialized in activateOMSDK).
        let session = try makeRealOMIDAdSession()
        defer { session.adSession.finish() }
        _ = session.webView

        XCTAssertNotNil(viewabilityManager.partner)
    }

    @MainActor
    func test_getOMIDJS_isNonEmpty_whenRealSessionCanBeCreated() throws {
        try skipIfUnknownIntegrationType()

        let viewabilityManager = makeViewabilityManager()

        // makeRealOMIDAdSession() already SKIPs if getOMIDJS is empty/unavailable,
        // so if we reach here we can assert it’s non-empty (covers fetchOMIDJS success path).
        let session = try makeRealOMIDAdSession()
        defer { session.adSession.finish() }
        _ = session.webView

        let omidJS = viewabilityManager.getOMIDJS() ?? ""
        XCTAssertFalse(omidJS.isEmpty)
    }

    @MainActor
    func test_getMediaEvents_returnsNil_whenSessionConfigurationDisablesMediaEvents() throws {
        try skipIfUnknownIntegrationType()

        let viewabilityManager = makeViewabilityManager()

        // This helper uses `mediaEventsOwner: .noneOwner` by design.
        // getMediaEvents(...) should legitimately return nil in this scenario.
        let session = try makeRealOMIDAdSession()
        defer { session.adSession.finish() }
        _ = session.webView

        let wrapper = makeAdSessionWrapper(with: session.adSession as AnyObject)
        let mediaEvents = viewabilityManager.getMediaEvents(wrapper)

        XCTAssertNil(mediaEvents, "Expected nil MediaEvents when OMIDAdSessionConfiguration.mediaEventsOwner is .noneOwner.")
    }

    func test_reportEvent_exercisesReportingEnabledCodePath_whenEnabled() throws {
        try skipIfUnknownIntegrationType()
        try XCTSkipIf(!isHyBidIntegration(), "This test only applies when integration type is HyBid.")

        let config = HyBidSDKConfig.sharedConfig
        let originalReporting = config.reporting
        config.reporting = true
        defer { config.reporting = originalReporting }

        let viewabilityManager = makeViewabilityManager()
        viewabilityManager.reportEvent("unit_test_event_reporting_enabled_swift")

        XCTAssertTrue(true) // coverage: exercises the reporting-enabled code path
    }
}
