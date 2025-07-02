// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

struct HyBidVASTsdkEvent {
    let name: String
    let vastEventBeaconType: HyBidVASTEventBeaconsType
    
    func sdkEventType() -> HyBidSDKEventType {
        switch self.name {
        case EventType.LOAD,
             EventType.LOAD_FAIL:
            return .LOAD
        
        case EventType.SHOW:
            return .SHOW
            
        case EventType.REPLAY:
            return .REPLAY
            
        default:
            return .UNKNOWN_SDK_EVENT
        }
    }
}
