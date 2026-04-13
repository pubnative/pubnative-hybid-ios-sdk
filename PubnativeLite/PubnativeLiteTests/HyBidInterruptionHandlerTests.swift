//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
import UIKit
@testable import HyBid

// MARK: - Mock delegate to assert ad can resume (adHasFocus) and was paused (adHasNoFocus)

private final class MockInterruptionDelegate: NSObject, HyBidInterruptionDelegate {
    var adHasFocusCallCount = 0
    var adHasNoFocusCallCount = 0

    func adHasFocus() {
        adHasFocusCallCount += 1
    }

    func adHasNoFocus() {
        adHasNoFocusCallCount += 1
    }

    func reset() {
        adHasFocusCallCount = 0
        adHasNoFocusCallCount = 0
    }
}

// MARK: - Tests: ad must not stay paused; user must be able to close (adHasFocus delivered)

final class HyBidInterruptionHandlerTests: XCTestCase {

    private let handler = HyBidInterruptionHandler.shared
    private let mockVAST = MockInterruptionDelegate()
    private let mockMRAID = MockInterruptionDelegate()

    override func setUp() {
        super.setUp()
        mockVAST.reset()
        mockMRAID.reset()
    }

    override func tearDown() {
        handler.deactivateContext(.vastPlayer)
        handler.deactivateContext(.mraidView)
        handler.deactivateContext(.endcard)
        handler.overlappingElementDelegate = nil
        super.tearDown()
    }

    // MARK: - Original issue: app background → one didBecomeActive must clear all appLifeCycle → adHasFocus so countdown resumes

