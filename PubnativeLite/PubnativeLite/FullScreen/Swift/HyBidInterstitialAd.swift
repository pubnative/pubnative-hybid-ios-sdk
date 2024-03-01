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

@objc
public protocol HyBidInterstitialAdDelegate: AnyObject {
    func interstitialDidLoad()
    func interstitialDidFailWithError(_ error: Error!)
    func interstitialDidTrackImpression()
    func interstitialDidTrackClick()
    func interstitialDidDismiss()
}

@objc
public class HyBidInterstitialAd: NSObject {
    
    // MARK: - Constants
    let TIME_TO_EXPIRE = 1800.0 //30 Minutes as in seconds
    
    // MARK: - Public properties
    
    @objc public var ad: HyBidAd?
    @objc public var isReady = false
    @objc public var isMediation = false
    @objc public var isAutoCacheOnLoad: Bool {
        set {
            self.interstitialAdRequest?.isAutoCacheOnLoad = newValue
        }
        get {
            if let isAutoCacheOnLoad = self.interstitialAdRequest?.isAutoCacheOnLoad {
                return isAutoCacheOnLoad
            }
            return true
        }
    }
    
    // MARK: - Private properties
    
    private var zoneID: String?
    private var appToken: String?
    private weak var delegate: HyBidInterstitialAdDelegate?
    private var interstitialPresenter: HyBidInterstitialPresenter?
    private var interstitialAdRequest: HyBidInterstitialAdRequest?
    private var videoSkipOffset: HyBidSkipOffset?
    private var htmlSkipOffset: HyBidSkipOffset?
    private var initialLoadTimestamp: TimeInterval?
    private var initialRenderTimestamp: TimeInterval?
    private var loadReportingProperties: [String: Any] = [:]
    private var renderReportingProperties: [String: Any] = [:]
    private var renderErrorReportingProperties: [String: Any] = [:]
    private var sessionReportingProperties: [String: Any] = [:]
    private var closeOnFinish = false
    
    func cleanUp() {
        self.ad = nil
        self.initialLoadTimestamp = -1
        self.initialRenderTimestamp = -1
    }
    
    @objc(initWithDelegate:)
    public convenience init(delegate: HyBidInterstitialAdDelegate) {
        self.init(zoneID: "", andWith: delegate)
    }
    
    @objc(initWithZoneID:andWithDelegate:)
    public convenience init(zoneID: String?, andWith delegate: HyBidInterstitialAdDelegate) {
        self.init(zoneID: zoneID, withAppToken: nil, andWith: delegate)
    }
    
