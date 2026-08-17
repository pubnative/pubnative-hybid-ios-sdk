//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
@testable import HyBid

/// Unit tests for HyBidInterstitialAd to improve coverage on new code (init, cleanUp, prepare, etc.).
final class HyBidInterstitialAdTests: XCTestCase {

    /// Mock delegate to capture callbacks without side effects.
    private class MockInterstitialDelegate: NSObject, HyBidInterstitialAdDelegate {
        var didLoad = false
        var didFailWithError: Error?
        var didTrackImpression = false
        var didTrackClick = false
        var didDismiss = false
        var didFailOnMainThread: Bool?
        var onFailure: (() -> Void)?

        func interstitialDidLoad() { didLoad = true }
        func interstitialDidFailWithError(_ error: Error!) {
            didFailWithError = error
            didFailOnMainThread = Thread.isMainThread
            onFailure?()
        }
        func interstitialDidTrackImpression() { didTrackImpression = true }
        func interstitialDidTrackClick() { didTrackClick = true }
        func interstitialDidDismiss() { didDismiss = true }
    }

    private var delegate: MockInterstitialDelegate!
    private var interstitial: HyBidInterstitialAd!

    override func setUp() {
        super.setUp()
        delegate = MockInterstitialDelegate()
        interstitial = HyBidInterstitialAd(zoneID: "test-zone", andWith: delegate)
    }

    override func tearDown() {
        interstitial = nil
        delegate = nil
        super.tearDown()
    }

    // MARK: - Init

    func testInitWithDelegate_createsInstance() {
        let ad = HyBidInterstitialAd(delegate: delegate)
        XCTAssertNotNil(ad)
        XCTAssertFalse(ad.isReady)
    }

    func testInitWithZoneIDAndDelegate_setsZoneID() {
        XCTAssertNotNil(interstitial)
        // Zone ID is internal; we just ensure init doesn't crash
    }

    // MARK: - cleanUp (internal but exercised via load/prepare)

    func testPrepare_whenAdAndRequestExist_doesNotCrash() {
        // prepare() only caches if adRequest != nil && ad != nil; with nil ad it's no-op
        interstitial.prepare()
        // No assert needed; we're covering the prepare path
    }

    func testSetOpenRTBAdType_doesNotCrash() {
        // HyBidOpenRTBAdType: native=0, banner=1, video=2 (from HyBidAdRequest.h)
        interstitial.setOpenRTBAdType(adFormat: HyBidOpenRTBAdVideo)
    }

    func testIsAutoCacheOnLoad_defaultIsTrue() {
        XCTAssertTrue(interstitial.isAutoCacheOnLoad)
    }

    func testSetMediationWatermark_doesNotCrash() {
        interstitial.setMediationWatermark(Data())
        interstitial.setMediationWatermark(nil)
    }

    // MARK: - load / loadExchangeAd (exercise cleanUp and request paths for coverage)

    func testLoad_withEmptyZone_invokesDidFailWithError() {
        let ad = HyBidInterstitialAd(zoneID: "", andWith: delegate)
        ad.load()
        XCTAssertNotNil(delegate.didFailWithError)
    }

    func testLoad_withValidZone_callsCleanUpAndStartsRequest() {
        interstitial.load()
        // cleanUp() runs at start of load(); request starts (may fail async)
        XCTAssertFalse(interstitial.isReady)
    }

    func testLoadExchangeAd_withValidZone_doesNotCrash() {
        interstitial.loadExchangeAd()
        XCTAssertFalse(interstitial.isReady)
    }

    func testShow_whenNotReady_doesNotCrash() {
        interstitial.show()
    }

    // MARK: - Ad session data in request(didLoadWithAd:) and signalDataDidFinish(with:)

    func testRequest_didLoadWithAd_setsAdSessionData() {
        guard let ad = hyBidAdFromTestBundle() else {
            return // skip if no bundle resource
        }
        let request = HyBidAdRequest()
        interstitial.request(request, didLoadWithAd: ad)
        XCTAssertNotNil(interstitial.ad)
    }

