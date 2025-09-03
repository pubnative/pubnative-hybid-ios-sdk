// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

enum HyBidSDKEventType: String, CaseIterable {
    case UNKNOWN_SDK_EVENT = "0"
    case LOAD = "1"
    case SHOW = "2"
    case REPLAY = "3"

    func stringValue() -> String { return self.rawValue }
}
