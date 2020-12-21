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

#import "HyBidMoPubMediationNativeAdAdapter.h"

@interface HyBidMoPubMediationNativeAdAdapter () <HyBidNativeAdDelegate>

@property(nonatomic, strong) HyBidNativeAd *nativeAd;

@end

@implementation HyBidMoPubMediationNativeAdAdapter

@synthesize properties = _properties;
@synthesize defaultActionURL;

- (void)dealloc {
    self.nativeAd = nil;
}

- (instancetype)initWithNativeAd:(HyBidNativeAd *)ad {
    self = [super init];
    if (self) {
        self.nativeAd = ad;
        _properties = [self convertAssetsToProperties:ad];
    }
    return self;
}

- (NSDictionary *)convertAssetsToProperties:(HyBidNativeAd *)nativeAd {
    return @{ kAdTitleKey : nativeAd.title,
              kAdTextKey : nativeAd.body,
              kAdCTATextKey : nativeAd.callToActionTitle,
              kAdStarRatingKey : nativeAd.rating,
              kAdIconImageKey : nativeAd.iconUrl,
              kAdMainImageKey : nativeAd.bannerUrl,
              };
}

#pragma mark - MPNativeAdAdapter

- (NSURL *)defaultActionURL {
    return nil;
}

- (BOOL)enableThirdPartyClickTracking {
    return YES;
}

- (UIView *)privacyInformationIconView {
    return self.nativeAd.contentInfo;
}

- (void)willAttachToView:(UIView *)view {
    [self.nativeAd startTrackingView:view withDelegate:self];
}

- (void)didDetachFromView:(UIView *)view {
    [self.nativeAd stopTracking];
}

#pragma mark - HyBidNativeAdDelegate

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) {
        MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])]);
        [self.delegate nativeAdWillLogImpression:self];
    } else {
        MPLogInfo(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
    }
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd {
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass([self class])]);
        [self.delegate nativeAdDidClick:self];
    } else {
        MPLogInfo(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
    MPLogEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass([self class])]);
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

@end