    func test_appBackgroundThenForeground_deliversAdHasFocusSoUserCanClose() {
        handler.activateContext(.vastPlayer, with: mockVAST)
        postWillResignActive()
        XCTAssertEqual(mockVAST.adHasNoFocusCallCount, 1, "Ad should pause when app goes to background")
        mockVAST.reset()

        postDidBecomeActive()
        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "Ad must receive adHasFocus so countdown resumes and user can close")
    }

    func test_multipleAppLifeCycleInterruptions_oneDidBecomeActiveClearsAll_deliversAdHasFocus() {
        handler.activateContext(.vastPlayer, with: mockVAST)
        // Simulate e.g. background + overlay: post willResignActive twice so two appLifeCycle entries are added
        postWillResignActive()
        postWillResignActive()
        mockVAST.reset()
        postDidBecomeActive()
        // removeAdInterruption(.appLifeCycle) removes ALL, so one didBecomeActive clears list and delivers adHasFocus
        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "One didBecomeActive must clear all appLifeCycle and deliver adHasFocus")
    }

    // MARK: - Feedback shown as MRAID: when feedback dismisses, MRAID (still on stack) must get adHasFocus

    func test_feedbackViewDismissedWithMRAIDActive_deliversAdHasFocusToMRAID() {
        handler.activateContext(.mraidView, with: mockMRAID)
        handler.adFeedbackViewDidShow()
        mockMRAID.reset()
        handler.adFeedbackViewDidDismiss()
        XCTAssertEqual(mockMRAID.adHasFocusCallCount, 1, "When feedback (shown as MRAID) dismisses, MRAID must get adHasFocus so ad can close")
    }

    // MARK: - Remove-all per type: one dismiss/finish clears all entries of that type → adHasFocus

    func test_multipleInternalBrowsers_oneDismissRemovesAll_deliversAdHasFocus() {
        handler.activateContext(.vastPlayer, with: mockVAST)
        handler.internalWebBrowserDidShow()
        handler.internalWebBrowserDidShow()
        mockVAST.reset()
        handler.internalWebBrowserDidDismiss()
        // removeAdInterruption(.internalBrowser) removes ALL of that type, so list empty and adHasFocus delivered once
        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "One dismiss clears all internalBrowser entries and delivers adHasFocus")
    }

    func test_multipleStoreKitViews_oneProductViewControllerDidFinishRemovesAll_deliversAdHasFocus() {
        handler.activateContext(.vastPlayer, with: mockVAST)
        handler.productViewControllerDidShow(isAutoStoreKitView: false, adFormat: "interstitial")
        handler.productViewControllerDidShow(isAutoStoreKitView: false, adFormat: "interstitial")
        mockVAST.reset()
        handler.productViewControllerDidFinish()
        // Removes all StoreKit-related entries, so list empty and adHasFocus delivered once
        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "One productViewControllerDidFinish clears all StoreKit entries and delivers adHasFocus")
    }

    func test_multipleFeedbackViews_oneDismissRemovesAll_deliversAdHasFocus() {
        handler.activateContext(.mraidView, with: mockMRAID)
        handler.adFeedbackViewDidShow()
        handler.adFeedbackViewDidShow()
        mockMRAID.reset()
        handler.adFeedbackViewDidDismiss()
        // removeAdInterruption(.feedbackView) removes ALL of that type, so list empty and adHasFocus delivered once
        XCTAssertEqual(mockMRAID.adHasFocusCallCount, 1, "One dismiss clears all feedbackView entries and delivers adHasFocus")
    }

    // MARK: - Mixed interruptions: clearing last one must deliver adHasFocus

    func test_appLifeCycleThenInternalBrowser_bothCleared_deliversAdHasFocus() {
        handler.activateContext(.vastPlayer, with: mockVAST)
        postWillResignActive()
        handler.internalWebBrowserDidShow()
        mockVAST.reset()
        postDidBecomeActive()
        XCTAssertEqual(mockVAST.adHasNoFocusCallCount, 0)
        handler.internalWebBrowserDidDismiss()
        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "After app active and browser closed, ad must get adHasFocus")
    }

    func test_internalBrowserThenAppBackground_bothCleared_deliversAdHasFocus() {
        handler.activateContext(.vastPlayer, with: mockVAST)
        handler.internalWebBrowserDidShow()
        postWillResignActive()
        mockVAST.reset()
        handler.internalWebBrowserDidDismiss()
        postDidBecomeActive()
        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "After browser closed and app active, ad must get adHasFocus")
    }

    // MARK: - Active context: only active delegate receives adHasFocus when stack non-empty

    func test_vastPlayerActive_appResume_deliversAdHasFocusToVAST() {
        handler.activateContext(.vastPlayer, with: mockVAST)
        handler.activateContext(.mraidView, with: mockMRAID)
        postWillResignActive()
        mockVAST.reset()
        mockMRAID.reset()
        postDidBecomeActive()
        XCTAssertEqual(mockMRAID.adHasFocusCallCount, 1, "Top of stack is MRAID so MRAID gets adHasFocus")
        XCTAssertEqual(mockVAST.adHasFocusCallCount, 0)
    }

    // MARK: - Replay scenario: endcard deactivates, vast player reactivates

    func test_replayFlow_endcardDeactivated_vastPlayerActivated_appResume_deliversAdHasFocusToVAST() {
        let mockEndcard = MockInterruptionDelegate()

        // Endcard shown: endcard is the active context
        handler.activateContext(.endcard, with: mockEndcard)
        postWillResignActive()
        mockEndcard.reset()
        mockVAST.reset()

        // Replay: endcard removed → deactivateContext called from removingReferences
        handler.deactivateContext(.endcard)

        // Vast player reactivates from setPlayState on replay
        handler.activateContext(.vastPlayer, with: mockVAST)

        // App returns to foreground
        postDidBecomeActive()

        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "VAST player should receive adHasFocus after replay")
        XCTAssertEqual(mockEndcard.adHasFocusCallCount, 0, "Deactivated endcard should not receive adHasFocus")
    }

    func test_endcardActive_appBackgroundThenForeground_endcardGetsBothCallbacks() {
        let mockEndcard = MockInterruptionDelegate()
        handler.activateContext(.endcard, with: mockEndcard)

        postWillResignActive()
        XCTAssertEqual(mockEndcard.adHasNoFocusCallCount, 1, "Endcard should be paused when app backgrounds")

        mockEndcard.reset()
        postDidBecomeActive()
        XCTAssertEqual(mockEndcard.adHasFocusCallCount, 1, "Endcard should resume when app foregrounds")
    }

    func test_endcardDeactivatedDuringBackground_vastPlayerActivated_foreground_deliversAdHasFocusToVAST() {
        // Edge case: cleanup (deactivateContext) happens while app is backgrounded
        let mockEndcard = MockInterruptionDelegate()
        handler.activateContext(.endcard, with: mockEndcard)

        postWillResignActive()

        // Cleanup while backgrounded (dealloc / removingReferences scenario)
        handler.deactivateContext(.endcard)
        handler.activateContext(.vastPlayer, with: mockVAST)

        mockVAST.reset()
        postDidBecomeActive()

        XCTAssertEqual(mockVAST.adHasFocusCallCount, 1, "VAST player should get adHasFocus even when endcard was cleaned up while backgrounded")
    }

    // MARK: - Helpers

    private func postWillResignActive() {
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
    }

    private func postDidBecomeActive() {
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}
