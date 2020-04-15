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

#import <HyBid/HyBidRequestParameter.h>
#import <HyBid/HyBidTargetingModel.h>
#import <HyBid/HyBidAdRequest.h>
#import <HyBid/HyBidMRAIDServiceProvider.h>
#import <HyBid/HyBidMRAIDView.h>
#import <HyBid/HyBidMRAIDServiceDelegate.h>
#import <HyBid/HyBidLeaderboardAdRequest.h>
#import <HyBid/HyBidBannerAdRequest.h>
#import <HyBid/HyBidMRectAdRequest.h>
#import <HyBid/HyBidInterstitialAdRequest.h>
#import <HyBid/HyBidAdPresenter.h>
#import <HyBid/HyBidInterstitialPresenter.h>
#import <HyBid/HyBidNativeAdLoader.h>
#import <HyBid/HyBidAdPresenterFactory.h>
#import <HyBid/HyBidLeaderboardPresenterFactory.h>
#import <HyBid/HyBidBannerPresenterFactory.h>
#import <HyBid/HyBidMRectPresenterFactory.h>
#import <HyBid/HyBidInterstitialPresenterFactory.h>
#import <HyBid/HyBidAdCache.h>
#import <HyBid/HyBidPrebidUtils.h>
#import <HyBid/HyBidContentInfoView.h>
#import <HyBid/HyBidUserDataManager.h>
#import <HyBid/HyBidBaseModel.h>
#import <HyBid/HyBidAdModel.h>
#import <HyBid/HyBidDataModel.h>
#import <HyBid/HyBidAd.h>
#import <HyBid/HyBidNativeAd.h>
#import <HyBid/HyBidAdView.h>
#import <HyBid/HyBidLeaderboardAdView.h>
#import <HyBid/HyBidBannerAdView.h>
#import <HyBid/HyBidMRectAdView.h>
#import <HyBid/HyBidInterstitialAd.h>
#import <HyBid/HyBidSettings.h>
#import <HyBid/HyBidStarRatingView.h>
#import <HyBid/HyBidNativeAdRenderer.h>
#import <HyBid/HyBidViewabilityManager.h>
#import <HyBid/HyBidLogger.h>
#import <HyBid/HyBidIntegrationType.h>
#import <HyBid/HyBidAdSize.h>
#import <HyBid/VWAdvertView.h>
#import <HyBid/VWAdRequest.h>
#import <HyBid/VWContentCategory.h>
#import <HyBid/VWAdSize.h>
#import <HyBid/VWInterstitialAd.h>

typedef void (^HyBidCompletionBlock)(BOOL);

@interface HyBid : NSObject

+ (void)setCoppa:(BOOL)enabled;
+ (void)setTargeting:(HyBidTargetingModel *)targeting;
+ (void)setTestMode:(BOOL)enabled;
+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion;
+ (void)initWithAppToken:(NSString *)appToken withPartnerKeyword:(NSString*) partnerKeyword completion:(HyBidCompletionBlock)completion;
+ (void)reconfigure:(NSString *)appToken withPartnerKeyword:(NSString*) partnerKeyword completion:(HyBidCompletionBlock)completion;
@end
