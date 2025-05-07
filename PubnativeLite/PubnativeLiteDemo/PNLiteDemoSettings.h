//
//  Copyright © 2018 PubNative. All rights reserved.
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
