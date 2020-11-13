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

#import "HyBidAdMobMediationRewardedCustomEvent.h"
#import "HyBidAdMobUtils.h"

@interface HyBidAdMobMediationRewardedCustomEvent() <HyBidRewardedAdDelegate>
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@end

@implementation HyBidAdMobMediationRewardedCustomEvent

@synthesize delegate;

- (void)dealloc {
    self.rewardedAd = nil;
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    [self.delegate customEventInterstitial:self didFailAd:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController {
    [self.delegate customEventInterstitialWillPresent:self];
    if ([self.rewardedAd respondsToSelector:@selector(showFromViewController:)]) {
        [self.rewardedAd showFromViewController:rootViewController];
    } else {
        [self.rewardedAd show];
    }
}

- (void)requestInterstitialAdWithParameter:(nullable NSString *)serverParameter label:(nullable NSString *)serverLabel request:(nonnull GADCustomEventRequest *)request {
    if ([HyBidAdMobUtils areExtrasValid:serverParameter]) {
        if ([HyBidAdMobUtils appToken:serverParameter] != nil || [[HyBidAdMobUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[HyBidAdMobUtils zoneID:serverParameter] andWithDelegate:self];
            self.rewardedAd.isMediation = YES;
            [self.rewardedAd load];
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
        
    } else {
        [self invokeFailWithMessage:@"Failed interstitial ad fetch. Missing required server extras."];
        return;
    }
}


#pragma mark - HyBidRewardedAdDelegate

- (void)onReward {
    NSLog(@"On Reward.");
}

- (void)rewardedDidDismiss {
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)rewardedDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)rewardedDidLoad {
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)rewardedDidTrackClick {
    [self.delegate customEventInterstitialWasClicked:self];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

- (void)rewardedDidTrackImpression {
    NSLog(@"Rewarded Did Track Impression.");
}

@end
