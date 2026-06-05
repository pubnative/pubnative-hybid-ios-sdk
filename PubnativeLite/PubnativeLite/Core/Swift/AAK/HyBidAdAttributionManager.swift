//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import AdAttributionKit

struct HyBidAdAttributionManager {
    
    @available(iOS 17.4, *)
    static func getAppImpression(ad: HyBidAd, adFormat: String? = nil, aakAdType: HyBidAdAttributionAdType) async -> AppImpression? {
        do {
            guard let adAttributionModel = ad.isUsingOpenRTB ? ad.getOpenRTBAdAttributionModel() : ad.getAttributionModel(),
                  let productParameters = adAttributionModel.productParameters as? [String: Any],
                  let jws = productParameters[HyBidAdAttributionParameter.jwt] as? String,
                  !jws.isEmpty, !jws.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .none }
            
            let impression = try await AppImpression(compactJWS: jws)
            
            if HyBidSDKConfig.sharedConfig.reporting {
                let eventType = EventType.AD_ATTRIBUTION_KIT_APP_IMPRESSION.replacingOccurrences(of: EventType.AD_ATTRIBUTION_KIT_AD_TYPE_MACRO, with: aakAdType.rawValue)
                let reportingEvent = HyBidReportingEvent(with: eventType, adFormat: adFormat)
                HyBid.reportingManager().reportEvent(for: reportingEvent)
            }
            return impression
        } catch {
            HyBidLogger.errorLog(fromClass: String(describing: HyBidAdAttributionManager.self), fromMethod: #function, withMessage: "App Impression error: \(error)")
            
            if HyBidSDKConfig.sharedConfig.reporting {
                let properties: [String: Any] = [Common.ERROR_MESSAGE: error.localizedDescription,
                                                 Common.ERROR_CODE: (error as NSError).code]
                let eventType = EventType.AD_ATTRIBUTION_KIT_APP_IMPRESSION_ERROR.replacingOccurrences(of: EventType.AD_ATTRIBUTION_KIT_AD_TYPE_MACRO, with: aakAdType.rawValue)
                let reportingEvent = HyBidReportingEvent(with: eventType, errorMessage: error.localizedDescription, properties: properties)
                HyBid.reportingManager().reportEvent(for: reportingEvent)
            }
        }
        return .none
    }
    
    @available(iOS 13.0, *)
    static func getReengagementURL(ad: HyBidAd) async -> URL? {
        guard #available(iOS 17.4, *) else {
            return nil
        }
        
        guard let adAttributionModel = ad.isUsingOpenRTB ? ad.getOpenRTBAdAttributionModel() : ad.getAttributionModel(),
              let productParameters = adAttributionModel.productParameters as? [String: Any],
              let reengagementURLString = productParameters[HyBidAdAttributionParameter.reengagement_url] as? String,
              !reengagementURLString.isEmpty, !reengagementURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let reengagementURL = URL(string: reengagementURLString) else { return .none }
        
        return reengagementURL
    }
}
