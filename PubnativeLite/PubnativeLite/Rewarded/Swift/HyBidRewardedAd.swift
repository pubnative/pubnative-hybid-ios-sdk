//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

@objc
public protocol HyBidRewardedAdDelegate: AnyObject {
    func rewardedDidLoad()
    func rewardedDidFailWithError(_ error: Error!)
    func rewardedDidTrackImpression()
    func rewardedDidTrackClick()
    func rewardedDidDismiss()
    func onReward()
}

@objc
public class HyBidRewardedAd: NSObject {
    
    // MARK: - Constants
    let TIME_TO_EXPIRE = 1800.0 //30 Minutes as in seconds
    
    // MARK: - Public properties
    
    @objc public var ad: HyBidAd?
    @objc public var isReady = false
    @objc public var isMediation = false
    @objc public var isAutoCacheOnLoad: Bool {
        set {
            self.rewardedAdRequest?.isAutoCacheOnLoad = newValue
        }
        get {
            if let isAutoCacheOnLoad = self.rewardedAdRequest?.isAutoCacheOnLoad {
                return isAutoCacheOnLoad
            }
            return true
        }
    }
    
    // MARK: - Private properties
    
    private var zoneID: String?
    private var appToken: String?
    private weak var delegate: HyBidRewardedAdDelegate?
    private var rewardedPresenter: HyBidRewardedPresenter?
    private var rewardedAdRequest: HyBidRewardedAdRequest?
    private var htmlSkipOffset: HyBidSkipOffset?
    private var initialLoadTimestamp: TimeInterval?
    private var initialRenderTimestamp: TimeInterval?
    private var loadReportingProperties: [String: String] = [:]
    private var renderReportingProperties: [String: String] = [:]
    private var renderErrorReportingProperties: [String: String] = [:]
    private var sessionReportingProperties: [String: Any] = [:]
    private var closeOnFinish = false
    
    func cleanUp() {
        self.ad = nil
        self.initialLoadTimestamp = -1
        self.initialRenderTimestamp = -1
    }
    
    @objc(initWithDelegate:)
    public convenience init(delegate: HyBidRewardedAdDelegate) {
        self.init(zoneID: "", andWith: delegate)
    }
    
    @objc(initWithZoneID:andWithDelegate:)
    public convenience init(zoneID: String?, andWith delegate: HyBidRewardedAdDelegate) {
        self.init(zoneID: zoneID, withAppToken: nil, andWith: delegate)
    }
    
