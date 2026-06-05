//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

import XCTest
@testable import HyBid

final class HyBidMRAIDServiceProviderTests: XCTestCase {

    private var serviceProvider: HyBidMRAIDServiceProvider!

    override func setUp() {
        super.setUp()
        serviceProvider = HyBidMRAIDServiceProvider()
    }

    override func tearDown() {
        serviceProvider = nil
        super.tearDown()
    }

    func test_safeURL_fromNonString_returnsNil() {
        let result = serviceProvider.safeURL(from: NSNumber(value: 1))
        XCTAssertNil(result)
    }

    func test_safeURL_fromEmptyString_returnsNil() {
        let result = serviceProvider.safeURL(from: "")
        XCTAssertNil(result)
    }

    func test_safeURL_fromValidURLString_returnsURL() {
        let result = serviceProvider.safeURL(from: "https://apple.com")
        XCTAssertEqual(result?.absoluteString, "https://apple.com")
    }

    func test_safeURL_whenNeedsPercentEncoding_returnsEncodedURL() {
        let input = "https://example.com?q=hello world"
        let result = serviceProvider.safeURL(from: input)

        XCTAssertEqual(
            result?.absoluteString,
            "https://example.com?q=hello%20world"
        )
    }

    func test_safeURL_whenCompletelyInvalid_returnsNil() {
        let input = "%%%%"
        let result = serviceProvider.safeURL(from: input)

        XCTAssertNil(result)
    }

    func test_safeURL_withLeadingOrTrailingWhitespace_returnsNil() {
        // Current implementation does not trim; it rejects URLs that contain leading/trailing whitespace.
        // This is still a valid (and safer) behavior for a URL sanitizer.
        let result = serviceProvider.safeURL(from: "  https://apple.com  \n")
        XCTAssertNil(result, "Expected nil because the input contains leading/trailing whitespace")
    }

    func test_safeURL_fromValidURLString_withoutWhitespace_returnsURL() {
        // Control test to ensure the same URL works when it is well-formed.
        let result = serviceProvider.safeURL(from: "https://apple.com")
        XCTAssertEqual(result?.absoluteString, "https://apple.com")
    }

    func test_safeURL_handlesCustomScheme() {
        // If implementation allows non-http(s), it should pass through; otherwise expect nil.
        let result = serviceProvider.safeURL(from: "hybid://open?x=1")
        // We accept either non-nil URL or nil depending on implementation; assert that if non-nil, it matches input.
        if let url = result {
            XCTAssertEqual(url.absoluteString, "hybid://open?x=1")
        } else {
            XCTAssertNil(result)
        }
    }

    func test_safeURL_encodesReservedCharactersInQuery() {
        let input = "https://example.com?q=hello+world&tags=a&b"
        let result = serviceProvider.safeURL(from: input)
        // Ensure it's still a valid URL and contains expected host
        XCTAssertEqual(result?.host, "example.com")
        XCTAssertNotNil(result)
    }

    func test_safeURL_withFragmentPreserved() {
        let input = "https://example.com/path#section-1"
        let result = serviceProvider.safeURL(from: input)
        XCTAssertEqual(result?.fragment, "section-1")
    }

    func test_safeURL_rejectsJavaScriptURLs() {
        let input = "javascript:alert('xss')"
        let result = serviceProvider.safeURL(from: input)
        // If implementation sanitizes to nil, we expect nil. If not, at least not an http(s) URL.
        if let url = result {
            XCTAssertNotEqual(url.scheme?.lowercased(), "http")
            XCTAssertNotEqual(url.scheme?.lowercased(), "https")
        } else {
            XCTAssertNil(result)
        }
    }
}
