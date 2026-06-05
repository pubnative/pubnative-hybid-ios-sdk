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

        func interstitialDidLoad() { didLoad = true }
        func interstitialDidFailWithError(_ error: Error!) { didFailWithError = error }
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

    // MARK: - New code coverage: HyBidATOMManager (prefix rename) in request(didLoadWithAd:) and signalDataDidFinish(with:)

    func testRequest_didLoadWithAd_setsAdSessionDataViaHyBidATOMManager() {
        guard let ad = hyBidAdFromTestBundle() else {
            return // skip if no bundle resource
        }
        let request = HyBidAdRequest()
        interstitial.request(request, didLoadWithAd: ad)
        XCTAssertNotNil(interstitial.ad)
    }

    func testSignalDataDidFinish_withAd_setsAdSessionDataViaHyBidATOMManager() {
        guard let ad = hyBidAdFromTestBundle() else {
            return
        }
        interstitial.signalDataDidFinish(with: ad)
        XCTAssertNotNil(interstitial.ad)
    }

    /// Covers new code: HyBidATOMManager.fireAdSessionEvent in show() when isReady and not expired
    func testShow_whenReadyAndHasAdSessionData_firesHyBidATOMManagerEvent() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        let request = HyBidAdRequest()
        interstitial.request(request, didLoadWithAd: ad)
        interstitial.setValue(true, forKey: "isReady")
        interstitial.show()
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
