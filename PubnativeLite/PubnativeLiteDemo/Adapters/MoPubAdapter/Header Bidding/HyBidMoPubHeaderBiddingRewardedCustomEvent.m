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

#import "HyBidMoPubHeaderBiddingRewardedCustomEvent.h"
#import "HyBidMoPubUtils.h"
#import "HyBidRewardedPresenter.h"
#import "HyBidRewardedPresenterFactory.h"

@interface HyBidMoPubHeaderBiddingRewardedCustomEvent () <HyBidRewardedPresenterDelegate>

@property (nonatomic, strong) HyBidRewardedPresenter *rewardedPresenter;
@property (nonatomic, strong) HyBidRewardedPresenterFactory *rewardedPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidMoPubHeaderBiddingRewardedCustomEvent

- (void)dealloc {
    self.rewardedPresenter = nil;
    self.rewardedPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if ([HyBidMoPubUtils isZoneIDValid:info]) {
        self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidMoPubUtils zoneID:info]];
        if (!self.ad) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"Could not find an ad in the cache for zone id with key: %@", [HyBidMoPubUtils zoneID:info]]];
            return;
        }
        
        self.rewardedPresenterFactory = [[HyBidRewardedPresenterFactory alloc] init];
        self.rewardedPresenter = [self.rewardedPresenterFactory createRewardedPresenterWithAd:self.ad withDelegate:self];
        
        if (!self.rewardedPresenter) {
            [self invokeFailWithMessage:@"Could not create valid rewarded presenter."];
            return;
        } else {
            [self.rewardedPresenter load];
            MPLogEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil]);
        }
    } else {
        [self invokeFailWithMessage:@"Failed rewarded ad fetch. Missing required server extras."];
        return;
    }
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    [self.delegate fullscreenAdAdapterAdWillPresent:self];
    if ([self.rewardedPresenter respondsToSelector:@selector(showFromViewController:)]) {
        [self.rewardedPresenter showFromViewController:viewController];
    } else {
        [self.rewardedPresenter show];
    }
    MPLogEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass([self class])]);
}


- (BOOL)isRewardExpected {
    return NO;
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogInfo(@"%@", message);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                         code:0
                                                                                     userInfo:nil]];
}

#pragma mark - HyBidRewardedPresenterDelegate

- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter didFailWithError:(NSError *)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass([self class]) error:error]);
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    MPLogEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    MPLogEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass([self class])]);
}

- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter {
    MPReward *reward = [[MPReward alloc] initWithCurrencyType:@"hybid_reward" amount:0];
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    MPLogEvent([MPLogEvent adShouldRewardUserWithReward:reward]);
}

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])]);
}

- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.delegate fullscreenAdAdapterAdDidPresent:self];
    MPLogEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])]);
}

@end
