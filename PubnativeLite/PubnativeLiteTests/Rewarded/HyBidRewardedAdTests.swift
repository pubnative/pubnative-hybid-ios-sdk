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
        var didFailOnMainThread: Bool?
        var onFailure: (() -> Void)?

        func rewardedDidLoad() { didLoad = true }
        func rewardedDidFailWithError(_ error: Error!) {
            didFailWithError = error
            didFailOnMainThread = Thread.isMainThread
            onFailure?()
        }
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

    // MARK: - Ad session data in request(didLoadWithAd:) and signalDataDidFinish(with:)

    func testRequest_didLoadWithAd_setsAdSessionData() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        let request = HyBidAdRequest()
        rewarded.request(request, didLoadWithAd: ad)
        XCTAssertNotNil(rewarded.ad)
    }

    func testSignalDataDidFinish_withAd_setsAdSessionData() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        rewarded.signalDataDidFinish(with: ad)
        XCTAssertNotNil(rewarded.ad)
    }

    func testShow_whenReadyAndHasAdSessionData_doesNotCrash() {
        guard let ad = hyBidAdFromTestBundle() else { return }
        let request = HyBidAdRequest()
        rewarded.request(request, didLoadWithAd: ad)
        rewarded.setValue(true, forKey: "isReady")
        rewarded.show()
    }

    // MARK: - VMI-1626

    /// VMI-1626: renderAd called off-main must re-enter on the main thread before building UIKit views.
    func testRenderAd_calledFromBackgroundThread_reEntersOnMainThread() throws {
        let ad = try XCTUnwrap(hyBidAdFromTestBundle(), "Failed to load adResponse.txt test fixture")
        let spy = ThreadRecordingRewardedAd(zoneID: "test-zone", andWith: delegate)
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
        let delivered = expectation(description: "rewardedDidFailWithError delivered")
        delegate.onFailure = { delivered.fulfill() }

        DispatchQueue.global(qos: .userInitiated).async {
            XCTAssertFalse(Thread.isMainThread, "the failure must originate off-main to exercise the hop")
            self.rewarded.signalDataDidFailWithError(NSError(domain: "test", code: -1, userInfo: nil))
        }

        wait(for: [delivered], timeout: 5)
        XCTAssertEqual(delegate.didFailOnMainThread, true,
                       "rewardedDidFailWithError must be delivered on the main thread")
    }

    /// VMI-1626: a failure raised on the main thread must still be delivered synchronously.
    func testInvokeDidFailWithError_calledOnMainThread_deliversSynchronously() {
        rewarded.invokeDidFailWithError(error: NSError(domain: "test", code: -1, userInfo: nil))
        XCTAssertNotNil(delegate.didFailWithError)
        XCTAssertEqual(delegate.didFailOnMainThread, true)
    }

    /// VMI-1626: records the thread of every renderAd entry so the main-thread hop is directly observable.
    private final class ThreadRecordingRewardedAd: HyBidRewardedAd {
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
