//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidGADNativeAd.h"

@interface HyBidGADNativeAd () <HyBidNativeAdDelegate>

@property(nonatomic, strong) HyBidNativeAd *nativeAd;

@end

@implementation HyBidGADNativeAd

@synthesize advertiser, extraAssets, store, price;

- (void)dealloc {
    self.nativeAd = nil;
}

- (instancetype)initWithHyBidNativeAd:(HyBidNativeAd *)nativeAd
                nativeAdViewAdOptions:(GADNativeAdViewAdOptions *)nativeAdViewAdOptions {
    if (!nativeAd) {
      return nil;
    }
    self = [super init];
    if (self) {
        self.nativeAd = nativeAd;
    }
    return self;
}

- (NSString *)headline {
    return self.nativeAd.title;
}

- (NSString *)body {
    return self.nativeAd.body;
}

- (NSString *)callToAction {
    return self.nativeAd.callToActionTitle;
}

- (NSDecimalNumber *)starRating {
    return [NSDecimalNumber decimalNumberWithDecimal:[self.nativeAd.rating decimalValue]];
}

- (GADNativeAdImage *)icon {
    return [[GADNativeAdImage alloc] initWithImage:self.nativeAd.icon];
}

- (NSArray *)images {
  return @[ [[GADNativeAdImage alloc] initWithImage:self.nativeAd.bannerImage] ];
}

- (UIView *)adChoicesView {
    return self.nativeAd.contentInfo;
}

- (void)didRenderInView:(UIView *)view clickableAssetViews:(NSDictionary<GADNativeAssetIdentifier,UIView *> *)clickableAssetViews nonclickableAssetViews:(NSDictionary<GADNativeAssetIdentifier,UIView *> *)nonclickableAssetViews viewController:(UIViewController *)viewController {
    [self.nativeAd startTrackingView:view withDelegate:self];
}

- (void)didUntrackView:(UIView *)view {
    [self.nativeAd stopTracking];
}

#pragma mark - HyBidNativeAdDelegate

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view {
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:self];
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd {
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self];
}

@end

