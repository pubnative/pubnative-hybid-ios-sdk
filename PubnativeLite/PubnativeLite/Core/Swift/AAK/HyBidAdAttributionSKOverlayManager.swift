//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import AdAttributionKit

@objc public class HyBidAdAttributionSKOverlayManager: NSObject {

    @available(iOS 17.4, *)
    @objc public func getAppConfiguration(appIdentifier:String?, position:SKOverlay.Position, userDismissible: Bool, ad: HyBidAd, adFormat: String) async -> SKOverlay.AppConfiguration? {
        
        guard let appIdentifier else { return .none }
        let appConfiguration = SKOverlay.AppConfiguration(appIdentifier: appIdentifier, position: position)
        appConfiguration.userDismissible = userDismissible
        appConfiguration.appImpression = await HyBidAdAttributionManager.getAppImpression(ad: ad, adFormat: adFormat, aakAdType: .skoverlay)
        
        if #available(iOS 18.0, *), let reengagementURL = await HyBidAdAttributionManager.getReengagementURL(ad: ad) {
            appConfiguration.adAttributionReengagementURL = reengagementURL
        }
        return appConfiguration
    }
}
