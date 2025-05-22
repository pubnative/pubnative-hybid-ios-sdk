// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

struct HyBidVASTauxiliaryAdEvent {
    let name: String
    let vastEventBeaconType: HyBidVASTEventBeaconsType
    
    func auxiliaryAdEventType() -> HyBidAuxiliaryAdEventType {
        switch self.name {
        case EventType.DEFAULT_ENDCARD_IMPRESSION,
             EventType.CUSTOM_ENDCARD_IMPRESSION,
             EventType.SKOVERLAY_IMPRESSION,
             EventType.AUTO_STORE_KIT_IMPRESSION:
            return .IMPRESSION
            
        case EventType.DEFAULT_ENDCARD_SKIP:
            return .SKIP        
            
        case EventType.DEFAULT_ENDCARD_CLOSE,
             EventType.CUSTOM_ENDCARD_CLOSE:
            return .CLOSE
            
        case EventType.DEFAULT_ENDCARD_CLICK,
             EventType.CUSTOM_ENDCARD_CLICK:
            return .CLICK
        
        case EventType.DEFAULT_ENDCARD_IMPRESSION_ERROR,
             EventType.CUSTOM_ENDCARD_IMPRESSION_ERROR,
             EventType.SKOVERLAY_IMPRESSION_ERROR,
             EventType.AUTO_STORE_KIT_IMPRESSION_ERROR:
            return .ERROR
    
        default:
            return .UNKNOWN_AUXILIARY_AD_EVENT
        }
    }
}
