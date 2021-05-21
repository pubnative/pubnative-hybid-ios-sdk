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

// In this header, you should import all the public headers of your framework using statements like #import <HyBid/PublicHeader.h>

//Banner module headers
#if __has_include("HyBidLeaderboardAdRequest.h")
    #import <HyBid/HyBidLeaderboardAdRequest.h>
#endif
#if __has_include("HyBidBannerAdRequest.h")
    #import <HyBid/HyBidBannerAdRequest.h>
#endif
#if __has_include("HyBidLeaderboardPresenterFactory.h")
    #import <HyBid/HyBidLeaderboardPresenterFactory.h>
#endif
#if __has_include("HyBidLeaderboardAdView.h")
    #import <HyBid/HyBidLeaderboardAdView.h>
#endif
#if __has_include("HyBidBannerAdView.h")
    #import <HyBid/HyBidBannerAdView.h>
#endif
#if __has_include("HyBidMRectAdRequest.h")
    #import <HyBid/HyBidMRectAdRequest.h>
#endif
#if __has_include("HyBidMRectPresenterFactory.h")
    #import <HyBid/HyBidMRectPresenterFactory.h>
#endif
#if __has_include("HyBidMRectAdView.h")
    #import <HyBid/HyBidMRectAdView.h>
#endif

//Native module headers
#if __has_include("HyBidNativeAdLoader.h")
    #import <HyBid/HyBidNativeAdLoader.h>
#endif
#if __has_include("HyBidNativeAd.h")
    #import <HyBid/HyBidNativeAd.h>
#endif
#if __has_include("HyBidNativeAdRenderer.h")
    #import <HyBid/HyBidNativeAdRenderer.h>
#endif

//FullScreen Module headers
#if __has_include("HyBidInterstitialAdRequest.h")
    #import <HyBid/HyBidInterstitialAdRequest.h>
#endif
#if __has_include("HyBidInterstitialPresenter.h")
    #import <HyBid/HyBidInterstitialPresenter.h>
#endif
#if __has_include("HyBidInterstitialPresenterFactory.h")
    #import <HyBid/HyBidInterstitialPresenterFactory.h>
#endif
#if __has_include("HyBidInterstitialAd.h")
    #import <HyBid/HyBidInterstitialAd.h>
#endif

//Rewarded video Module headers
#if __has_include("HyBidRewardedAd.h")
    #import <HyBid/HyBidRewardedAd.h>
#endif

#import <HyBid/HyBidBannerPresenterFactory.h>
#import <HyBid/HyBidRequestParameter.h>
#import <HyBid/HyBidTargetingModel.h>
#import <HyBid/HyBidAdRequest.h>
#import <HyBid/HyBidMRAIDServiceProvider.h>
#import <HyBid/HyBidMRAIDView.h>
#import <HyBid/HyBidMRAIDServiceDelegate.h>
#import <HyBid/HyBidAdPresenter.h>
#import <HyBid/HyBidAdPresenterFactory.h>
#import <HyBid/HyBidAdCache.h>
#import <HyBid/HyBidHeaderBiddingUtils.h>
#import <HyBid/HyBidPrebidUtils.h>
#import <HyBid/HyBidContentInfoView.h>
#import <HyBid/HyBidUserDataManager.h>
#import <HyBid/HyBidBaseModel.h>
#import <HyBid/HyBidAdModel.h>
#import <HyBid/HyBidDataModel.h>
#import <HyBid/HyBidAd.h>
#import <HyBid/HyBidAdView.h>
#import <HyBid/HyBidSettings.h>
#import <HyBid/HyBidStarRatingView.h>
#import <HyBid/HyBidViewabilityManager.h>
#import <HyBid/HyBidLogger.h>
#import <HyBid/HyBidIntegrationType.h>
#import <HyBid/HyBidAdSize.h>
#import <HyBid/HyBidSignalDataProcessor.h>
#import <HyBid/HyBidOpenRTBDataModel.h>
#import <HyBid/HyBidReportingManager.h>
#import <HyBid/HyBidReporting.h>
#import <HyBid/HyBidReportingEvent.h>

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
+ (void)setInterstitialSkipOffset:(NSInteger)seconds;
+ (void)setInterstitialCloseOnFinish:(BOOL)closeOnFinish;
+ (HyBidReportingManager *)reportingManager;
+ (void)setVideoAudioStatus:(HyBidAudioStatus)audioStatus;

@end
