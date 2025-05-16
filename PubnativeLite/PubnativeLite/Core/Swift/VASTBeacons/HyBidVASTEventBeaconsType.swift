// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//


enum HyBidVASTEventBeaconsType: String, CaseIterable {
    case sdk_event = "sdk_event"
    case companion_ad_event = "companion_ad_event"
    case custom_endcard_event = "custom_endcard_event"
    case autostorekit_event = "autostorekit_event"
    case skoverlay_event = "skoverlay_event"
    
    func stringValue() -> String { return self.rawValue }
}
