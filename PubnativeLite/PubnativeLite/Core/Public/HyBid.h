// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

//! Project version number for HyBid.
FOUNDATION_EXPORT double HyBidVersionNumber;

//! Project version string for HyBid.
FOUNDATION_EXPORT const unsigned char HyBidVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import "PublicHeader.h"

//Banner module headers
#if __has_include("HyBidLeaderboardAdRequest.h")
    #import "HyBidLeaderboardAdRequest.h"
#endif
#if __has_include("HyBidBannerAdRequest.h")
    #import "HyBidBannerAdRequest.h"
#endif
#if __has_include("HyBidLeaderboardPresenterFactory.h")
    #import "HyBidLeaderboardPresenterFactory.h"
#endif
#if __has_include("HyBidLeaderboardAdView.h")
    #import "HyBidLeaderboardAdView.h"
#endif
#if __has_include("HyBidBannerAdView.h")
    #import "HyBidBannerAdView.h"
#endif
#if __has_include("HyBidMRectAdRequest.h")
    #import "HyBidMRectAdRequest.h"
#endif
#if __has_include("HyBidMRectPresenterFactory.h")
    #import "HyBidMRectPresenterFactory.h"
#endif
#if __has_include("HyBidMRectAdView.h")
    #import "HyBidMRectAdView.h"
#endif

//Native module headers
#if __has_include("HyBidNativeAdLoader.h")
    #import "HyBidNativeAdLoader.h"
#endif
#if __has_include("HyBidNativeAd.h")
    #import "HyBidNativeAd.h"
#endif
#if __has_include("HyBidNativeAdRenderer.h")
    #import "HyBidNativeAdRenderer.h"
#endif

//FullScreen Module headers
#if __has_include("HyBidInterstitialAdRequest.h")
    #import "HyBidInterstitialAdRequest.h"
#endif
#if __has_include("HyBidInterstitialPresenter.h")
    #import "HyBidInterstitialPresenter.h"
#endif
#if __has_include("HyBidInterstitialPresenterFactory.h")
    #import "HyBidInterstitialPresenterFactory.h"
#endif
#if __has_include("HyBidInterstitialAd.h")
    #import "HyBidInterstitialAd.h"
#endif

//Rewarded video Module headers
#if __has_include("HyBidRewardedAdRequest.h")
    #import "HyBidRewardedAdRequest.h"
#endif
#if __has_include("HyBidRewardedPresenter.h")
    #import "HyBidRewardedPresenter.h"
#endif
#if __has_include("HyBidRewardedPresenterFactory.h")
    #import "HyBidRewardedPresenterFactory.h"
#endif
#if __has_include("HyBidRewardedAd.h")
    #import "HyBidRewardedAd.h"
#endif

#import "HyBidBannerPresenterFactory.h"
#import "HyBidRequestParameter.h"
#import "HyBidAdRequest.h"
#import "HyBidMRAIDServiceProvider.h"
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "HyBidAdPresenter.h"
#import "HyBidAdPresenterFactory.h"
#import "HyBidAdCache.h"
#import "HyBidHeaderBiddingUtils.h"
#import "HyBidContentInfoView.h"
#import "HyBidUserDataManager.h"
#import "HyBidBaseModel.h"
#import "HyBidAdModel.h"
#import "HyBidDataModel.h"
#import "HyBidAd.h"
#import "HyBidAdView.h"
#import "HyBidStarRatingView.h"
#import "HyBidViewabilityManager.h"
#import "HyBidIntegrationType.h"
#import "HyBidAdSize.h"
#import "HyBidOpenRTBDataModel.h"
#import "HyBidDiagnosticsManager.h"
#import "HyBidError.h"
#import "HyBidSignalDataProcessor.h"
#import "HyBidAdImpression.h"
#import "HyBidAdSourceConfig.h"
#import "HyBidSkAdNetworkRequestModel.h"
#import "HyBidSKAdNetworkParameter.h"
#import "HyBidWebBrowserUserAgentInfo.h"
#import "HyBidTimerState.h"
#import "HyBidCustomCTAViewDelegate.h"
#import "HyBidSKOverlay.h"
#import "HyBidConfigModel.h"
#import "HyBidConfig.h"
#import "HyBidConfigManager.h"
#import "NSUserDefaults+HyBidCustomMethods.h"
#import "HyBidSKOverlayDelegate.h"
#import "ATOMManager.h"

