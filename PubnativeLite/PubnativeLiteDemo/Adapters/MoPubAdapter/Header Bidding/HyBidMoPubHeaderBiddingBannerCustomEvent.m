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

#import "HyBidMoPubHeaderBiddingBannerCustomEvent.h"
#import "HyBidMoPubUtils.h"

@interface HyBidMoPubHeaderBiddingBannerCustomEvent () <HyBidAdPresenterDelegate>

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidBannerPresenterFactory *bannerPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidMoPubHeaderBiddingBannerCustomEvent

- (void)dealloc {
    self.adPresenter = nil;
    self.bannerPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if ([HyBidMoPubUtils isZoneIDValid:info]) {
        self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidMoPubUtils zoneID:info]];
        if (!self.ad) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"Could not find an ad in the cache for zone id with key: %@", [HyBidMoPubUtils zoneID:info]]];
            return;
        }
        self.bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
        self.adPresenter = [self.bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
        if (!self.adPresenter) {
            [self invokeFailWithMessage:@"Could not create valid banner presenter."];
            return;
        } else {
            [self.adPresenter load];
                MPLogEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil]);
        }
    } else {
        [self invokeFailWithMessage:@"Failed banner ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogInfo(@"%@", message);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                     code:0
                                                                                 userInfo:nil]];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:adView];
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])]);
    [self.delegate inlineAdAdapterDidTrackImpression:self];
    MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])]);
    [self.adPresenter startTracking];
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass([self class]) error:error]);
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    [self.delegate inlineAdAdapterDidTrackClick:self];
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass([self class])]);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

@end
