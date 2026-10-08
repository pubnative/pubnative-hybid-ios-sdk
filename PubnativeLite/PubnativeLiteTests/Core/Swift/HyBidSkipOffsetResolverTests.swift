//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import XCTest
import Foundation
@testable import HyBid

final class HyBidSkipOffsetResolverTests: XCTestCase {

    private let interstitialDefault = NSNumber(value: HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET)

    // MARK: - seconds(fromSkipOffset:)

    func test_secondsFromSkipOffset_absoluteAndPercentage() {
        XCTAssertEqual(HyBidSkipOffsetResolver.seconds(fromSkipOffset: "00:00:08", durationSeconds: 30), 8)
        XCTAssertEqual(HyBidSkipOffsetResolver.seconds(fromSkipOffset: "00:00:08", durationSeconds: 0), 8)
        XCTAssertEqual(HyBidSkipOffsetResolver.seconds(fromSkipOffset: "20%", durationSeconds: 30), 6)
    }

    func test_secondsFromSkipOffset_percentageWithoutDuration_returnsNil() {
        XCTAssertNil(HyBidSkipOffsetResolver.seconds(fromSkipOffset: "20%", durationSeconds: 0))
    }

    func test_secondsFromSkipOffset_malformed_returnsNil() {
        XCTAssertNil(HyBidSkipOffsetResolver.seconds(fromSkipOffset: "garbage", durationSeconds: 30))
        XCTAssertNil(HyBidSkipOffsetResolver.seconds(fromSkipOffset: "150%", durationSeconds: 30))
    }

    // MARK: - VAST absolute values

    func test_resolve_absoluteVAST_isCustom() {
        let result = resolve(["00:00:12"])
        assertSkipOffset(result, 12, isCustom: true)
        XCTAssertFalse(result.hasInvalidVASTSkipOffset)
    }

    func test_resolve_allZeroComponents_isGenuineZero() {
        assertSkipOffset(resolve(["00:00:00"], remoteConfigOffset: 12), 0, isCustom: true)
    }

    func test_resolve_leadingWhitespace_isAccepted() {
        assertSkipOffset(resolve([" 00:00:05"]), 5, isCustom: true)
    }

    func test_resolve_fractionalSeconds_isTruncated() {
        assertSkipOffset(resolve(["00:00:10.500"]), 10, isCustom: true)
    }

    // MARK: - VAST percentages

    func test_resolve_percentage_resolvesAgainstDuration() {
        assertSkipOffset(resolve(["20%"], duration: "00:01:00"), 12, isCustom: true)
        assertSkipOffset(resolve(["50%"], duration: "00:00:10"), 5, isCustom: true)
    }

    func test_resolve_zeroPercentage_isGenuineZero() {
        assertSkipOffset(resolve(["0%"], duration: "00:01:00"), 0, isCustom: true)
    }

    func test_resolve_hundredPercentage_equalsFullDuration() {
        assertSkipOffset(resolve(["100%"], duration: "00:01:00"), 60, isCustom: true)
    }

    func test_resolve_fractionalPercentage_resolvesAgainstDuration() {
        assertSkipOffset(resolve(["20.5%"], duration: "00:01:00"), 12, isCustom: true)
    }

    func test_resolve_percentageWithFractionalDuration_keepsFraction() {
        assertSkipOffset(resolve(["100%"], duration: "00:00:00.500"), 1, isCustom: true)
    }

