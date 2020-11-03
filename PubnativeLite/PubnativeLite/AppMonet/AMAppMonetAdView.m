////
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

#import "AMAppMonetAdView.h"
#import "AMOConstants.h"
#import "AMMonetBid.h"

CGSize const MONET_BANNER_SIZE = {.width = 320.0f, .height = 50.0f};
CGSize const MONET_MEDIUM_RECT_SIZE = {.width = 300.0f, .height = 250.0f};

@interface AMAppMonetAdView () <HyBidAdViewDelegate>
@property(nonatomic) CGSize size;
@end

@implementation AMAppMonetAdView
- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.adUnitId = adUnitId;

        self.frame = ({
            CGRect frame = self.frame;
            frame.size = [AMAppMonetAdView sizeForContainer:self adSize:size adUnitId:adUnitId];
            frame;
        });
        self.size = size;
    }
    return self;
}

- (void)loadAd {
}

- (void)requestAds:(void (^)(AMMonetBid *bid))handler {
}

- (void)render:(AMMonetBid *)bid {
}

- (void)loadCustomEventAdapter:(NSDictionary *)localExtras withHandler:(void (^)(AMMonetBid *bid))handler {
}

- (void)invalidateAdapter {
}

- (void)registerClick {
}

- (void)onBannerFailed:(NSError *)error {
}

- (void)adLoaded {
}

- (void)setAdView:(UIView *)bannerView {
}

- (void)dealloc {
}

+ (CGSize)sizeForContainer:(UIView *_Nullable)container adSize:(CGSize)adSize adUnitId:(NSString *_Nullable)adUnitId {
    // Hydrating an ad size means resolving the `kMPFlexibleAdSize` value
    // into it's final size value based upon the container bounds.
    CGSize hydratedAdSize = adSize;

    // Hydrate the width.
    if (adSize.width == kAMFlexibleAdSize) {
        // Frame hasn't been set, issue a warning.
        if (container.bounds.size.width == 0) {}

        hydratedAdSize.width = container.bounds.size.width;
    }

    if (adSize.height == kAMFlexibleAdSize) {
        // Frame hasn't been set, issue a warning.
        if (container.bounds.size.height == 0) {}

        hydratedAdSize.height = container.bounds.size.height;
    }

    return hydratedAdSize;
}

#pragma mark HyBidAdViewDelegate

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    if ([self.bannerDelegate respondsToSelector:@selector(adError:withAdView:)]) {
        [self.bannerDelegate adError:error withAdView:self];
    }
}

- (void)adViewDidLoad:(HyBidAdView *)adView {
    if ([self.bannerDelegate respondsToSelector:@selector(adLoaded:)]) {
        [self.bannerDelegate adLoaded:self];
    }
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    if ([self.bannerDelegate respondsToSelector:@selector(wasClicked:)]) {
        [self.bannerDelegate wasClicked:self];
    }
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
}

@end
