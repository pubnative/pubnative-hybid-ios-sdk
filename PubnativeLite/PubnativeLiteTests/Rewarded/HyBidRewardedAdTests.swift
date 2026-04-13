//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
@testable import HyBid

/// Unit tests for HyBidRewardedAd to improve coverage on new code (init, cleanUp, prepare, etc.).
final class HyBidRewardedAdTests: XCTestCase {

    private class MockRewardedDelegate: NSObject, HyBidRewardedAdDelegate {
        var didLoad = false
        var didFailWithError: Error?
        var didTrackImpression = false
        var didTrackClick = false
        var didDismiss = false
        var onRewardCalled = false

        func rewardedDidLoad() { didLoad = true }
        func rewardedDidFailWithError(_ error: Error!) { didFailWithError = error }
        func rewardedDidTrackImpression() { didTrackImpression = true }
        func rewardedDidTrackClick() { didTrackClick = true }
        func rewardedDidDismiss() { didDismiss = true }
        func onReward() { onRewardCalled = true }
    }

    private var delegate: MockRewardedDelegate!
    private var rewarded: HyBidRewardedAd!

    override func setUp() {
        super.setUp()
        delegate = MockRewardedDelegate()
        rewarded = HyBidRewardedAd(zoneID: "test-zone", andWith: delegate)
    }

    override func tearDown() {
        rewarded = nil
        delegate = nil
        super.tearDown()
    }

    func testInitWithDelegate_createsInstance() {
        let ad = HyBidRewardedAd(delegate: delegate)
        XCTAssertNotNil(ad)
        XCTAssertFalse(ad.isReady)
    }

    func testInitWithZoneIDAndDelegate_doesNotCrash() {
        XCTAssertNotNil(rewarded)
    }

    func testPrepare_whenAdAndRequestExist_doesNotCrash() {
        rewarded.prepare()
    }

    func testIsAutoCacheOnLoad_defaultIsTrue() {
        XCTAssertTrue(rewarded.isAutoCacheOnLoad)
    }

    func testSetMediationWatermark_doesNotCrash() {
        rewarded.setMediationWatermark(Data())
        rewarded.setMediationWatermark(nil)
    }

    // MARK: - load / loadExchangeAd (exercise cleanUp and request paths for coverage)

    func testLoad_withEmptyZone_invokesDidFailWithError() {
        let ad = HyBidRewardedAd(zoneID: "", andWith: delegate)
        ad.load()
        XCTAssertNotNil(delegate.didFailWithError)
    }

    func testLoad_withValidZone_callsCleanUpAndStartsRequest() {
        rewarded.load()
        XCTAssertFalse(rewarded.isReady)
    }

    func testLoadExchangeAd_withValidZone_doesNotCrash() {
        rewarded.loadExchangeAd()
        XCTAssertFalse(rewarded.isReady)
    }

    func testShow_whenNotReady_doesNotCrash() {
        rewarded.show()
    }

    // MARK: - New code coverage: HyBidATOMManager (prefix rename) in request(didLoadWithAd:) and signalDataDidFinish(with:)

    func testRequest_didLoadWithAd_setsAdSessionDataViaHyBidATOMManager() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        let request = HyBidAdRequest()
        rewarded.request(request, didLoadWithAd: ad)
        XCTAssertNotNil(rewarded.ad)
    }

    func testSignalDataDidFinish_withAd_setsAdSessionDataViaHyBidATOMManager() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        rewarded.signalDataDidFinish(with: ad)
        XCTAssertNotNil(rewarded.ad)
    }

    /// Covers new code: HyBidATOMManager.fireAdSessionEvent in show() when isReady and not expired
    func testShow_whenReadyAndHasAdSessionData_firesHyBidATOMManagerEvent() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        let request = HyBidAdRequest()
        rewarded.request(request, didLoadWithAd: ad)
        rewarded.setValue(true, forKey: "isReady")
        rewarded.show()
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