    func test_resolve_percentageWithoutDuration_isNotAnErrorAndKeepsCurrentSkipOffset() {
        let output = captureStdout {
            let result = resolve(["20%"], duration: nil)
            XCTAssertNil(result.skipOffset)
            XCTAssertFalse(result.hasInvalidVASTSkipOffset)
        }
        XCTAssertTrue(output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Expected no warning, got: \(output)")
    }

    // MARK: - Invalid VAST values

    func test_resolve_invalidValues_reportErrorAndFallBackToSDKDefault() {
        for invalid in ["garbage", "aa:bb:cc", "00:08", "00:00:𝟝", "9999999999999999999:00:00", "abc%", "150%", "%", "-1%"] {
            let result = resolve([invalid])
            assertSkipOffset(result, HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET, isCustom: false, invalid)
            XCTAssertTrue(result.hasInvalidVASTSkipOffset, invalid)
        }
    }

    func test_resolve_invalidValue_logsWarning() {
        let output = captureStdout { _ = resolve(["garbage"]) }
        XCTAssertTrue(output.contains("Discarding invalid VAST skipoffset \"garbage\""))
    }

    func test_resolve_invalidValue_fallsBackToRemoteConfig() {
        assertSkipOffset(resolve(["garbage"], remoteConfigOffset: 7), 7, isCustom: false)
    }

    func test_resolve_invalidValue_fallsBackToRemoteConfigPercentage() {
        let result = resolve(["garbage"], duration: "00:00:30", remoteConfigPercentage: "50%")
        assertSkipOffset(result, 15, isCustom: false)
        XCTAssertTrue(result.hasInvalidVASTSkipOffset)
    }

    func test_resolve_invalidValue_zeroRemoteConfig_isGenuineZero() {
        assertSkipOffset(resolve(["garbage"], remoteConfigOffset: 0), 0, isCustom: false)
    }

    func test_resolve_invalidValue_negativeRemoteConfig_fallsBackToSDKDefault() {
        assertSkipOffset(resolve(["garbage"], remoteConfigOffset: -5), HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET, isCustom: false)
    }

    // MARK: - Wrapper -> Inline chain

    func test_resolve_validInline_winsOverWrapper() {
        assertSkipOffset(resolve(["00:00:08", "20%"], duration: "00:00:30"), 6, isCustom: true)
    }

    func test_resolve_wrapperPercentage_resolvesAgainstInlineDuration() {
        assertSkipOffset(resolve(["20%", "-1"], duration: "00:00:30"), 6, isCustom: true)
    }

    func test_resolve_absentOrEmptyInline_keepsWrapperWithoutError() {
        for absent in ["-1", " -1 ", "", "   "] {
            let result = resolve(["00:00:08", absent])
            assertSkipOffset(result, 8, isCustom: true, absent)
            XCTAssertFalse(result.hasInvalidVASTSkipOffset, absent)
        }
    }

    func test_resolve_invalidInline_overwritesValidWrapper() {
        let result = resolve(["00:00:08", "garbage"])
        assertSkipOffset(result, HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET, isCustom: false)
        XCTAssertTrue(result.hasInvalidVASTSkipOffset)
    }

    func test_resolve_invalidWrapperValidInline_usesInlineWithoutError() {
        let result = resolve(["garbage", "00:00:05"])
        assertSkipOffset(result, 5, isCustom: true)
        XCTAssertFalse(result.hasInvalidVASTSkipOffset)
    }

    func test_resolve_invalidWrapperEmptyInline_reportsError() {
        let result = resolve(["garbage", ""])
        assertSkipOffset(result, HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET, isCustom: false)
        XCTAssertTrue(result.hasInvalidVASTSkipOffset)
    }

    // MARK: - min(VAST, remote config) (VMI-1704)

    func test_resolve_remoteConfigBelowVAST_remoteConfigWins() {
        assertSkipOffset(resolve(["00:00:08"], remoteConfigOffset: 5), 5, isCustom: false)
        assertSkipOffset(resolve(["00:02:00"], remoteConfigOffset: 30), 30, isCustom: false)
    }

    func test_resolve_vastBelowOrEqualRemoteConfig_vastWins() {
        assertSkipOffset(resolve(["00:00:05"], remoteConfigOffset: 8), 5, isCustom: true)
        assertSkipOffset(resolve(["00:00:08"], remoteConfigOffset: 8), 8, isCustom: true)
    }

    func test_resolve_zeroRemoteConfig_actsAsCeiling() {
        assertSkipOffset(resolve(["00:00:12"], remoteConfigOffset: 0), 0, isCustom: false)
    }

    func test_resolve_genuineZeroVAST_staysZeroUnderMin() {
        assertSkipOffset(resolve(["00:00:00"], remoteConfigOffset: 5), 0, isCustom: true)
    }

    func test_resolve_negativeRemoteConfig_treatedAsAbsent() {
        assertSkipOffset(resolve(["00:00:12"], remoteConfigOffset: -5), 12, isCustom: true)
    }

    func test_resolve_remoteConfigPercentageBelowVASTPercentage_remoteConfigWins() {
        assertSkipOffset(resolve(["50%"], duration: "00:00:20", remoteConfigPercentage: "20%"), 4, isCustom: false)
    }

    func test_resolve_numericRemoteConfig_takesPrecedenceOverPercentage() {
        assertSkipOffset(resolve([], duration: "00:00:20", remoteConfigOffset: 7, remoteConfigPercentage: "10%"), 7, isCustom: false)
    }

    // MARK: - Absent VAST

    func test_resolve_absentVAST_remoteConfigApplies() {
        assertSkipOffset(resolve(["-1"], remoteConfigOffset: 7), 7, isCustom: false)
        assertSkipOffset(resolve([], remoteConfigOffset: 0), 0, isCustom: false)
    }

    func test_resolve_absentVAST_remoteConfigPercentageResolvesAgainstDuration() {
        assertSkipOffset(resolve(["-1"], duration: "00:00:14", remoteConfigPercentage: "20%"), 3, isCustom: false)
    }

    func test_resolve_absentVAST_remoteConfigPercentageWithoutDuration_keepsCurrentSkipOffset() {
        XCTAssertNil(resolve(["-1"], duration: nil, remoteConfigPercentage: "0%").skipOffset)
    }

    func test_resolve_absentVASTAndRemoteConfig_keepsCurrentSkipOffset() {
        let result = resolve(["-1"])
        XCTAssertNil(result.skipOffset)
        XCTAssertFalse(result.hasInvalidVASTSkipOffset)
    }

    func test_resolve_invalidRemoteConfigPercentage_logsWarning() {
        let output = captureStdout {
            XCTAssertNil(resolve([], duration: "00:00:30", remoteConfigPercentage: "abc%").skipOffset)
        }
        XCTAssertTrue(output.contains("Discarding invalid remote config skipoffset \"abc%\""))
    }

    // MARK: - Formats without a video skip offset

    func test_resolve_noSDKDefault_appliesNothingButStillReportsInvalidVAST() {
        let valid = HyBidSkipOffsetResolver.resolve(skipOffsetChain: ["20%"], durationString: "00:00:30",
                                                    remoteConfigOffset: nil, remoteConfigPercentage: nil,
                                                    sdkDefaultOffset: nil)
        XCTAssertNil(valid.skipOffset)
        XCTAssertFalse(valid.hasInvalidVASTSkipOffset)

        let invalid = HyBidSkipOffsetResolver.resolve(skipOffsetChain: ["garbage"], durationString: "00:00:30",
                                                      remoteConfigOffset: nil, remoteConfigPercentage: nil,
                                                      sdkDefaultOffset: nil)
        XCTAssertNil(invalid.skipOffset)
        XCTAssertTrue(invalid.hasInvalidVASTSkipOffset)
    }

    // MARK: - setUp / tearDown

    override func setUp() {
        super.setUp()
        HyBidLogger.setLogLevel(HyBidLogLevelWarning)
    }

    override func tearDown() {
        HyBidLogger.setLogLevel(HyBidLogLevelInfo)
        super.tearDown()
    }

    // MARK: Helpers

    private func resolve(_ chain: [String],
                         duration: String? = "00:01:00",
                         remoteConfigOffset: NSNumber? = nil,
                         remoteConfigPercentage: String? = nil) -> HyBidSkipOffsetResolution {
        return HyBidSkipOffsetResolver.resolve(skipOffsetChain: chain,
                                               durationString: duration,
                                               remoteConfigOffset: remoteConfigOffset,
                                               remoteConfigPercentage: remoteConfigPercentage,
                                               sdkDefaultOffset: interstitialDefault)
    }

    private func assertSkipOffset(_ result: HyBidSkipOffsetResolution, _ seconds: Int, isCustom: Bool, _ message: String = "",
                                  file: StaticString = #filePath, line: UInt = #line) {
        guard let skipOffset = result.skipOffset else {
            return XCTFail("Expected a skip offset. \(message)", file: file, line: line)
        }
        XCTAssertEqual(skipOffset.offset?.intValue, seconds, message, file: file, line: line)
        XCTAssertEqual(skipOffset.isCustom, isCustom, message, file: file, line: line)
    }

    private func captureStdout(_ block: () -> Void) -> String {
        fflush(stdout)

        let pipe = Pipe()
        let originalStdout = dup(STDOUT_FILENO)

        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        block()

        fflush(stdout)
        dup2(originalStdout, STDOUT_FILENO)
        close(originalStdout)

        pipe.fileHandleForWriting.closeFile()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        pipe.fileHandleForReading.closeFile()

        return String(data: data, encoding: .utf8) ?? ""
    }
}
