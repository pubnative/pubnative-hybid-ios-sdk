//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import AdAttributionKit

@objc public class HyBidAppImpressionWrapper: NSObject {
    private var impression: Any? // Must use `Any` since `AppImpression` isn't @objc
    
    @available(iOS 17.4, *)
    @objc public static func createWithAd(_ ad: HyBidAd?, adFormat: String) async -> HyBidAppImpressionWrapper? {
        
        guard let ad else { return .none }
        
        let wrapper = HyBidAppImpressionWrapper()
        
        // Store AppImpression internally
        wrapper.impression = await HyBidAdAttributionManager.getAppImpression(ad: ad, adFormat: adFormat, aakAdType: .viewThrough)
        
        return wrapper
    }
    
    // Objective-C-friendly wrapper
    @objc public func createWithAd(_ ad: HyBidAd?, adFormat: String, completion: @escaping (HyBidAppImpressionWrapper?) -> Void) {
        if #available(iOS 17.4, *) {
            createWithAdAsync(ad, adFormat: adFormat, completion: completion)
        } else {
            HyBidLogger.infoLog(fromClass: String(describing: HyBidAppImpressionWrapper.self),
                              fromMethod: #function,
                              withMessage: "AdAttributionKit is not available on iOS versions below 17.4")
            completion(nil)
        }
    }

    @available(iOS 17.4, *)
    private func createWithAdAsync(_ ad: HyBidAd?, adFormat: String, completion: @escaping (HyBidAppImpressionWrapper?) -> Void) {
        Task {
            let wrapper = await HyBidAppImpressionWrapper.createWithAd(ad, adFormat: adFormat)
            completion(wrapper)
        }
    }
    
    /// Begin view with the internally held AppImpression
    @objc public func beginView(forAdFormat adFormat:String, completion: @escaping @convention(block) (Bool) -> Void) {
        if #available(iOS 17.4, *) {
            beginViewAsync(forAdFormat: adFormat, completion: completion)
        } else {
            HyBidLogger.infoLog(fromClass: String(describing: HyBidAppImpressionWrapper.self),
                              fromMethod: #function,
                              withMessage: "AdAttributionKit is not available on iOS versions below 17.4")
            completion(false)
        }
    }

    @available(iOS 17.4, *)
    private func beginViewAsync(forAdFormat adFormat: String, completion: @escaping @convention(block) (Bool) -> Void) {
        guard let impression = self.impression as? AppImpression else {
            completion(false)
            return
        }

        Task {
            do {
                try await impression.beginView()

                if HyBidSDKConfig.sharedConfig.reporting {
                    let reportingEvent = HyBidReportingEvent(with: EventType.AD_ATTRIBUTION_KIT_APP_IMPRESSION_BEGIN_VIEW, adFormat: adFormat)
                    HyBid.reportingManager().reportEvent(for: reportingEvent)
                }

                HyBidLogger.infoLog(fromClass: String(describing: HyBidAppImpressionWrapper.self), fromMethod: #function, withMessage: "AdAttribution AppImpression beginView started successfully.")

                completion(true)
            } catch {
                HyBidLogger.errorLog(fromClass: String(describing: HyBidAppImpressionWrapper.self), fromMethod: #function, withMessage: "AdAttribution AppImpression beginView failed with error: \(error)")

                if HyBidSDKConfig.sharedConfig.reporting {
                    let reportingEvent = HyBidReportingEvent(with: EventType.AD_ATTRIBUTION_KIT_APP_IMPRESSION_BEGIN_VIEW_ERROR, errorMessage: error.localizedDescription)
                    HyBid.reportingManager().reportEvent(for: reportingEvent)
                }
                completion(false)
            }
        }
    }
    
    /// End view with the internally held AppImpression
    @objc public func endView(forAdFormat adFormat:String, completion: @escaping @convention(block) (Bool) -> Void) {
        if #available(iOS 17.4, *) {
            endViewAsync(forAdFormat: adFormat, completion: completion)
        } else {
            HyBidLogger.infoLog(fromClass: String(describing: HyBidAppImpressionWrapper.self),
                              fromMethod: #function,
                              withMessage: "AdAttributionKit is not available on iOS versions below 17.4")
            completion(false)
        }
    }

    @available(iOS 17.4, *)
    private func endViewAsync(forAdFormat adFormat: String, completion: @escaping @convention(block) (Bool) -> Void) {
        guard let impression = self.impression as? AppImpression else {
            completion(false)
            return
        }

        Task {
            do {
                try await impression.endView()

                if HyBidSDKConfig.sharedConfig.reporting {
                    let reportingEvent = HyBidReportingEvent(with: EventType.AD_ATTRIBUTION_KIT_APP_IMPRESSION_END_VIEW, adFormat: adFormat)
                    HyBid.reportingManager().reportEvent(for: reportingEvent)
                }

                HyBidLogger.infoLog(fromClass: String(describing: HyBidAppImpressionWrapper.self), fromMethod: #function, withMessage: "AdAttribution AppImpression endView was successful.")

                completion(true)
            } catch {
                HyBidLogger.errorLog(fromClass: String(describing: HyBidAppImpressionWrapper.self), fromMethod: #function, withMessage: "AdAttribution AppImpression endView failed with error: \(error)")

                if HyBidSDKConfig.sharedConfig.reporting {
                    let reportingEvent = HyBidReportingEvent(with: EventType.AD_ATTRIBUTION_KIT_APP_IMPRESSION_END_VIEW_ERROR, errorMessage: error.localizedDescription)
                    HyBid.reportingManager().reportEvent(for: reportingEvent)
                }
                completion(false)
            }
        }
    }
}
