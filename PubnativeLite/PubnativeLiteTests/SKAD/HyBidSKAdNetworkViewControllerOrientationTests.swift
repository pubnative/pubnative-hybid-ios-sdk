//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
import StoreKit
import UIKit
@testable import HyBid

/// Regression tests for the orientation crash fixed in VMI-1553 / VMI-1607 / VMI-1605.
///
/// The crash was caused by HyBid's extension on SKStoreProductViewController overriding
/// supportedInterfaceOrientations and delegating to presentingViewController, which in turn
/// asked its visibleViewController — creating infinite recursion under iOS's orientation
/// query lock. Removing the override eliminates the cycle; these tests confirm it stays gone.
@MainActor
final class HyBidSKAdNetworkViewControllerOrientationTests: XCTestCase {

    // MARK: - Recursive-cycle regression (VMI-1553 / VMI-1607 / VMI-1605)

    /// Reproduces the exact runtime topology that caused the crash:
    /// skVC.presentingViewController == navVC, navVC.visibleViewController == skVC.
    /// If HyBid ever reintroduces an orientation override that delegates to presentingViewController,
    /// this test will crash with a stack overflow.
    func test_supportedInterfaceOrientations_withRecursivePresentingVC_doesNotCrash() {
        let skVC = MockSKStoreProductViewController()
        let navVC = RecursiveOrientationNavController(rootViewController: UIViewController())
        skVC.mockPresentingViewController = navVC
        navVC.mockVisibleVC = skVC

        XCTAssertNoThrow({ _ = skVC.supportedInterfaceOrientations }())
        XCTAssertNotEqual(skVC.supportedInterfaceOrientations.rawValue, 0)
    }

    func test_shouldAutorotate_withRecursivePresentingVC_doesNotCrash() {
        let skVC = MockSKStoreProductViewController()
        let navVC = RecursiveOrientationNavController(rootViewController: UIViewController())
        skVC.mockPresentingViewController = navVC
        navVC.mockVisibleVC = skVC

        XCTAssertNoThrow({ _ = skVC.shouldAutorotate }())
    }

    // MARK: - Baseline sanity checks

    func test_supportedInterfaceOrientations_doesNotCrash() {
        let skVC = SKStoreProductViewController()
        XCTAssertNoThrow({ _ = skVC.supportedInterfaceOrientations }())
    }

    func test_supportedInterfaceOrientations_returnsNonZeroMask() {
        let skVC = SKStoreProductViewController()
        XCTAssertNotEqual(skVC.supportedInterfaceOrientations.rawValue, 0)
    }

    func test_supportedInterfaceOrientations_calledRepeatedly_returnsSameValue() {
        let skVC = SKStoreProductViewController()
        let first  = skVC.supportedInterfaceOrientations
        let second = skVC.supportedInterfaceOrientations
        let third  = skVC.supportedInterfaceOrientations
        XCTAssertEqual(first, second)
        XCTAssertEqual(second, third)
    }

    func test_shouldAutorotate_doesNotCrash() {
        let skVC = SKStoreProductViewController()
        XCTAssertNoThrow({ _ = skVC.shouldAutorotate }())
    }
}

// MARK: - Test Doubles

/// Lets tests inject a mock presentingViewController without a real window hierarchy,
/// replicating the runtime state where skVC has been modally presented over a nav controller.
private class MockSKStoreProductViewController: SKStoreProductViewController {
    var mockPresentingViewController: UIViewController?
    override var presentingViewController: UIViewController? { mockPresentingViewController }
}

/// Simulates the UINavigationController(Autorotate) category from the crash log.
/// Its supportedInterfaceOrientations queries visibleViewController, which in the crash
/// scenario pointed back to the SKStoreProductViewController — forming the recursive cycle.
private class RecursiveOrientationNavController: UINavigationController {
    var mockVisibleVC: UIViewController?

    override var visibleViewController: UIViewController? {
        mockVisibleVC ?? super.visibleViewController
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
}
