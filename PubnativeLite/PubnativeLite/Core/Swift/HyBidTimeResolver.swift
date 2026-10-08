//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidTimeResolver: NSObject {

    // Parses a VAST "HH:MM:SS" or "HH:MM:SS.mmm" duration/skipoffset into seconds.
    public static func absoluteSeconds(from string: String) -> Double? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmed.components(separatedBy: ":")
        guard components.count == 3,
              isNumericTimeComponent(components[0], allowFraction: false),
              isNumericTimeComponent(components[1], allowFraction: false),
              isNumericTimeComponent(components[2], allowFraction: true),
              let hours = Double(components[0]),
              let minutes = Double(components[1]),
              let seconds = Double(components[2]) else {
            return nil
        }
        return seconds + minutes * 60 + hours * 3600
    }

    @objc(absoluteSecondsFromString:)
    public static func absoluteSecondsFromString(_ string: String) -> NSNumber? {
        guard let seconds = absoluteSeconds(from: string) else {
            return nil
        }
        return NSNumber(value: seconds)
    }

    // VAST time components must be numeric: NSString integerValue returns 0 for text like "aa",
    // which would turn a malformed skipoffset into an instantly skippable ad (VMI-1705).
    static func isNumericTimeComponent(_ component: String, allowFraction: Bool) -> Bool {
        let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.components(separatedBy: ".")
        guard parts.count <= (allowFraction ? 2 : 1) else { return false }
        // ASCII 0-9 only: decimalDigitCharacterSet covers all Unicode Nd digits, which pass the
        // guard but parse to 0 via integerValue. The 9-digit bound prevents hours * 3600 overflow.
        for part in parts {
            guard !part.isEmpty, part.count <= 9,
                  part.allSatisfy({ $0.isASCII && $0.isNumber }) else {
                return false
            }
        }
        return true
    }
}
