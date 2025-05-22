// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@objc
public class HyBidLandingBehaviour: NSObject {
    
    @objc public enum HyBidLandingBehaviourType: Int32 {
        
        case instantCloseButton
        case noCountdown
        case countdown
        case unknown
        
        var stringValue: String? {
            switch self {
            case .instantCloseButton: return "ic"
            case .noCountdown: return "nc"
            case .countdown: return "c"
            case .unknown: return .none
            }
        }
    }
    
    @objc public func convertString(value: String?) -> HyBidLandingBehaviourType {
        
        guard let value = value, value.isEmpty == false else {
            return .unknown
        }
        
        switch value {
        case HyBidLandingBehaviourType.instantCloseButton.stringValue: return .instantCloseButton
        case HyBidLandingBehaviourType.noCountdown.stringValue: return .noCountdown
        case HyBidLandingBehaviourType.countdown.stringValue: return .countdown
        default: return .unknown
        }
    }
}
