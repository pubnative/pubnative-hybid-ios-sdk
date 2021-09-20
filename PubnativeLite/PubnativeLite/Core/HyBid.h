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
#if __has_include("HyBidRewardedAd.h")
    #import "HyBidRewardedAd.h"
#endif

#import "HyBidBannerPresenterFactory.h"
#import "HyBidRequestParameter.h"
#import "HyBidTargetingModel.h"
#import "HyBidAdRequest.h"
#import "HyBidMRAIDServiceProvider.h"
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "HyBidAdPresenter.h"
#import "HyBidAdPresenterFactory.h"
#import "HyBidAdCache.h"
#import "HyBidHeaderBiddingUtils.h"
#import "HyBidPrebidUtils.h"
#import "HyBidContentInfoView.h"
#import "HyBidUserDataManager.h"
#import "HyBidBaseModel.h"
#import "HyBidAdModel.h"
#import "HyBidDataModel.h"
#import "HyBidAd.h"
#import "HyBidAdView.h"
#import "HyBidSettings.h"
#import "HyBidStarRatingView.h"
#import "HyBidViewabilityManager.h"
#import "HyBidLogger.h"
#import "HyBidIntegrationType.h"
#import "HyBidAdSize.h"
#import "HyBidOpenRTBDataModel.h"
#import "HyBidReportingManager.h"
#import "HyBidReporting.h"
#import "HyBidReportingEvent.h"
#import "HyBidDiagnosticsManager.h"
#import "HyBidError.h"

typedef void (^HyBidCompletionBlock)(BOOL);

@interface HyBid : NSObject

+ (void)setCoppa:(BOOL)enabled;
+ (void)setTargeting:(HyBidTargetingModel *)targeting;
+ (void)setTestMode:(BOOL)enabled;
+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion;
+ (void)setLocationUpdates:(BOOL)enabled;
+ (void)setLocationTracking:(BOOL)enabled;
+ (void)setAppStoreAppID:(NSString *)appID;
+ (NSString *)sdkVersion;
+ (BOOL)isInitialized;
+ (void)setInterstitialSkipOffset:(NSInteger)seconds;
+ (void)setInterstitialCloseOnFinish:(BOOL)closeOnFinish;
+ (HyBidReportingManager *)reportingManager;
+ (void)setVideoAudioStatus:(HyBidAudioStatus)audioStatus;
+ (NSString*)getSDKVersionInfo;
+ (NSString*)getCustomRequestSignalData;

@end