    @objc(initWithZoneID:withAppToken:andWithDelegate:)
    public convenience init(zoneID: String?, withAppToken appToken: String?, andWith delegate: HyBidInterstitialAdDelegate) {
        self.init()
        if !HyBid.isInitialized() {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: "HyBid SDK was not initialized. Please initialize it before creating a HyBidInterstitialAd. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process.")
        }
        self.interstitialAdRequest = HyBidInterstitialAdRequest()
        self.interstitialAdRequest?.openRTBAdType = HyBidOpenRTBAdVideo
        self.zoneID = zoneID
        self.delegate = delegate
        self.appToken = appToken
        self.htmlSkipOffset = HyBidConstants.interstitialHtmlSkipOffset
        self.videoSkipOffset = HyBidConstants.videoSkipOffset
        self.closeOnFinish = HyBidConstants.interstitialCloseOnFinish
    }
    
    @objc
    public func load() {
        cleanUp()
        self.initialLoadTimestamp = Date().timeIntervalSince1970
        if let zoneID = self.zoneID, zoneID.count > 0 {
            self.isReady = false
            self.interstitialAdRequest?.setIntegrationType(self.isMediation ? MEDIATION : STANDALONE, withZoneID: zoneID)
            self.interstitialAdRequest?.requestAd(with: HyBidInterstitialAdRequestWrapper(parent: self), withZoneID: zoneID)
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
            self.interstitialAdRequest?.isUsingOpenRTB = true
            self.interstitialAdRequest?.setIntegrationType(self.isMediation ? MEDIATION : STANDALONE, withZoneID: zoneID)
            
            self.interstitialAdRequest?.requestAd(with: HyBidInterstitialAdRequestWrapper(parent: self), withZoneID: zoneID)
        } else {
            invokeDidFailWithError(error: NSError.hyBidInvalidZoneId())
        }
    }
    
    @objc
    public func prepare() {
        if self.interstitialAdRequest != nil && self.ad != nil {
            self.interstitialAdRequest?.cacheAd(ad)
        }
    }
    
    @objc(setMediationVendor:)
    public func setMediationVendor(with mediationVendor: String) {
        self.interstitialAdRequest?.setMediationVendor(mediationVendor)
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
    
    @objc(prepareVideoTagFrom:)
    public func prepareVideoTag(from url: String) {
        self.cleanUp()
        self.initialLoadTimestamp = Date().timeIntervalSince1970
        self.interstitialAdRequest?.requestVideoTag(from: url, andWith: HyBidInterstitialAdRequestWrapper(parent: self))
    }
    
    @objc(prepareCustomMarkupFrom:)
    public func prepareCustomMarkupFrom(_ markup: String) {
        self.cleanUp()
        self.initialLoadTimestamp = Date().timeIntervalSince1970
        self.interstitialAdRequest?.processCustomMarkup(from: markup, with: HyBidDemoAppPlacementInterstitial, andWith: HyBidInterstitialAdRequestWrapper(parent: self))
    }
    
    func processAdContent(adContent: String) {
        let signalDataProcessor = HyBidSignalDataProcessor()
        signalDataProcessor.delegate = HyBidInterstitialSignalDataProcessorWrapper(parent: self)
        signalDataProcessor.processSignalData(adContent)
    }
    
    func processAdReponse(adReponse: String) {
        let interstitialAdRequest = HyBidInterstitialAdRequest()
        interstitialAdRequest.openRTBAdType = HyBidOpenRTBAdVideo
        interstitialAdRequest.delegate = HyBidInterstitialAdRequestWrapper(parent: self)
        interstitialAdRequest.processResponse(withJSON: adReponse)
    }

    func processExchangeAdReponse(adReponse: String) {
        let interstitialAdRequest = HyBidInterstitialAdRequest()
        interstitialAdRequest.isUsingOpenRTB = true
        interstitialAdRequest.openRTBAdType = HyBidOpenRTBAdVideo
        interstitialAdRequest.delegate = HyBidInterstitialAdRequestWrapper(parent: self)
        interstitialAdRequest.processResponse(withJSON: adReponse)
    }
    
    @objc
    public func show() {
        if self.isReady {
            self.initialRenderTimestamp = Date().timeIntervalSince1970
            let initialLoadTimestamp = (self.initialLoadTimestamp ?? 0.0)
            let adExpireTime = initialLoadTimestamp + TIME_TO_EXPIRE
            if let zoneID = self.zoneID{
                HyBidSessionManager.sharedInstance.sessionDuration(zoneID: zoneID)
            }
            if initialLoadTimestamp < adExpireTime {
                self.interstitialPresenter?.show()
            } else {
                HyBidLogger.errorLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: "Ad has expired")
                self.cleanUp()
                self.invokeDidFailWithError(error: NSError.hyBidExpiredAd())
            }
            
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: "Can't display ad. Interstitial is not ready.")
        }
    }
    
    @objc(showFromViewController:)
    public func show(from viewController: UIViewController) {
        if self.isReady {
            self.initialRenderTimestamp = Date().timeIntervalSince1970
            let initialLoadTimestamp = (self.initialLoadTimestamp ?? 0.0)
            let adExpireTime = initialLoadTimestamp + TIME_TO_EXPIRE
            if let zoneID = self.zoneID{
                HyBidSessionManager.sharedInstance.sessionDuration(zoneID: zoneID)
            }
            if initialLoadTimestamp < adExpireTime {
                self.interstitialPresenter?.show(from: viewController)
            } else {
                HyBidLogger.errorLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: "Ad has expired")
                self.cleanUp()
                self.invokeDidFailWithError(error: NSError.hyBidExpiredAd())
            }
            
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: "Can't display ad. Interstitial is not ready.")
        }
    }
    
    func hide(from viewController: UIViewController) {
        self.interstitialPresenter?.hide(from: viewController)
    }
    
    func renderAd(ad: HyBidAd) {
        if let hasEndCard = self.ad?.hasEndCard, !hasEndCard, !(videoSkipOffset?.isCustom ?? false), let hasCustomEndCard = self.ad?.hasCustomEndCard, !hasCustomEndCard {
            self.videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD), isCustom: false)
        }
        let interstitalPresenterFactory = HyBidInterstitialPresenterFactory()
        let videoSkipOffset = self.videoSkipOffset?.offset?.intValue ?? 0
        let htmlSkipOffset = self.htmlSkipOffset?.offset?.intValue ?? 0
        var defaultVideoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
        let defaultHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_HTML_SKIP_OFFSET), isCustom: false)

        if videoSkipOffset >= 0 && htmlSkipOffset >= 0 {
            if htmlSkipOffset >= HyBidSkipOffset.DEFAULT_INTERSTITIAL_HTML_MAX_SKIP_OFFSET {
                self.interstitialPresenter = interstitalPresenterFactory.createInterstitalPresenter(with: ad, withVideoSkipOffset: UInt(videoSkipOffset), withHTMLSkipOffset: UInt(HyBidSkipOffset.DEFAULT_INTERSTITIAL_HTML_MAX_SKIP_OFFSET), withCloseOnFinish: self.closeOnFinish, with: HyBidInterstitialPresenterWrapper(parent: self))
            } else {
                self.interstitialPresenter = interstitalPresenterFactory.createInterstitalPresenter(with: ad, withVideoSkipOffset: UInt(videoSkipOffset), withHTMLSkipOffset: UInt(htmlSkipOffset), withCloseOnFinish: self.closeOnFinish, with: HyBidInterstitialPresenterWrapper(parent: self))
            }
        } else if videoSkipOffset < 0 && htmlSkipOffset < 0 {
            let isEndCardOrCustomEndCard = self.ad?.hasEndCard ?? false || self.ad?.hasCustomEndCard ?? false
            let offsetValue = isEndCardOrCustomEndCard && HyBidConstants.showEndCard
                ? HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
                : HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD), isCustom: true)
            
            
            defaultVideoSkipOffset = offsetValue
            HyBidConstants.videoSkipOffset = HyBidSkipOffset(offset: (defaultVideoSkipOffset.offset?.intValue ?? 0) as NSNumber, isCustom: false)
            self.interstitialPresenter = interstitalPresenterFactory.createInterstitalPresenter(with: ad, withVideoSkipOffset: UInt(defaultVideoSkipOffset.offset?.intValue ?? 0), withHTMLSkipOffset: UInt(defaultHtmlSkipOffset.offset?.intValue ?? 0), withCloseOnFinish: self.closeOnFinish, with: HyBidInterstitialPresenterWrapper(parent: self))
        } else if htmlSkipOffset < 0 {
            self.interstitialPresenter = interstitalPresenterFactory.createInterstitalPresenter(with: ad, withVideoSkipOffset: UInt(videoSkipOffset), withHTMLSkipOffset: UInt(defaultHtmlSkipOffset.offset?.intValue ?? 0), withCloseOnFinish: self.closeOnFinish, with: HyBidInterstitialPresenterWrapper(parent: self))
        } else if videoSkipOffset < 0{
            let isEndCardOrCustomEndCard = self.ad?.hasEndCard ?? false || self.ad?.hasCustomEndCard ?? false
            let offsetValue = isEndCardOrCustomEndCard && HyBidConstants.showEndCard
                ? HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
                : HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD), isCustom: true)
            
            defaultVideoSkipOffset = offsetValue
            HyBidConstants.videoSkipOffset = HyBidSkipOffset(offset: (defaultVideoSkipOffset.offset?.intValue ?? 0) as NSNumber, isCustom: false)
            self.interstitialPresenter = interstitalPresenterFactory.createInterstitalPresenter(with: ad, withVideoSkipOffset: UInt(defaultVideoSkipOffset.offset?.intValue ?? 0), withHTMLSkipOffset: UInt(htmlSkipOffset), withCloseOnFinish: self.closeOnFinish, with: HyBidInterstitialPresenterWrapper(parent: self))
        }
        
        if (self.interstitialPresenter == nil) {
            HyBidLogger.errorLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: "Could not create valid interstitial presenter.")
            
            self.invokeDidFailWithError(error: NSError.hyBidUnsupportedAsset())
            
            self.renderErrorReportingProperties[Common.ERROR_MESSAGE] = NSError.hyBidUnsupportedAsset().localizedDescription
            self.renderErrorReportingProperties[Common.ERROR_CODE] = String(format: "%ld", NSError.hyBidUnsupportedAsset().code)
            self.renderReportingProperties.update(other: HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.interstitialAdRequest))
            self.reportEvent(EventType.RENDER_ERROR, properties: self.renderReportingProperties)
            return
        } else {
            self.interstitialPresenter?.load()
        }
    }
    
    func addSessionReportingProperties() -> [String:Any] {
        var sessionReportingDictionaryToAppend = [String:Any]()
        if !HyBidSessionManager.sharedInstance.impressionCounter.isEmpty {
            sessionReportingDictionaryToAppend[Common.IMPRESSION_SESSION_COUNT] = HyBidSessionManager.sharedInstance.impressionCounter
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
        let reportingEvent = HyBidReportingEvent(with: eventType, adFormat: AdFormat.FULLSCREEN, properties: properties)
        HyBid.reportingManager().reportEvent(for: reportingEvent)
    }
    
    func elapsedTimeSince(_ timestamp: TimeInterval) -> TimeInterval {
        return Date().timeIntervalSince1970 - timestamp
    }
    
    func invokeDidLoad() {
        if let initialLoadTimestamp = self.initialLoadTimestamp, initialLoadTimestamp != -1 {
            self.loadReportingProperties[Common.TIME_TO_LOAD] = String(format: "%f", elapsedTimeSince(initialLoadTimestamp))
        }
        
        self.loadReportingProperties[Common.HAS_END_CARD] = self.ad?.hasEndCard
        self.loadReportingProperties = HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.interstitialAdRequest)
        self.reportEvent(EventType.LOAD, properties: self.loadReportingProperties)
        guard let delegate = self.delegate else { return }
        delegate.interstitialDidLoad()
    }
    
    func invokeDidFailWithError(error: Error) {
        if let initialLoadTimestamp = self.initialLoadTimestamp, initialLoadTimestamp != -1 {
            self.loadReportingProperties[Common.TIME_TO_LOAD] = String(format: "%f", elapsedTimeSince(initialLoadTimestamp))
        }
        self.loadReportingProperties = HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.interstitialAdRequest)
        self.reportEvent(EventType.LOAD_FAIL, properties: self.loadReportingProperties)
        HyBidLogger.errorLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: error.localizedDescription)
        
        if let delegate = delegate {
            delegate.interstitialDidFailWithError(error)
        }
    }
    
    func invokeDidTrackImpression() {
        guard let delegate = self.delegate else { return }
        delegate.interstitialDidTrackImpression()
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
        delegate.interstitialDidTrackClick()
    }
    
    func invokeDidDismiss() {
        guard let delegate = self.delegate else { return }
        delegate.interstitialDidDismiss()
    }
    
    func determineSkipOffsetValuesFor(_ ad: HyBidAd) {
        if ad.interstitialHtmlSkipOffset != nil {
            self.htmlSkipOffset = HyBidSkipOffset(offset: ad.interstitialHtmlSkipOffset, isCustom: true)
        }
        if ad.videoSkipOffset != nil {
            self.videoSkipOffset = HyBidSkipOffset(offset: ad.videoSkipOffset, isCustom: true)
        }
    }
    
    func determineCloseOnFinishFor(_ ad: HyBidAd) {
        if (ad.closeInterstitialAfterFinish != nil) {
            self.closeOnFinish = ad.closeInterstitialAfterFinish.boolValue;
        }
    }
}

