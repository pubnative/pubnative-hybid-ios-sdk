// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidConstants: NSObject {
    
    @objc public static let HYBID_SDK_NAME = "HyBid"
    @objc public static let HYBID_OMSDK_VERSION = "1.5.4"
    @objc public static let HYBID_SDK_VERSION = "3.7.1"
    @objc public static let SMAATO_SDK_VERSION = "23.0.0"
    @objc public static let HYBID_OMSDK_IDENTIFIER = "Pubnativenet"
    @objc public static let SMAATO_OMSDK_IDENTIFIER = "Smaato"
    @objc public static let SMAATO_OMSDK_VERSION = "1.5.2"
    @objc public static let RENDERING_SUCCESS = "rendering success"
    @objc public static let AD_SESSION_DATA = "ad_session_data"
    @objc public static let PERCENT_VISIBLE = "percentVisible"
    @objc public static let HYBID_DEEPLINK_SCHEME = "vrvdl"
    @objc public static let HYBID_DEEPLINK_PARAM  = "deeplinkUrl"
    @objc public static let HYBID_FALLBACK_PARAM  = "fallbackUrl"
    
    //Rendering Constants
    @objc public static var mraidExpand: Bool = true
    @objc public static var showEndCard: Bool = true
    @objc public static var showCustomEndCard: Bool = false
    @objc public static var customEndCardInputValue: String = ""
    @objc public static var customEndcardDisplay: HyBidCustomEndcardDisplayBehaviour = HyBidCustomEndcardDisplayFallback
    @objc public static var interstitialCloseOnFinish: Bool = false
    @objc public static var rewardedCloseOnFinish: Bool = false
    @objc public static var rewardedHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_REWARDED_HTML_SKIP_OFFSET), isCustom: false)
    @objc public static var rewardedVideoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_REWARDED_VIDEO_MAX_SKIP_OFFSET), isCustom: false)
    @objc public static var interstitialHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    @objc public static var pcInterstitialHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_PC_INTERSTITIAL_SKIP_OFFSET), isCustom: false)
    @objc public static var videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
    @objc public static var pcVideoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_PC_VIDEO_SKIP_OFFSET), isCustom: false)
    @objc public static var interstitialActionBehaviour: HyBidInterstitialActionBehaviour = HB_CREATIVE
    @objc public static var endCardCloseMaxOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_END_CARD_CLOSE_MAX_OFFSET), isCustom: false)
    @objc public static var nativeCloseButtonOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_NATIVE_CLOSE_BUTTON_OFFSET), isCustom: false)
    @objc public static var audioStatus: HyBidAudioStatus = HyBidAudioStatusON
    @objc public static var creativeAutoStorekitEnabled: Bool = false
    @objc public static var sdkAutoStorekitEnabled: Bool = false
    @objc public static var skAdNetworkModelInputValue: NSDictionary = NSDictionary()
    @objc public static var itunesIdValue: String = String()
    @objc public static var customCTAInputValue: String = String()
    @objc public static var customBundleId: String = String()
    @objc public static var iconSizeReducedInputValue: Bool = false
    @objc public static var navigationModeInputValue: String = String()
    @objc public static var landingPageInputValue: Bool = false
    @objc public static var ctaSizeTypeInputValue: String = String()
    @objc public static var ctaLocationTypeInputValue: String = String()
    
    @objc public static func endCardCloseOffset(adExperience: String?) -> HyBidSkipOffset {
        switch adExperience {
        case HyBidAdExperiencePerformanceValue:
            return HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_PC_END_CARD_CLOSE_DELAY), isCustom: false)
        case HyBidAdExperienceBrandValue:
            return HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_BC_END_CARD_CLOSE_DELAY), isCustom: false)
        default:
            return HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_END_CARD_CLOSE_OFFSET), isCustom: false)
        }
        
    }
}
