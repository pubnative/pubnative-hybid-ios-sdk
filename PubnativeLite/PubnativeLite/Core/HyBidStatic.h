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

#import <HyBidStatic/HyBidRequestParameter.h>
#import <HyBidStatic/HyBidTargetingModel.h>
#import <HyBidStatic/HyBidAdRequest.h>
#import <HyBidStatic/HyBidMRAIDServiceProvider.h>
#import <HyBidStatic/HyBidMRAIDView.h>
#import <HyBidStatic/HyBidMRAIDServiceDelegate.h>
#import <HyBidStatic/HyBidLeaderboardAdRequest.h>
#import <HyBidStatic/HyBidBannerAdRequest.h>
#import <HyBidStatic/HyBidMRectAdRequest.h>
#import <HyBidStatic/HyBidInterstitialAdRequest.h>
#import <HyBidStatic/HyBidAdPresenter.h>
#import <HyBidStatic/HyBidInterstitialPresenter.h>
#import <HyBidStatic/HyBidNativeAdLoader.h>
#import <HyBidStatic/HyBidAdPresenterFactory.h>
#import <HyBidStatic/HyBidLeaderboardPresenterFactory.h>
#import <HyBidStatic/HyBidBannerPresenterFactory.h>
#import <HyBidStatic/HyBidMRectPresenterFactory.h>
#import <HyBidStatic/HyBidInterstitialPresenterFactory.h>
#import <HyBidStatic/HyBidAdCache.h>
#import <HyBidStatic/HyBidHeaderBiddingUtils.h>
#import <HyBidStatic/HyBidPrebidUtils.h>
#import <HyBidStatic/HyBidContentInfoView.h>
#import <HyBidStatic/HyBidUserDataManager.h>
#import <HyBidStatic/HyBidBaseModel.h>
#import <HyBidStatic/HyBidAdModel.h>
#import <HyBidStatic/HyBidDataModel.h>
#import <HyBidStatic/HyBidAd.h>
#import <HyBidStatic/HyBidNativeAd.h>
#import <HyBidStatic/HyBidAdView.h>
#import <HyBidStatic/HyBidLeaderboardAdView.h>
#import <HyBidStatic/HyBidBannerAdView.h>
#import <HyBidStatic/HyBidMRectAdView.h>
#import <HyBidStatic/HyBidInterstitialAd.h>
#import <HyBidStatic/HyBidSettings.h>
#import <HyBidStatic/HyBidStarRatingView.h>
#import <HyBidStatic/HyBidNativeAdRenderer.h>
#import <HyBidStatic/HyBidViewabilityManager.h>
#import <HyBidStatic/HyBidLogger.h>
#import <HyBidStatic/HyBidIntegrationType.h>
#import <HyBidStatic/HyBidAdSize.h>
#import <HyBidStatic/HyBidSignalDataProcessor.h>
#import <HyBidStatic/HyBidRewardedAd.h>

typedef void (^HyBidCompletionBlock)(BOOL);

@interface HyBid : NSObject

+ (void)setCoppa:(BOOL)enabled;
+ (void)setTargeting:(HyBidTargetingModel *)targeting;
+ (void)setTestMode:(BOOL)enabled;
+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion;
+ (void)setLocationUpdates:(BOOL)enabled;
+ (void)setLocationTracking:(BOOL)enabled;

@end