// MARK: - HyBidAdRequestDelegate

extension HyBidInterstitialAd {
    func requestDidStart(_ request: HyBidAdRequest) {
        let message = "Ad Request \(String(describing: request)) started"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: message)
        
        if HyBidSDKConfig.sharedConfig.test == true {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: "You are using Verve HyBid SDK on test mode. Please disabled test mode before submitting your application for production.")
        }
    }
    
    func request(_ request: HyBidAdRequest, didLoadWithAd ad: HyBidAd?) {
        let message = "Ad Request \(String(describing: request)) loaded with ad \(String(describing: ad))"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidInterstitialAd.self), fromMethod: #function, withMessage: message)
        
        if let ad = ad {
            self.ad = ad
            self.determineSkipOffsetValuesFor(ad)
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

// MARK: - HyBidInterstitialPresenterDelegate

extension HyBidInterstitialAd {
    func interstitialPresenterDidLoad(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        self.isReady = true
        self.invokeDidLoad()
    }
    
    func interstitialPresenter(_ interstitialPresenter: HyBidInterstitialPresenter!, didFailWithError error: Error!) {
        self.invokeDidFailWithError(error: error)
    }
    
    func interstitialPresenterDidShow(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        if let initialRenderTimestamp = self.initialRenderTimestamp, initialRenderTimestamp
            != -1 {
            self.loadReportingProperties[Common.RENDER_TIME] = String(format: "%f",
                                                                      elapsedTimeSince(initialRenderTimestamp))
        }
        self.renderReportingProperties = HyBid.reportingManager().addCommonProperties(forAd: self.ad, withRequest: self.interstitialAdRequest)
        self.sessionReportingProperties = self.addSessionReportingProperties()
        self.reportEvent(EventType.RENDER, properties: self.renderReportingProperties)
        self.reportEvent(EventType.SESSION_REPORT_INFO, properties: self.sessionReportingProperties)
        self.invokeDidTrackImpression()
    }
    
    func interstitialPresenterDidClick(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        self.invokeDidTrackClick()
    }
    
    func interstitialPresenterDidDismiss(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        self.invokeDidDismiss()
        if #available(iOS 14.5, *) {
            HyBidAdImpression.sharedInstance().end(for: self.ad)
        }
    }
    
    func interstitialPresenterDidFinish(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        
    }
    
}

// MARK: - HyBidSignalDataProcessorDelegate

extension HyBidInterstitialAd {
    func signalDataDidFinish(with ad: HyBidAd) {
        self.ad = ad
        self.renderAd(ad: ad)
    }
    
    func signalDataDidFailWithError(_ error: Error) {
        invokeDidFailWithError(error: error)
    }
}
