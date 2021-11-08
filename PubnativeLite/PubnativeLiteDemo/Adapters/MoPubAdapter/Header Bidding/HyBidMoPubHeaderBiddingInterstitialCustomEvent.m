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

#import "HyBidMoPubHeaderBiddingInterstitialCustomEvent.h"
#import "HyBidMoPubUtils.h"

@interface HyBidMoPubHeaderBiddingInterstitialCustomEvent () <HyBidInterstitialPresenterDelegate>

@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidInterstitialPresenterFactory *interstitalPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidMoPubHeaderBiddingInterstitialCustomEvent

- (void)dealloc {
    self.interstitialPresenter = nil;
    self.interstitalPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if ([HyBidMoPubUtils isZoneIDValid:info]) {
        self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidMoPubUtils zoneID:info]];
        if (!self.ad) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"Could not find an ad in the cache for zone id with key: %@", [HyBidMoPubUtils zoneID:info]]];
            return;
        }
        if (self.ad.vast != nil) {
            self.ad.adType = kHyBidAdTypeVideo;
        } else {
            self.ad.adType = kHyBidAdTypeHTML;
        }
        self.interstitalPresenterFactory = [[HyBidInterstitialPresenterFactory alloc] init];
        self.interstitialPresenter = [self.interstitalPresenterFactory createInterstitalPresenterWithAd:self.ad
                                                                                    withVideoSkipOffset:[HyBidSettings sharedInstance].videoSkipOffset
                                                                                     withHTMLSkipOffset:[HyBidSettings sharedInstance].htmlSkipOffset
                                                                                      withCloseOnFinish:[HyBidSettings sharedInstance].closeOnFinish
                                                                                           withDelegate:self];
        if (!self.interstitialPresenter) {
            [self invokeFailWithMessage:@"Could not create valid interstitial presenter."];
            return;
        } else {
            [self.interstitialPresenter load];
            MPLogEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil]);
        }
    } else {
        [self invokeFailWithMessage:@"Failed interstitial ad fetch. Missing required server extras."];
        return;
    }
}

- (BOOL)isRewardExpected {
    return NO;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
    if ([self.interstitialPresenter respondsToSelector:@selector(showFromViewController:)]) {
        [self.interstitialPresenter showFromViewController:viewController];
    } else {
        [self.interstitialPresenter show];
    }
    MPLogEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass([self class])]);
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogInfo(@"%@", message);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                         code:0
                                                                                     userInfo:nil]];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])]);
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
    MPLogEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])]);
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    MPLogEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    MPLogEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass([self class])]);
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass([self class]) error:error]);
    [self invokeFailWithMessage:error.localizedDescription];
}

@end
