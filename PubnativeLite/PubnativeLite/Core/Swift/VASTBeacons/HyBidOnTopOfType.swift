// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@objc
public enum HyBidOnTopOfType: Int, CaseIterable {
    case UNKNOWN_TOP_EVENT
    case DISPLAY
    case COMPANION_AD
    case CUSTOM_ENDCARD
    
    public func stringValue() -> String {
        switch self {
        case .UNKNOWN_TOP_EVENT: return "0"
        case .DISPLAY: return "1"
        case .COMPANION_AD: return "2"
        case .CUSTOM_ENDCARD: return "3"
        }
    }
}
