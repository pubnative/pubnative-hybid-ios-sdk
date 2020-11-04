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
#import "HyBidLogger.h"
#import "HyBidAdCache.h"

CGSize const MONET_BANNER_SIZE = {.width = 320.0f, .height = 50.0f};
CGSize const MONET_MEDIUM_RECT_SIZE = {.width = 300.0f, .height = 250.0f};

@interface AMAppMonetAdView () <HyBidAdViewDelegate, HyBidAdRequestDelegate>
@property(nonatomic) CGSize size;
@end

@implementation AMAppMonetAdView

- (id)initWithAdUnitId:(NSString *)adUnitId size:(HyBidAdSize *)size {
    self = [self initWithSize:size];
    self.adUnitId = adUnitId;
    self.size = CGSizeMake(size.width, size.height);
    return self;
}

- (void)loadAd {
    if (self.adUnitId != NULL) {
        [self loadWithZoneID:self.adUnitId andWithDelegate:self];
    }
}

- (void)requestAds:(void (^)(AMMonetBid *bid))handler {
    [self.adRequest requestAdWithDelegate:self withZoneID:self.adUnitId];
}

- (void)render:(AMMonetBid *)bid {
    if (bid != nil) {
        HyBidAd *ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:bid.id];
        self.ad = ad;
        [self renderAd];
    } else {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"The provided bid is invalid."]];
    }
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

- (void)invokeDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

- (void)dealloc {
    self.bannerDelegate = nil;
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

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    
    if (!ad) {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"Server returned nil ad." code:0 userInfo:nil]];
    } else {
        AMMonetBid *bid = [[AMMonetBid alloc] initWithCPM:ad.eCPM id:self.adUnitId];
        if (bid.cpm > [[NSDecimalNumber alloc] initWithDouble:1.0]) {
            [self render:bid];
        }
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

@end
