// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidCustomCTATracking: NSObject {
    
    private let PNLiteAdCustomCTAImpression = "custom_cta_show"
    private let PNLiteAdCustomCTAClick = "custom_cta_click"
    private let PNLiteAdCustomCTAEndCardClick = "custom_cta_endcard_click"
    
    private var impressionBeaconsArray: Array<HyBidDataModel> = []
    private var clickBeaconsArray: Array<HyBidDataModel> = []
    private var endCardClickBeaconsArray: Array<HyBidDataModel> = []
    
    @available(*, unavailable)
    public override init() {}
    
    @objc public init(ad: HyBidAd) {
        if let impressionBeacons = ad.beaconsData(withType: PNLiteAdCustomCTAImpression) as? Array<HyBidDataModel> {
            self.impressionBeaconsArray = impressionBeacons
        }
        
        if let clickBeacons = ad.beaconsData(withType: PNLiteAdCustomCTAClick) as? Array<HyBidDataModel> {
            self.clickBeaconsArray = clickBeacons
        }
        
        if let endCardClickBeacons = ad.beaconsData(withType: PNLiteAdCustomCTAEndCardClick) as? Array<HyBidDataModel> {
            self.endCardClickBeaconsArray = endCardClickBeacons
        }
    }
    
    @objc public func impressionBeacons() -> Array<HyBidDataModel> { return self.impressionBeaconsArray }
    
    @objc public func clickBeacons() -> Array<HyBidDataModel> { return self.clickBeaconsArray }
    
    @objc public func endCardClickBeacons() -> Array<HyBidDataModel> { return self.endCardClickBeaconsArray }
}