// For swift compatibility, we are making this file public instead of private
// Avoid using custom module map
#import "PNLiteLocationManager.h"
#import "PNLiteAdRequestModel.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidVASTImpression.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidAdFeedbackViewDelegate.h"

@class HyBidTargetingModel;
@class HyBidReportingManager;
@class HyBidAdAttributionCustomClickAdsWrapper;

typedef NS_ENUM(NSInteger, SDKIntegrationType) {
    SDKIntegrationTypeHyBid = 0,
    SDKIntegrationTypeSmaato = 1
};

typedef enum {
    HyBidAudioStatusMuted,
    HyBidAudioStatusON,
    HyBidAudioStatusDefault
} HyBidAudioStatus;

typedef enum {
    HyBidLogLevelNone,
    HyBidLogLevelError,
    HyBidLogLevelWarning,
    HyBidLogLevelInfo,
    HyBidLogLevelDebug,
} HyBidLogLevel;

typedef enum {
    HB_CREATIVE,
    HB_ACTION_BUTTON
} HyBidInterstitialActionBehaviour;

typedef enum{
    HyBidAdImpressionTrackerRender,
    HyBidAdImpressionTrackerViewable
} HyBidImpressionTrackerMethod;

typedef enum {
    HyBidCustomEndcardDisplayExtention,
    HyBidCustomEndcardDisplayFallback
} HyBidCustomEndcardDisplayBehaviour;

typedef enum {
    HyBidWebBrowserNavigationExternal,
    HyBidWebBrowserNavigationInternal
} HyBidWebBrowserNavigation;

static NSString * const HyBidCustomEndcardDisplayExtentionValue = @"extension";
static NSString * const HyBidCustomEndcardDisplayFallbackValue = @"fallback";
static NSString * const HyBidAdExperiencePerformanceValue = @"performance";
static NSString * const HyBidAdExperienceBrandValue = @"brand";
static NSString * const HyBidWebBrowserNavigationExternalValue = @"external";
static NSString * const HyBidWebBrowserNavigationInternalValue = @"internal";

//PNLiteAssetGroupType
static const unsigned int MRAID_320x50 = 10;
static const unsigned int MRAID_300x50 = 12;
static const unsigned int MRAID_300x250 = 8;
static const unsigned int MRAID_320x480 = 21;
static const unsigned int MRAID_1024x768 = 22;
static const unsigned int MRAID_768x1024 = 23;
static const unsigned int MRAID_728x90 = 24;
static const unsigned int MRAID_160x600 = 25;
static const unsigned int MRAID_250x250 = 26;
static const unsigned int MRAID_300x600 = 27;
static const unsigned int MRAID_320x100 = 28;
static const unsigned int MRAID_480x320 = 29;
static const unsigned int VAST_MRECT = 4;
static const unsigned int VAST_INTERSTITIAL = 15;
static const unsigned int VAST_REWARDED = 15;
static const unsigned int NON_DEFINED = 0;

typedef void (^HyBidCompletionBlock)(BOOL);

@interface HyBid : NSObject

@property (nonatomic, assign) SDKIntegrationType sdkIntegrationType;

+ (void)setCoppa:(BOOL)enabled;
+ (void)setTargeting:(HyBidTargetingModel *)targeting;
+ (void)setTestMode:(BOOL)enabled;
+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion;
+ (void)setLocationUpdates:(BOOL)enabled;
+ (void)setLocationTracking:(BOOL)enabled;
+ (void)setAppStoreAppID:(NSString *)appID DEPRECATED_MSG_ATTRIBUTE("You can safely remove this method from your integration.");
+ (NSString *)sdkVersion;
+ (BOOL)isInitialized;
+ (HyBidReportingManager *)reportingManager;
+ (NSString*)getSDKVersionInfo;
+ (NSString*)getCustomRequestSignalData;
+ (NSString*)getCustomRequestSignalData:(NSString*) mediationVendorName;
+ (NSString*)getEncodedCustomRequestSignalData;
+ (NSString*)getEncodedCustomRequestSignalData:(NSString*) mediationVendorName;
+ (void)setReporting:(BOOL)enabled;
+ (void)rightToBeForgotten;
+ (void)setIntegrationType:(SDKIntegrationType)integrationType;
+ (SDKIntegrationType)getIntegrationType;

@end
