//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation
import AdAttributionKit

@objc public class HyBidAdAttributionCustomClickAdsWrapper: NSObject {
    
    private var adManager : Any?
    private var isAdUsingCustomMarketplace = false
    
    @objc public init(ad: HyBidAd, adFormat: String? = nil) {
        guard #available(iOS 17.4, *) else { return }
        self.adManager = HyBidAdAttributionCustomClickAdsManager(ad: ad, adFormat: adFormat)
        
        guard let aakModel = ad.isUsingOpenRTB ? ad.getOpenRTBAdAttributionModel() : ad.getAttributionModel(),
              let productParameters = aakModel.productParameters,
              let customMarketPlaceParameter = productParameters[HyBidAdAttributionParameter.custom_market_place],
              let customMarketPlaceValue = customMarketPlaceParameter as? Bool else { return }
        
        self.isAdUsingCustomMarketplace = customMarketPlaceValue
    }
    
    @objc public func startImpression(adView: UIView?) {
        
        guard #available(iOS 17.4, *), self.isAdUsingCustomMarketplace,
              let adManager = self.adManager as? HyBidAdAttributionCustomClickAdsManager,
              let adView = adView else { return }
        adManager.startImpression(adView: adView)
    }
    
    @objc public func adHasCustomMarketPlace() -> Bool {
        return self.isAdUsingCustomMarketplace
    }
    
    @objc public func handlingCustomMarketPlace(completion: @escaping(Bool) -> Void) {
        
        guard #available(iOS 17.4, *), self.isAdUsingCustomMarketplace,
              let adManager = self.adManager as? HyBidAdAttributionCustomClickAdsManager else { return completion(false) }
        Task {
            completion(await adManager.handleTap())
        }
    }
}

@available(iOS 17.4, *)
fileprivate class HyBidAdAttributionCustomClickAdsManager {
    
    private let refreshImpressionMinutesInterval = 15.0
    private var ad: HyBidAd
    private var adFormat: String? = .none
    private var eventAttributionView: UIEventAttributionView?
    private var adView: UIView?
    private var impresion: AppImpression? {
        didSet { self.refreshAppImpression() }
    }
    
    fileprivate init(ad: HyBidAd, adFormat: String? = nil) {
        self.ad = ad
        self.adFormat = adFormat
    }
    
    fileprivate func startImpression(adView: UIView) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.adView = adView
            self.eventAttributionView = UIEventAttributionView(frame: adView.frame)
            guard let eventAttributionView = self.eventAttributionView else { return }
            adView.addSubview(eventAttributionView)
            adView.bringSubviewToFront(eventAttributionView)
            eventAttributionView.translatesAutoresizingMaskIntoConstraints = true
            eventAttributionView.center = CGPoint(x: adView.bounds.midX, y: adView.bounds.midY)
            eventAttributionView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth ,.flexibleHeight]
            
            Task { self.impresion = await HyBidAdAttributionManager.getAppImpression(ad: self.ad, adFormat: self.adFormat, aakAdType: .clickThrough) }
        }
    }
    
    private func refreshAppImpression() {
        let deadlineTime: DispatchTime = .now() + (self.refreshImpressionMinutesInterval * 60)
        DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
            Task { self.impresion = await HyBidAdAttributionManager.getAppImpression(ad: self.ad, adFormat: self.adFormat, aakAdType: .clickThrough) }
        }
    }
    
    fileprivate func handleTap() async -> Bool {
        do {
            guard let eventAttributionView = self.eventAttributionView else { return false }
            await self.adView?.bringSubviewToFront(eventAttributionView)
            
            guard let impression = self.impresion else { return false }
            
            if #available(iOS 18.0, *), let reengagementURL = await HyBidAdAttributionManager.getReengagementURL(ad: ad) {
                try await impression.handleTap(reengagementURL: reengagementURL)
            } else {
                try await impression.handleTap()
            }
            
            if HyBidSDKConfig.sharedConfig.reporting {
                let reportingEvent = HyBidReportingEvent(with: EventType.AD_ATTRIBUTION_KIT_APP_HANDLE_TAP, adFormat: AdFormat.NATIVE)
                HyBid.reportingManager().reportEvent(for: reportingEvent)
            }
            return true
        } catch {
            HyBidLogger.errorLog(fromClass: String(describing: HyBidAdAttributionCustomClickAdsManager.self), fromMethod: #function, withMessage: "AdAttribution handleTap error: \(error)")
            if HyBidSDKConfig.sharedConfig.reporting {
                let properties: [String: Any] = [Common.ERROR_MESSAGE: error.localizedDescription,
                                                 Common.ERROR_CODE: (error as NSError).code]
                let reportingEvent = HyBidReportingEvent(with: EventType.AD_ATTRIBUTION_KIT_APP_HANDLE_TAP_ERROR, errorMessage: error.localizedDescription, properties: properties)
                HyBid.reportingManager().reportEvent(for: reportingEvent)
            }
            return false
        }
    }
}