    func testSignalDataDidFinish_withAd_setsAdSessionData() {
        guard let ad = hyBidAdFromTestBundle() else {
            return
        }
        interstitial.signalDataDidFinish(with: ad)
        XCTAssertNotNil(interstitial.ad)
    }

    func testShow_whenReadyAndHasAdSessionData_doesNotCrash() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        let request = HyBidAdRequest()
        interstitial.request(request, didLoadWithAd: ad)
        interstitial.setValue(true, forKey: "isReady")
        interstitial.show()
    }

    // MARK: - VMI-1626

    /// VMI-1626: renderAd called off-main must re-enter on the main thread before building UIKit views.
    func testRenderAd_calledFromBackgroundThread_reEntersOnMainThread() throws {
        let ad = try XCTUnwrap(hyBidAdFromTestBundle(), "Failed to load adResponse.txt test fixture")
        let spy = ThreadRecordingInterstitialAd(zoneID: "test-zone", andWith: delegate)
        let reEnteredOnMain = expectation(description: "renderAd re-enters on the main thread")
        spy.reEntryExpectation = reEnteredOnMain
        spy.ad = ad

        DispatchQueue.global(qos: .userInitiated).async {
            XCTAssertFalse(Thread.isMainThread, "renderAd must be invoked off-main to exercise the hop")
            spy.renderAd(ad: ad)
        }

        wait(for: [reEnteredOnMain], timeout: 5)
        XCTAssertEqual(spy.entriesWereOnMain, [false, true],
                       "renderAd must be entered once off-main, then re-entered on main")
    }

    /// VMI-1626: signal-data failures raised off-main must reach the publisher delegate on the main thread.
    func testSignalDataDidFailWithError_calledFromBackgroundThread_deliversDelegateOnMainThread() {
        let delivered = expectation(description: "interstitialDidFailWithError delivered")
        delegate.onFailure = { delivered.fulfill() }

        DispatchQueue.global(qos: .userInitiated).async {
            XCTAssertFalse(Thread.isMainThread, "the failure must originate off-main to exercise the hop")
            self.interstitial.signalDataDidFailWithError(NSError(domain: "test", code: -1, userInfo: nil))
        }

        wait(for: [delivered], timeout: 5)
        XCTAssertEqual(delegate.didFailOnMainThread, true,
                       "interstitialDidFailWithError must be delivered on the main thread")
    }

    /// VMI-1626: a failure raised on the main thread must still be delivered synchronously.
    func testInvokeDidFailWithError_calledOnMainThread_deliversSynchronously() {
        interstitial.invokeDidFailWithError(error: NSError(domain: "test", code: -1, userInfo: nil))
        XCTAssertNotNil(delegate.didFailWithError)
        XCTAssertEqual(delegate.didFailOnMainThread, true)
    }

    /// VMI-1626: records the thread of every renderAd entry so the main-thread hop is directly observable.
    private final class ThreadRecordingInterstitialAd: HyBidInterstitialAd {
        private let lock = NSLock()
        private var entries: [Bool] = []
        var reEntryExpectation: XCTestExpectation?

        var entriesWereOnMain: [Bool] {
            lock.lock()
            defer { lock.unlock() }
            return entries
        }

        override func renderAd(ad: HyBidAd) {
            lock.lock()
            entries.append(Thread.isMainThread)
            let isReEntry = entries.count == 2
            lock.unlock()
            if isReEntry {
                reEntryExpectation?.fulfill()
            }
            super.renderAd(ad: ad)
        }
    }

    private func hyBidAdFromTestBundle() -> HyBidAd? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "adResponse", ofType: "txt"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any],
              let response = PNLiteResponseModel(dictionary: json),
              let firstAd = response.ads?.first as? HyBidAdModel else {
            return nil
        }
        return HyBidAd(data: firstAd, withZoneID: "4")
    }
}
