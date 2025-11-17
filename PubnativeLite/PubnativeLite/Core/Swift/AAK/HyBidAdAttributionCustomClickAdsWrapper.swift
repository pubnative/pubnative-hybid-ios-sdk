//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

import Foundation
import AdAttributionKit

@objc public class HyBidAdAttributionCustomClickAdsWrapper: NSObject {
    
    private var adManager : Any? = nil
    private var isAdUsingCustomMarketplace = false
    
    @objc public init(ad: HyBidAd, adFormat: String? = nil) {
        super.init()
        
        if #available(iOS 17.4, *){
            self.adManager = HyBidAdAttributionCustomClickAdsManager(ad: ad, adFormat: adFormat)
        }

        guard let aakModel = ad.isUsingOpenRTB ? ad.getOpenRTBAdAttributionModel() : ad.getAttributionModel(),
              let productParameters = aakModel.productParameters,
              let customMarketPlaceParameter = productParameters[HyBidAdAttributionParameter.custom_market_place],
              let customMarketPlaceValue = customMarketPlaceParameter as? Bool else { return }
        
        self.isAdUsingCustomMarketplace = customMarketPlaceValue
    }
    
    @objc public func startImpression(adView: UIView?) {
        guard #available(iOS 17.4, *),
              isAdUsingCustomMarketplace,
              let adManager = adManager as? HyBidAdAttributionCustomClickAdsManager,
              let adView = adView else { return }
        
        adManager.startImpression(adView: adView)
    }
    
    @objc public func adHasCustomMarketPlace() -> Bool {
        return isAdUsingCustomMarketplace
    }
    
    @objc public func handlingCustomMarketPlace(completion: @escaping (Bool) -> Void) {
        guard #available(iOS 17.4, *),
              isAdUsingCustomMarketplace,
              let adManager = adManager as? HyBidAdAttributionCustomClickAdsManager else {
            completion(false)
            return
        }

        handlingCustomMarketPlaceAsync(adManager: adManager, completion: completion)
    }

    @available(iOS 17.4, *)
    private func handlingCustomMarketPlaceAsync(adManager: HyBidAdAttributionCustomClickAdsManager, completion: @escaping (Bool) -> Void) {
        Task {
            completion(await adManager.handleTap())
        }
    }
}
