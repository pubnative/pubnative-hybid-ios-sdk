//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
@testable import HyBid

final class HyBidConstantsTests: XCTestCase {

    // MARK: - endCardCloseOffset

    func test_endCardCloseOffset_withPerformanceExperience_returnsPCDelay() {
        let offset = HyBidConstants.endCardCloseOffset(adExperience: "performance")
        XCTAssertEqual(offset.offset, NSNumber(value: HyBidSkipOffset.DEFAULT_PC_END_CARD_CLOSE_DELAY))
        XCTAssertFalse(offset.isCustom)
    }

    func test_endCardCloseOffset_withBrandExperience_returnsBCDelay() {
        let offset = HyBidConstants.endCardCloseOffset(adExperience: "brand")
        XCTAssertEqual(offset.offset, NSNumber(value: HyBidSkipOffset.DEFAULT_BC_END_CARD_CLOSE_DELAY))
        XCTAssertFalse(offset.isCustom)
    }

    func test_endCardCloseOffset_withNilExperience_returnsDefaultOffset() {
        let offset = HyBidConstants.endCardCloseOffset(adExperience: nil)
        XCTAssertEqual(offset.offset, NSNumber(value: HyBidSkipOffset.DEFAULT_END_CARD_CLOSE_OFFSET))
        XCTAssertFalse(offset.isCustom)
    }

    func test_endCardCloseOffset_withUnknownExperience_returnsDefaultOffset() {
        let offset = HyBidConstants.endCardCloseOffset(adExperience: "unknown_experience_value")
        XCTAssertEqual(offset.offset, NSNumber(value: HyBidSkipOffset.DEFAULT_END_CARD_CLOSE_OFFSET))
        XCTAssertFalse(offset.isCustom)
    }

    func test_endCardCloseOffset_withEmptyString_returnsDefaultOffset() {
        let offset = HyBidConstants.endCardCloseOffset(adExperience: "")
        XCTAssertEqual(offset.offset, NSNumber(value: HyBidSkipOffset.DEFAULT_END_CARD_CLOSE_OFFSET))
        XCTAssertFalse(offset.isCustom)
    }

    // MARK: - ATOM constants

    func test_atomSurveyParam_hasExpectedValue() {
        XCTAssertEqual(HyBidConstants.ATOM_SURVEY_PARAM, "SurveyHtml")
    }

    func test_atomSurveyDataParam_hasExpectedValue() {
        XCTAssertEqual(HyBidConstants.ATOM_SURVEY_DATA_PARAM, "SurveyData")
    }

    func test_atomKeyPrefix_hasExpectedValue() {
        XCTAssertEqual(HyBidConstants.ATOM_KEY_PREFIX, "atomvalue_")
    }
}
