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

#import "HyBidMoPubBannerCustomEvent.h"
#import "HyBidMoPubUtils.h"
#import "MPLogging.h"
#import "MPConstants.h"
#import "MPError.h"

@interface HyBidMoPubBannerCustomEvent () <HyBidAdPresenterDelegate>

@property (nonatomic, strong) HyBidAdPresenter *bannerPresenter;
@property (nonatomic, strong) HyBidBannerPresenterFactory *bannerPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidMoPubBannerCustomEvent

- (void)dealloc {
    [self.bannerPresenter stopTracking];
    self.bannerPresenter = nil;
    self.bannerPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    if ([HyBidMoPubUtils isZoneIDValid:info]) {
        if (CGSizeEqualToSize(MOPUB_BANNER_SIZE, size)) {
            self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidMoPubUtils zoneID:info]];
            if (!self.ad) {
                [self invokeFailWithMessage:[NSString stringWithFormat:@"HyBid - Error: Could not find an ad in the cache for zone id with key: %@", [HyBidMoPubUtils zoneID:info]]];
                return;
            }
            self.bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
            self.bannerPresenter = [self.bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
            if (!self.bannerPresenter) {
                [self invokeFailWithMessage:@"HyBid - Error: Could not create valid banner presenter"];
                return;
            } else {
                [self.bannerPresenter load];
            }
        } else {
            [self invokeFailWithMessage:@"HyBid - Error: Wrong ad size."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"HyBid - Error: Failed banner ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogError(message);
    [self.delegate bannerCustomEvent:self
            didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                         code:0
                                                     userInfo:nil]];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
    [self.bannerPresenter startTracking];
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:[NSString stringWithFormat:@"HyBid - Internal Error: %@", error.localizedDescription]];
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
