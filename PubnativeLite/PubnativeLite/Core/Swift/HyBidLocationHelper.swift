//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

import Foundation

@objc
public class HyBidLocationHelper: NSObject {
    static let coordinateRoundingPlaces = 2
    
    @objc(roundedCoordinate:)
    public static func roundedCoordinate(_ value: Double) -> Double {
        return value.rounded(toPlaces: coordinateRoundingPlaces)
    }
    
    @objc(formattedCoordinate:)
    public static func formattedCoordinate(_ value: Double) -> String {
        return String(format: "%.\(coordinateRoundingPlaces)f", locale: Locale(identifier: "en_US_POSIX"), roundedCoordinate(value))
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
