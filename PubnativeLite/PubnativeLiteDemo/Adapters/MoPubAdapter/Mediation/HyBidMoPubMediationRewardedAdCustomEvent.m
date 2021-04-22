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

#import "HyBidMoPubMediationRewardedAdCustomEvent.h"
#import "HyBidMoPubUtils.h"

@interface HyBidMoPubMediationRewardedAdCustomEvent() <HyBidRewardedAdDelegate>
@property (nonatomic) HyBidRewardedAd *rewardedAd;
@end

@implementation HyBidMoPubMediationRewardedAdCustomEvent

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if ([HyBidMoPubUtils areExtrasValid:info]) {
        if ([HyBidMoPubUtils appToken:info] != nil && [[HyBidMoPubUtils appToken:info] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[HyBidMoPubUtils zoneID:info] andWithDelegate:self];
            self.rewardedAd.isMediation = YES;
            [self.rewardedAd load];
            MPLogEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil]);
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"Failed Rewarded ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogInfo(@"%@", message);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

- (BOOL)isRewardExpected {
    return YES;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    if ([self.rewardedAd respondsToSelector:@selector(showFromViewController:)]) {
        [self.rewardedAd showFromViewController:viewController];
    } else {
        [self.rewardedAd show];
    }
    MPLogEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass([self class])]);
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - HyBidRewardedAdDelegate

- (void)onReward {
    MPReward *reward = [[MPReward alloc] initWithCurrencyType:@"hybid_reward" amount:0];
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
    MPLogEvent([MPLogEvent adShouldRewardUserWithReward:reward]);
}

- (void)rewardedDidDismiss {
    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    MPLogEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    MPLogEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    MPLogEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass([self class])]);
}

- (void)rewardedDidFailWithError:(NSError *)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass([self class]) error:error]);
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)rewardedDidLoad {
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])]);
}

- (void)rewardedDidTrackClick {
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)rewardedDidTrackImpression {
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    MPLogEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass([self class])]);
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
    MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])]);
}

-(void)dealloc {
    self.rewardedAd = nil;
}

@end