    @objc(initWithZoneID:withAppToken:andWithDelegate:)
    public convenience init(zoneID: String?, withAppToken appToken: String?, andWith delegate: HyBidRewardedAdDelegate) {
        self.init()
        if !HyBid.isInitialized() {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: "HyBid SDK was not initialized. Please initialize it before creating a HyBidRewardedAd. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process.")
        }
        self.rewardedAdRequest = HyBidRewardedAdRequest()
        self.rewardedAdRequest?.openRTBAdType = HyBidOpenRTBAdVideo
        self.zoneID = zoneID
        self.appToken = appToken
        self.delegate = delegate
        self.htmlSkipOffset = HyBidConstants.rewardedHtmlSkipOffset
        self.closeOnFinish = HyBidConstants.rewardedCloseOnFinish
    }
    
    @objc
    public func load() {
        cleanUp()
        self.rewardedAdRequest?.isUsingOpenRTB = false
        self.initialLoadTimestamp = Date().timeIntervalSince1970
        if let zoneID = self.zoneID, zoneID.count > 0 {
            self.isReady = false
            self.rewardedAdRequest?.setIntegrationType(self.isMediation ? MEDIATION : STANDALONE, withZoneID: zoneID)
            self.rewardedAdRequest?.requestAd(with: HyBidRewardedAdRequestWrapper(parent: self), withZoneID: zoneID)
        } else {
            invokeDidFailWithError(error: NSError.hyBidInvalidZoneId())
        }
    }
    
    @objc
    public func loadExchangeAd() {
        cleanUp()
        self.initialLoadTimestamp = Date().timeIntervalSince1970
        if let zoneID = self.zoneID, zoneID.count > 0 {
            self.isReady = false
            self.rewardedAdRequest?.isUsingOpenRTB = true
            self.rewardedAdRequest?.setIntegrationType(self.isMediation ? MEDIATION : STANDALONE, withZoneID: zoneID)
            self.rewardedAdRequest?.requestAd(with: HyBidRewardedAdRequestWrapper(parent: self), withZoneID: zoneID)
        } else {
            invokeDidFailWithError(error: NSError.hyBidInvalidZoneId())
        }
    }
    
    @objc
    public func setOpenRTBAdType(adFormat: HyBidOpenRTBAdType) {
        self.rewardedAdRequest?.openRTBAdType = adFormat
    }
    
    @objc
    public func prepare() {
        if self.rewardedAdRequest != nil && self.ad != nil {
            self.rewardedAdRequest?.cacheAd(self.ad)
        }
    }
    
    @objc(setMediationVendor:)
    public func setMediationVendor(with mediationVendor: String) {
        if self.rewardedAdRequest != nil {
            self.rewardedAdRequest?.setMediationVendor(mediationVendor)
        }
    }
    
    @objc(prepareCustomMarkupFrom:)
    public func prepareCustomMarkupFrom(_ markup: String) {
        self.cleanUp()
        self.initialLoadTimestamp = Date().timeIntervalSince1970
        self.rewardedAdRequest?.processCustomMarkup(from: markup, with: HyBidDemoAppPlacementRewarded, andWith: HyBidRewardedAdRequestWrapper(parent: self))
    }
    
    @objc(prepareAdWithContent:)
    public func prepareAdWithContent(adContent: String) {
        if adContent.count != 0 {
            self.cleanUp()
            self.initialLoadTimestamp = Date().timeIntervalSince1970
            self.processAdContent(adContent: adContent)
        } else {
            self.invokeDidFailWithError(error: NSError.hyBidInvalidAsset())
        }
    }
    
    @objc(prepareExchangeAdWithAdReponse:)
    public func prepareExchangeAdWithAdReponse(adReponse: String) {
        if adReponse.count != 0 {
            self.cleanUp()
            self.initialLoadTimestamp = Date().timeIntervalSince1970
            self.processExchangeAdReponse(adReponse: adReponse)
        } else {
            self.invokeDidFailWithError(error: NSError.hyBidInvalidAsset())
        }
    }

    @objc(prepareAdWithAdReponse:)
    public func prepareAdWithAdReponse(adReponse: String) {
        if adReponse.count != 0 {
            self.cleanUp()
            self.initialLoadTimestamp = Date().timeIntervalSince1970
            self.processAdReponse(adReponse: adReponse)
        } else {
            self.invokeDidFailWithError(error: NSError.hyBidInvalidAsset())
        }
    }
    
    func processAdContent(adContent: String) {
        let signalDataProcessor = HyBidSignalDataProcessor()
        signalDataProcessor.delegate = HyBidRewardedSignalDataProcessorWrapper(parent: self)
        signalDataProcessor.processSignalData(adContent)
    }
    
    func processAdReponse(adReponse: String) {
        let rewardedAdRequest = HyBidRewardedAdRequest()
        rewardedAdRequest.openRTBAdType = HyBidOpenRTBAdVideo
        rewardedAdRequest.delegate = HyBidRewardedAdRequestWrapper(parent: self)
        rewardedAdRequest.processResponse(withJSON: adReponse)
    }

        func processExchangeAdReponse(adReponse: String) {
        let rewardedAdRequest = HyBidRewardedAdRequest()
        rewardedAdRequest.isUsingOpenRTB = true
        rewardedAdRequest.openRTBAdType = HyBidOpenRTBAdVideo
        rewardedAdRequest.delegate = HyBidRewardedAdRequestWrapper(parent: self)
        rewardedAdRequest.processResponse(withJSON: adReponse)
    }
    
    @objc
    public func show() {
        if self.isReady {
            self.initialRenderTimestamp = Date().timeIntervalSince1970
            let initialLoadTimestamp = (self.initialLoadTimestamp ?? 0.0)
            let adExpireTime = initialLoadTimestamp + TIME_TO_EXPIRE
            if let zoneID = self.zoneID {
                HyBidSessionManager.sharedInstance.sessionDuration(zoneID: zoneID)
            }
            if initialLoadTimestamp < adExpireTime {
                self.rewardedPresenter?.show()
            } else {
                HyBidLogger.errorLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: "Ad has expired")
                self.cleanUp()
                self.invokeDidFailWithError(error: NSError.hyBidExpiredAd())
            }
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: "Can't display ad. Rewarded is not ready.")
        }
    }
    
    @objc(showFromViewController:)
    public func show(from viewController: UIViewController) {
        if self.isReady {
            self.initialRenderTimestamp = Date().timeIntervalSince1970
            let initialLoadTimestamp = (self.initialLoadTimestamp ?? 0.0)
            let adExpireTime = initialLoadTimestamp + TIME_TO_EXPIRE
            if let zoneID = self.zoneID {
                HyBidSessionManager.sharedInstance.sessionDuration(zoneID: zoneID)
            }
            if initialLoadTimestamp < adExpireTime {
                self.rewardedPresenter?.show(from: viewController)
            } else {
                HyBidLogger.errorLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: "Ad has expired")
                self.cleanUp()
                self.invokeDidFailWithError(error: NSError.hyBidExpiredAd())
            }
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: "Can't display ad. Rewarded is not ready.")
        }
    }
    
    func hide(from viewController: UIViewController) {
        self.rewardedPresenter?.hide(from: viewController)
    }
    
    func renderAd(ad: HyBidAd) {
        let rewardedPresenterFactory = HyBidRewardedPresenterFactory()
        if let skipOffset = self.htmlSkipOffset?.offset?.intValue, skipOffset >= 0 {
            if skipOffset >= HyBidSkipOffset.DEFAULT_REWARDED_HTML_MAX_SKIP_OFFSET {
                self.rewardedPresenter = rewardedPresenterFactory.createRewardedPresenter(with: ad, withHTMLSkipOffset: UInt(HyBidSkipOffset.DEFAULT_REWARDED_HTML_MAX_SKIP_OFFSET), withCloseOnFinish: self.closeOnFinish, with: HyBidRewardedPresenterWrapper(parent: self))
            } else {
                self.rewardedPresenter = rewardedPresenterFactory.createRewardedPresenter(with: ad, withHTMLSkipOffset: UInt(skipOffset), withCloseOnFinish: self.closeOnFinish, with: HyBidRewardedPresenterWrapper(parent: self))
            }
        } else {
            let skipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_REWARDED_HTML_SKIP_OFFSET), isCustom: false);
            self.rewardedPresenter = rewardedPresenterFactory.createRewardedPresenter(with: ad, withHTMLSkipOffset: UInt(skipOffset.offset?.intValue ?? 0), withCloseOnFinish: self.closeOnFinish, with: HyBidRewardedPresenterWrapper(parent: self))
        }
        
        if (self.rewardedPresenter == nil) {
            HyBidLogger.errorLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: "Could not create valid rewarded presenter.")
            
            self.invokeDidFailWithError(error: NSError.hyBidUnsupportedAsset())
            
            if HyBidSDKConfig.sharedConfig.reporting {
                self.renderErrorReportingProperties[Common.ERROR_MESSAGE] = NSError.hyBidUnsupportedAsset().localizedDescription
                self.renderErrorReportingProperties[Common.ERROR_CODE] = String(format: "%ld", NSError.hyBidUnsupportedAsset().code)
                self.renderReportingProperties.update(other: HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.rewardedAdRequest))
                self.reportEvent(EventType.RENDER_ERROR, properties: self.renderReportingProperties)
            }
            return
        } else {
            self.rewardedPresenter?.load()
        }
    }
    
    func addSessionReportingProperties() -> [String: Any] {
        var sessionReportingDictionaryToAppend = [String: Any]()
        let impressionCounter = HyBidSessionManager.sharedInstance.safeImpressionCounter
        if !impressionCounter.isEmpty {
            sessionReportingDictionaryToAppend[Common.IMPRESSION_SESSION_COUNT] = impressionCounter
        }
        if let sessionDuration = UserDefaults.standard.string(forKey: Common.SESSION_DURATION), !sessionDuration.isEmpty{
            sessionReportingDictionaryToAppend[Common.SESSION_DURATION] = sessionDuration
        }
        if zoneID != nil {
            sessionReportingDictionaryToAppend[Common.ZONE_ID] = zoneID
        }
        let ageOfApp = HyBidSessionManager.sharedInstance.getAgeOfApp()
        if !ageOfApp.isEmpty {
            sessionReportingDictionaryToAppend[Common.AGE_OF_APP] = ageOfApp
        }
        return sessionReportingDictionaryToAppend
    }
    
    func reportEvent(_ eventType: String, properties: [String: Any]) {
        if HyBidSDKConfig.sharedConfig.reporting == true {
            let reportingEvent = HyBidReportingEvent(with: eventType, adFormat: AdFormat.REWARDED, properties: properties)
            HyBid.reportingManager().reportEvent(for: reportingEvent)
        }
    }
    
    func elapsedTimeSince(_ timestamp: TimeInterval) -> TimeInterval {
        return Date().timeIntervalSince1970 - timestamp
    }
    
    func invokeDidLoad() {
        if HyBidSDKConfig.sharedConfig.reporting {
            if let initialLoadTimestamp = self.initialLoadTimestamp, initialLoadTimestamp != -1 {
                self.loadReportingProperties[Common.TIME_TO_LOAD] = String(format: "%f", elapsedTimeSince(initialLoadTimestamp))
            }
            self.loadReportingProperties = HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.rewardedAdRequest)
            self.reportEvent(EventType.LOAD, properties: self.loadReportingProperties)
        }
        HyBidVASTEventBeaconsManager.shared.reportVASTEvent(type: EventType.LOAD, ad: self.ad)
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidLoad()
    }
    
    func invokeDidFailWithError(error: Error) {
        if HyBidSDKConfig.sharedConfig.reporting {
            if let initialLoadTimestamp = self.initialLoadTimestamp, initialLoadTimestamp != -1 {
                self.loadReportingProperties[Common.TIME_TO_LOAD] = String(format: "%f", elapsedTimeSince(initialLoadTimestamp))
            }
            self.loadReportingProperties = HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.rewardedAdRequest)
            self.reportEvent(EventType.LOAD_FAIL, properties: self.loadReportingProperties)
        }
        let error = error as NSError
        HyBidVASTEventBeaconsManager.shared.reportVASTEvent(type: EventType.LOAD_FAIL, ad: self.ad, errorCode: error.code)
        HyBidLogger.errorLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: error.localizedDescription)
        if let delegate = delegate {
            delegate.rewardedDidFailWithError(error)
        }
    }
    
    func invokeDidTrackImpression() {
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidTrackImpression()
        if #available(iOS 14.5, *) {
            HyBidAdImpression.sharedInstance().start(for: self.ad)
        }
    }
    
    func skAdNetworkModel() -> HyBidSkAdNetworkModel? {
        var result: HyBidSkAdNetworkModel? = nil
        
        if let ad = self.ad {
            result = ad.isUsingOpenRTB
            ? ad.getOpenRTBSkAdNetworkModel()
            : ad.getSkAdNetworkModel()
        }
        return result
    }
    
    func invokeDidTrackClick() {
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidTrackClick()
    }
    
    func invokeOnReward() {
        guard let delegate = self.delegate else { return }
        delegate.onReward()
        if HyBidSDKConfig.sharedConfig.reporting {
            self.reportEvent(EventType.REWARD, properties: [:])
        }
    }
    
    func invokeDidDismiss() {
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidDismiss()
        if #available(iOS 14.5, *) {
            HyBidAdImpression.sharedInstance().end(for: self.ad)
        }
    }
    
    func determineSkipOffsetValuesFor(_ ad: HyBidAd) {
        if ad.rewardedHtmlSkipOffset != nil {
            self.htmlSkipOffset = HyBidSkipOffset(offset: ad.rewardedHtmlSkipOffset, isCustom: true)
        }
    }
    
    func determineCloseOnFinishFor(_ ad: HyBidAd) {
        if (ad.closeRewardedAfterFinish != nil) {
            self.closeOnFinish = ad.closeRewardedAfterFinish.boolValue;
        }
    }
    
}

