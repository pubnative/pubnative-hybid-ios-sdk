//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
import Foundation
@testable import HyBid

final class HyBidTimeResolverTests: XCTestCase {

    // MARK: - Valid

    func test_absoluteSeconds_wellFormed_returnsSeconds() {
        XCTAssertEqual(HyBidTimeResolver.absoluteSeconds(from: "00:00:08"), 8)
        XCTAssertEqual(HyBidTimeResolver.absoluteSeconds(from: "01:02:03"), 3723)
    }

    func test_absoluteSeconds_fractionalSeconds_returnsSeconds() {
        XCTAssertEqual(HyBidTimeResolver.absoluteSeconds(from: "00:00:00.500"), 0.5)
    }

    func test_absoluteSeconds_trimsWhitespace_returnsSeconds() {
        XCTAssertEqual(HyBidTimeResolver.absoluteSeconds(from: "  00:00:08  "), 8)
    }

    // MARK: - Invalid

    func test_absoluteSeconds_wrongComponentCount_returnsNil() {
        XCTAssertNil(HyBidTimeResolver.absoluteSeconds(from: "00:08"))
        XCTAssertNil(HyBidTimeResolver.absoluteSeconds(from: "20%"))
    }

    func test_absoluteSeconds_nonNumericComponent_returnsNil() {
        XCTAssertNil(HyBidTimeResolver.absoluteSeconds(from: "aa:00:08"))
    }

    func test_absoluteSeconds_fractionalHoursOrMinutes_returnsNil() {
        XCTAssertNil(HyBidTimeResolver.absoluteSeconds(from: "00:00.5:08"))
    }

    func test_absoluteSeconds_empty_returnsNil() {
        XCTAssertNil(HyBidTimeResolver.absoluteSeconds(from: ""))
    }

    // MARK: - Objective-C bridge

    func test_absoluteSecondsFromString_wellFormed_returnsNSNumber() {
        XCTAssertEqual(HyBidTimeResolver.absoluteSecondsFromString("00:00:08"), 8)
    }

    func test_absoluteSecondsFromString_malformed_returnsNil() {
        XCTAssertNil(HyBidTimeResolver.absoluteSecondsFromString("garbage"))
    }
}
