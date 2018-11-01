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

#import <HyBid/PNLiteRequestParameter.h>
#import <HyBid/PNLiteTargetingModel.h>
#import <HyBid/PNLiteAdRequest.h>
#import <HyBid/PNLiteBrowser.h>
#import <HyBid/PNLiteBrowserControlsView.h>
#import <HyBid/PNLiteMRAIDServiceProvider.h>
#import <HyBid/PNLiteMRAIDView.h>
#import <HyBid/PNLiteMRAIDServiceDelegate.h>
#import <HyBid/PNLiteBannerAdRequest.h>
#import <HyBid/PNLiteMRectAdRequest.h>
#import <HyBid/PNLiteInterstitialAdRequest.h>
#import <HyBid/PNLiteBannerPresenter.h>
#import <HyBid/PNLiteMRectPresenter.h>
#import <HyBid/PNLiteInterstitialPresenter.h>
#import <HyBid/PNLiteNativeAdLoader.h>
#import <HyBid/PNLiteBannerPresenterFactory.h>
#import <HyBid/PNLiteMRectPresenterFactory.h>
#import <HyBid/PNLiteInterstitialPresenterFactory.h>
#import <HyBid/PNLiteAdCache.h>
#import <HyBid/PNLitePrebidUtils.h>
#import <HyBid/PNLiteContentInfoView.h>
#import <HyBid/PNLiteUserDataManager.h>
#import <HyBid/PNLiteBaseModel.h>
#import <HyBid/PNLiteAdModel.h>
#import <HyBid/PNLiteDataModel.h>
#import <HyBid/PNLiteAd.h>
#import <HyBid/PNLiteNativeAd.h>
#import <HyBid/PNLiteAdView.h>
#import <HyBid/PNLiteBannerAdView.h>
#import <HyBid/PNLiteMRectAdView.h>
#import <HyBid/PNLiteInterstitialAd.h>
#import <HyBid/PNLiteSettings.h>
#import <HyBid/PNLiteStarRatingView.h>
#import <HyBid/PNLiteNativeAdRenderer.h>

#import <HyBid/HyBidRequestParameter.h>
#import <HyBid/HyBidTargetingModel.h>
#import <HyBid/HyBidAdRequest.h>
#import <HyBid/HyBidBrowser.h>
#import <HyBid/HyBidBrowserControlsView.h>
#import <HyBid/HyBidMRAIDServiceProvider.h>
#import <HyBid/HyBidMRAIDView.h>
#import <HyBid/HyBidMRAIDServiceDelegate.h>
#import <HyBid/HyBidBannerAdRequest.h>
#import <HyBid/HyBidMRectAdRequest.h>
#import <HyBid/HyBidInterstitialAdRequest.h>
#import <HyBid/HyBidLeaderboardPresenter.h>
#import <HyBid/HyBidBannerPresenter.h>
#import <HyBid/HyBidMRectPresenter.h>
#import <HyBid/HyBidInterstitialPresenter.h>
#import <HyBid/HyBidNativeAdLoader.h>
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
#import <HyBid/HyBidBannerAdView.h>
#import <HyBid/HyBidMRectAdView.h>
#import <HyBid/HyBidInterstitialAd.h>
#import <HyBid/HyBidSettings.h>
#import <HyBid/HyBidStarRatingView.h>
#import <HyBid/HyBidNativeAdRenderer.h>

typedef void (^HyBidCompletionBlock)(BOOL);

@interface HyBid : NSObject

+ (void)setCoppa:(BOOL)enabled;
+ (void)setTargeting:(HyBidTargetingModel *)targeting;
+ (void)setTestMode:(BOOL)enabled;
+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion;

@end