// MARK: - HyBidAdRequestDelegate

extension HyBidRewardedAd {
    func requestDidStart(_ request: HyBidAdRequest) {
        let message = "Ad Request \(String(describing: request)) started"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: message)
        
        if HyBidSDKConfig.sharedConfig.test == true {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: "You are using Verve HyBid SDK on test mode. Please disabled test mode before submitting your application for production.")
        }
    }
    
    func request(_ request: HyBidAdRequest, didLoadWithAd ad: HyBidAd?) {
        let message = "Ad Request \(String(describing: request)) loaded with ad \(String(describing: ad))"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidRewardedAd.self), fromMethod: #function, withMessage: message)
        
        if let ad = ad {
            self.ad = ad
            self.determineSkipOffsetValuesFor(ad)
            self.ad?.adType = Int(kHyBidAdTypeVideo)
            self.determineCloseOnFinishFor(ad)
            self.renderAd(ad: ad)
        } else {
            self.invokeDidFailWithError(error: NSError.hyBidNullAd())
        }
    }
    
    func request(_ requst: HyBidAdRequest, didFailWithError error: Error) {
        self.invokeDidFailWithError(error: error)
    }
}

// MARK: - HyBidRewardedPresenterDelegate

extension HyBidRewardedAd {
    func rewardedPresenterDidLoad(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.isReady = true
        self.invokeDidLoad()
    }
    
