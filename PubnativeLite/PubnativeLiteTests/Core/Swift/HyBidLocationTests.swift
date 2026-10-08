//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

import XCTest
import Foundation
@testable import HyBid

final class HyBidLocationTests: XCTestCase {

    // MARK: - roundedCoordinate tests

    func test_roundedCoordinate_roundsToTwoDecimalPlaces() {
        XCTAssertEqual(HyBidLocationHelper.roundedCoordinate(52.345678), 52.35)
    }

    func test_roundedCoordinate_negativeValue_roundsCorrectly() {
        XCTAssertEqual(HyBidLocationHelper.roundedCoordinate(-73.935242), -73.94)
    }

    func test_roundedCoordinate_alreadyRounded_staysUnchanged() {
        XCTAssertEqual(HyBidLocationHelper.roundedCoordinate(40.71), 40.71)
    }

    func test_roundedCoordinate_zero_returnsZero() {
        XCTAssertEqual(HyBidLocationHelper.roundedCoordinate(0.0), 0.0)
    }

    // MARK: - formattedCoordinate tests

    func test_formattedCoordinate_returnsTwoDecimalString() {
        XCTAssertEqual(HyBidLocationHelper.formattedCoordinate(52.345678), "52.35")
    }

    func test_formattedCoordinate_padsTrailingZero() {
        XCTAssertEqual(HyBidLocationHelper.formattedCoordinate(52.3), "52.30")
    }

    func test_formattedCoordinate_negativeValue() {
        XCTAssertEqual(HyBidLocationHelper.formattedCoordinate(-73.935242), "-73.94")
    }
}
