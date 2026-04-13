//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
import UIKit
@testable import HyBid

final class HyBidInternalWebBrowserTests: XCTestCase {

    override func tearDown() {
        HyBidInternalWebBrowser.shared.isInternalBrowserBeingPresented = false
        super.tearDown()
    }

    func test_navigateToURL_withValidHTTPSUrl_doesNotCrash() {
        let expectation = expectation(description: "navigateToURL completes")
        HyBidInternalWebBrowser.shared.navigateToURL("https://example.com/path")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 2.0)
    }

    func test_navigateToURL_withInvalidURL_doesNotCrash() {
        let expectation = expectation(description: "navigateToURL completes")
        HyBidInternalWebBrowser.shared.navigateToURL("not-a-url")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 2.0)
    }

    func test_navigateToURL_withEmptyString_doesNotCrash() {
        let expectation = expectation(description: "navigateToURL completes")
        HyBidInternalWebBrowser.shared.navigateToURL("")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 2.0)
    }

    func test_webBrowserNavigationBehaviourFromString_internal_returnsInternal() {
        let internalResult = HyBidInternalWebBrowser.shared.webBrowserNavigationBehaviourFromString("internal")
        let externalResult = HyBidInternalWebBrowser.shared.webBrowserNavigationBehaviourFromString("external")
        XCTAssertNotEqual(internalResult, externalResult)
    }

    func test_webBrowserNavigationBehaviourFromString_external_returnsExternal() {
        let externalResult = HyBidInternalWebBrowser.shared.webBrowserNavigationBehaviourFromString("external")
        XCTAssertEqual(HyBidInternalWebBrowser.shared.webBrowserNavigationBehaviourFromString("external"), externalResult)
        XCTAssertEqual(HyBidInternalWebBrowser.shared.webBrowserNavigationBehaviourFromString(nil), externalResult)
        XCTAssertEqual(HyBidInternalWebBrowser.shared.webBrowserNavigationBehaviourFromString("other"), externalResult)
    }

    func test_shared_isSingleton() {
        XCTAssertTrue(HyBidInternalWebBrowser.shared === HyBidInternalWebBrowser.shared)
    }
}
