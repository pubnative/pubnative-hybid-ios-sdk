//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation
import AdAttributionKit

@objc class HyBidAdAttributionCustomClickAdsManager: NSObject {
    private let refreshImpressionMinutesInterval = 15.0
    private var ad: HyBidAd
    private var adFormat: String? = .none
    private var eventAttributionView: Any?
    private var adView: UIView?
    private var impression: Any? {
        didSet { self.refreshAppImpression() }
    }
    
    init(ad: HyBidAd, adFormat: String? = nil) {
        self.ad = ad
        self.adFormat = adFormat
    }

    func startImpression(adView: UIView) {
        guard #available(iOS 17.4, *) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.adView = adView
            let eventAttributionView = UIEventAttributionView(frame: adView.frame)
            self.eventAttributionView = eventAttributionView
            adView.addSubview(eventAttributionView)
            adView.bringSubviewToFront(eventAttributionView)
            eventAttributionView.translatesAutoresizingMaskIntoConstraints = true
            eventAttributionView.center = CGPoint(x: adView.bounds.midX, y: adView.bounds.midY)
            eventAttributionView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth ,.flexibleHeight]

            self.loadImpressionAsync()
        }
    }

    @available(iOS 17.4, *)
    private func loadImpressionAsync() {
        Task {
            self.impression = await HyBidAdAttributionManager.getAppImpression(ad: self.ad, adFormat: self.adFormat, aakAdType: .clickThrough)
        }
    }
    
    func refreshAppImpression() {
        guard #available(iOS 17.4, *) else { return }
        let deadlineTime: DispatchTime = .now() + (self.refreshImpressionMinutesInterval * 60)
        DispatchQueue.global().asyncAfter(deadline: deadlineTime) { [weak self] in
            guard let self else { return }
            self.refreshImpressionAsync()
        }
    }

    @available(iOS 17.4, *)
    private func refreshImpressionAsync() {
        Task {
            self.impression = await HyBidAdAttributionManager.getAppImpression(ad: self.ad, adFormat: self.adFormat, aakAdType: .clickThrough)
        }
    }
    
    @available(iOS 13.0, *)
    func handleTap() async -> Bool {
        guard #available(iOS 17.4, *) else { return false}
        do {
            guard let eventAttributionView = self.eventAttributionView as? UIEventAttributionView else { return false }
            await self.adView?.bringSubviewToFront(eventAttributionView)
            
            guard let impression = self.impression as? AppImpression else { return false }
            
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
