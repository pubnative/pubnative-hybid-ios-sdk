// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

enum HyBidAuxiliaryAdEventType: String, CaseIterable {
    case UNKNOWN_AUXILIARY_AD_EVENT = "0"
    case IMPRESSION = "1"
    case SKIP = "2"
    case CLOSE = "3"
    case CLICK = "4"
    case ERROR = "5"
    
    func stringValue() -> String { return self.rawValue }
}
