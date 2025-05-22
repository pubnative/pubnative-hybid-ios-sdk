// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <HyBid/HyBid.h>

#define kHyBidDemoAppTokenKey @"appToken"
#define kHyBidDemoZoneIDKey @"zoneID"
#define kHyBidDemoKeywordsKey @"keywords"
#define kHyBidDemoTestModeKey @"testMode"
#define kHyBidDemoPublisherModeKey @"publisherMode"
#define kHyBidDemoCOPPAModeKey @"coppaMode"
#define kHyBidDemoReportingKey @"reporting"
#define kHyBidGAMLeaderboardAdUnitIDKey @"gamLeaderboardAdUnitID"
#define kHyBidGAMBannerAdUnitIDKey @"gamBannerAdUnitID"
#define kHyBidGAMMRectAdUnitIDKey @"gamMRectAdUnitID"
#define kHyBidGAMInterstitialAdUnitIDKey @"gamInterstitialAdUnitID"
#define kHyBidGADAppIDKey @"gadAppID"
#define kHyBidGADNativeAdUnitIDKey @"gadNativeAdUnitID"
#define kHyBidGADBannerAdUnitIDKey @"gadBannerAdUnitID"
#define kHyBidGADMRectAdUnitIDKey @"gadMRectAdUnitID"
#define kHyBidGADLeaderboardAdUnitIDKey @"gadLeaderboardAdUnitID"
#define kHyBidGADInterstitialAdUnitIDKey @"gadInterstitialAdUnitID"
#define kHyBidGADRewardedAdUnitIDKey @"gadRewardedAdUnitID"
#define kHyBidDemoAPIURLKey @"apiURL"
#define kHyBidDemoOpenRTBAPIURLKey @"openRtbApiURL"
#define kHyBidDemoAppID @"1530210244"
#define kHyBidISAppIDKey @"ironsourceAppID"
#define kHyBidISBannerAdUnitIdKey @"ironsourceBannerAdUnitID"
#define kHyBidISInterstitialAdUnitIdKey @"ironsourceInterstitialAdUnitID"
#define kHyBidISRewardedAdUnitIdKey @"ironsourceRewardedAdUnitID"
#define kHyBidALMediationNativeAdUnitIDKey @"alMediationNativeAdUnitID"
#define kHyBidALMediationBannerAdUnitIDKey @"alMediationBannerAdUnitID"
#define kHyBidALMediationMRectAdUnitIDKey @"alMediationMRectAdUnitID"
#define kHyBidALMediationInterstitialAdUnitIDKey @"alMediationInterstitialAdUnitID"
#define kHyBidALMediationRewardedAdUnitIDKey @"alMediationRewardedAdUnitID"
#define kHyBidChartboostAppIDKey @"chartboostAppID"
#define kHyBidChartboostAppSignatureKey @"chartboostAppSignature"
#define kHyBidChartboostBannerPositionKey @"bannerPosition"
#define kHyBidChartboostMRectHTMLPositionKey @"mRectHTMLPosition"
#define kHyBidChartboostMRectVideoPositionKey @"mRectVideoPosition"
#define kHyBidChartboostInterstitialHTMLPositionKey @"interstitialHTMLPosition"
#define kHyBidChartboostInterstitialVideoPositionKey @"interstitialVideoPosition"
#define kHyBidChartboostRewardedHTMLPositionKey @"rewardedHTMLPosition"
#define kHyBidChartboostRewardedVideoPositionKey @"rewardedVideoPosition"

#define kHyBidSDKConfigAlertTitle @"Choose SDK Config URL to use"
#define kHyBidSDKConfigAlertTextFieldPlaceholder @"SDK Config URL for Testing"
#define kHyBidSDKConfigAlertActionTitleForTesting @"Testing URL"
#define kHyBidSDKConfigAlertActionTitleForProduction @"Production URL"

@interface PNLiteDemoSettings : NSObject

@property (nonatomic, strong) HyBidTargetingModel *targetingModel;
@property (nonatomic, strong) HyBidAdSize *adSize;
@property (nonatomic, strong) NSMutableArray *bannerSizesArray;
@property (nonatomic, strong) NSString *sdkConfigAlertMessage;
@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *sdkConfigAlertAttributes;
@property (nonatomic, strong) NSString *publisherModeAlertMessage;
@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *publisherModeAlertAttributes;

+ (PNLiteDemoSettings *)sharedInstance;

@end
