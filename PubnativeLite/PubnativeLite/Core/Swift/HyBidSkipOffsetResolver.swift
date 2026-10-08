//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidSkipOffsetResolution: NSObject {

    @objc public let skipOffset: HyBidSkipOffset?
    @objc public let hasInvalidVASTSkipOffset: Bool

    init(skipOffset: HyBidSkipOffset?, hasInvalidVASTSkipOffset: Bool) {
        self.skipOffset = skipOffset
        self.hasInvalidVASTSkipOffset = hasInvalidVASTSkipOffset
    }
}

@objc
public class HyBidSkipOffsetResolver: NSObject {

    static let absentSkipOffsetSentinel = "-1"

    @objc(resolveWithSkipOffsetChain:durationString:remoteConfigOffset:remoteConfigPercentage:sdkDefaultOffset:)
    public static func resolve(skipOffsetChain: [String],
                               durationString: String?,
                               remoteConfigOffset: NSNumber?,
                               remoteConfigPercentage: String?,
                               sdkDefaultOffset: NSNumber?) -> HyBidSkipOffsetResolution {
        let durationSeconds = durationString.flatMap { HyBidTimeResolver.absoluteSeconds(from: $0) } ?? 0
        let vastOffset = finalSkipOffset(in: skipOffsetChain)
        let hasInvalidVASTSkipOffset = vastOffset.map { !isValidSkipOffset($0) } ?? false
        if hasInvalidVASTSkipOffset, let vastOffset = vastOffset {
            logDiscarded(vastOffset, source: "VAST")
        }

        guard let sdkDefaultOffset = sdkDefaultOffset else {
            return HyBidSkipOffsetResolution(skipOffset: nil, hasInvalidVASTSkipOffset: hasInvalidVASTSkipOffset)
        }

        let vastSeconds = vastOffset.flatMap { seconds(fromSkipOffset: $0, durationSeconds: durationSeconds) }
        let remoteConfigSeconds = resolveRemoteConfig(offset: remoteConfigOffset,
                                                      percentage: remoteConfigPercentage,
                                                      durationSeconds: durationSeconds)
        let skipOffset: HyBidSkipOffset?
        if let vastSeconds = vastSeconds {
            // Zero is a genuine ceiling (skippable immediately), matching Android's isValidSkipOffset >= 0.
            if let remoteConfigSeconds = remoteConfigSeconds, remoteConfigSeconds < vastSeconds {
                skipOffset = HyBidSkipOffset(offset: NSNumber(value: remoteConfigSeconds), isCustom: false)
            } else {
                skipOffset = HyBidSkipOffset(offset: NSNumber(value: vastSeconds), isCustom: true)
            }
        } else if let remoteConfigSeconds = remoteConfigSeconds {
            skipOffset = HyBidSkipOffset(offset: NSNumber(value: remoteConfigSeconds), isCustom: false)
        } else if hasInvalidVASTSkipOffset {
            skipOffset = HyBidSkipOffset(offset: sdkDefaultOffset, isCustom: false)
        } else {
            skipOffset = nil
        }
        return HyBidSkipOffsetResolution(skipOffset: skipOffset, hasInvalidVASTSkipOffset: hasInvalidVASTSkipOffset)
    }

    static func seconds(fromSkipOffset skipOffset: String, durationSeconds: Double) -> Int? {
        if let absoluteSeconds = HyBidTimeResolver.absoluteSeconds(from: skipOffset) {
            return Int(absoluteSeconds)
        }
        guard let percent = validPercent(skipOffset), durationSeconds > 0 else { return nil }
        return Int((durationSeconds * percent / 100.0).rounded())
    }

    private static func isValidSkipOffset(_ skipOffset: String) -> Bool {
        return HyBidTimeResolver.absoluteSeconds(from: skipOffset) != nil || validPercent(skipOffset) != nil
    }

    private static func finalSkipOffset(in skipOffsetChain: [String]) -> String? {
        return skipOffsetChain
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .last { !$0.isEmpty && $0 != absentSkipOffsetSentinel }
    }

    private static func resolveRemoteConfig(offset: NSNumber?, percentage: String?, durationSeconds: Double) -> Int? {
        if let offset = offset {
            return offset.intValue >= 0 ? offset.intValue : nil
        }
        guard let percentage = percentage?.trimmingCharacters(in: .whitespacesAndNewlines), !percentage.isEmpty else {
            return nil
        }
        guard validPercent(percentage) != nil else {
            logDiscarded(percentage, source: "remote config")
            return nil
        }
        return seconds(fromSkipOffset: percentage, durationSeconds: durationSeconds)
    }

    private static func validPercent(_ raw: String) -> Double? {
        guard raw.hasSuffix("%"), raw.count > 1 else { return nil }
        let numericPart = String(raw.dropLast())
        guard HyBidTimeResolver.isNumericTimeComponent(numericPart, allowFraction: true),
              let percent = Double(numericPart),
              percent >= 0, percent <= 100 else {
            return nil
        }
        return percent
    }

    private static func logDiscarded(_ raw: String, source: String) {
        HyBidLogger.warningLog(fromClass: "HyBidSkipOffsetResolver",
                                fromMethod: "resolve(skipOffsetChain:durationString:remoteConfigOffset:remoteConfigPercentage:sdkDefaultOffset:)",
                                withMessage: "Discarding invalid \(source) skipoffset \"\(raw)\"")
    }
}
