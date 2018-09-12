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

//! Project version number for PubnativeLite.
FOUNDATION_EXPORT double PubnativeLiteVersionNumber;

//! Project version string for PubnativeLite.
FOUNDATION_EXPORT const unsigned char PubnativeLiteVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PubnativeLite/PublicHeader.h>

#import <PubnativeLite/PNLiteRequestParameter.h>
#import <PubnativeLite/PNLiteTargetingModel.h>
#import <PubnativeLite/PNLiteAdRequest.h>
#import <PubnativeLite/PNLiteBrowser.h>
#import <PubnativeLite/PNLiteBrowserControlsView.h>
#import <PubnativeLite/PNLiteMRAIDServiceProvider.h>
#import <PubnativeLite/PNLiteMRAIDView.h>
#import <PubnativeLite/PNLiteMRAIDServiceDelegate.h>
#import <PubnativeLite/PNLiteBannerAdRequest.h>
#import <PubnativeLite/PNLiteMRectAdRequest.h>
#import <PubnativeLite/PNLiteInterstitialAdRequest.h>
#import <PubnativeLite/PNLiteBannerPresenter.h>
#import <PubnativeLite/PNLiteMRectPresenter.h>
#import <PubnativeLite/PNLiteInterstitialPresenter.h>
#import <PubnativeLite/PNLiteNativeAdLoader.h>
#import <PubnativeLite/PNLiteBannerPresenterFactory.h>
#import <PubnativeLite/PNLiteMRectPresenterFactory.h>
#import <PubnativeLite/PNLiteInterstitialPresenterFactory.h>
#import <PubnativeLite/PNLiteAdCache.h>
#import <PubnativeLite/PNLitePrebidUtils.h>
#import <PubnativeLite/PNLiteContentInfoView.h>
#import <PubnativeLite/PNLiteUserDataManager.h>
#import <PubnativeLite/PNLiteAdModel.h>
#import <PubnativeLite/PNLiteDataModel.h>
#import <PubnativeLite/PNLiteAd.h>
#import <PubnativeLite/PNLiteNativeAd.h>
#import <PubnativeLite/PNLiteAdView.h>
#import <PubnativeLite/PNLiteBannerAdView.h>
#import <PubnativeLite/PNLiteMRectAdView.h>
#import <PubnativeLite/PNLiteInterstitialAd.h>
#import <PubnativeLite/PNLiteSettings.h>
#import <PubnativeLite/PNLiteStarRatingView.h>
#import <PubnativeLite/PNLiteNativeAdRenderer.h>

#import <PubnativeLite/HyBidRequestParameter.h>
#import <PubnativeLite/HyBidTargetingModel.h>
#import <PubnativeLite/HyBidAdRequest.h>
#import <PubnativeLite/HyBidBrowser.h>
#import <PubnativeLite/HyBidBrowserControlsView.h>
#import <PubnativeLite/HyBidMRAIDServiceProvider.h>
#import <PubnativeLite/HyBidMRAIDView.h>
#import <PubnativeLite/HyBidMRAIDServiceDelegate.h>
#import <PubnativeLite/HyBidBannerAdRequest.h>
#import <PubnativeLite/HyBidMRectAdRequest.h>
#import <PubnativeLite/HyBidInterstitialAdRequest.h>
#import <PubnativeLite/HyBidBannerPresenter.h>
#import <PubnativeLite/HyBidMRectPresenter.h>
#import <PubnativeLite/HyBidInterstitialPresenter.h>
#import <PubnativeLite/HyBidNativeAdLoader.h>
#import <PubnativeLite/HyBidBannerPresenterFactory.h>
#import <PubnativeLite/HyBidMRectPresenterFactory.h>



typedef void (^PubnativeLiteCompletionBlock)(BOOL);

@interface PubnativeLite : NSObject

+ (void)setCoppa:(BOOL)enabled;
+ (void)setTargeting:(HyBidTargetingModel *)targeting;
+ (void)setTestMode:(BOOL)enabled;
+ (void)initWithAppToken:(NSString *)appToken completion:(PubnativeLiteCompletionBlock)completion;

@end