    func rewardedPresenter(_ rewardedPresenter: HyBidRewardedPresenter!, didFailWithError error: Error!) {
        self.invokeDidFailWithError(error: error)
    }
    
    func rewardedPresenterDidShow(_ rewardedPresenter: HyBidRewardedPresenter!) {
        if HyBidSDKConfig.sharedConfig.reporting {
            if let initialRenderTimestamp = self.initialRenderTimestamp, initialRenderTimestamp
                != -1 {
                self.loadReportingProperties[Common.RENDER_TIME] = String(format: "%f",
                                                                          elapsedTimeSince(initialRenderTimestamp))
            }
            self.renderReportingProperties = HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.rewardedAdRequest)
            self.sessionReportingProperties = self.addSessionReportingProperties()
            self.reportEvent(EventType.RENDER, properties: self.renderReportingProperties)
            self.reportEvent(EventType.SESSION_REPORT_INFO, properties: self.sessionReportingProperties)
        }
        self.invokeDidTrackImpression()
    }
    
    func rewardedPresenterDidClick(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.invokeDidTrackClick()
    }
    
    func rewardedPresenterDidDismiss(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.invokeOnReward()
        self.invokeDidDismiss()
    }
    
    func rewardedPresenterDidFinish(_ rewardedPresenter: HyBidRewardedPresenter!) {
        
    }
}

// MARK: - HyBidSignalDataProcessorDelegate
extension HyBidRewardedAd {
    func signalDataDidFinish(with ad: HyBidAd) {
        self.ad = ad
        self.ad?.adType = Int(kHyBidAdTypeVideo)
        self.renderAd(ad: ad)
    }
    
    func signalDataDidFailWithError(_ error: Error) {
        invokeDidFailWithError(error: error)
    }
}
