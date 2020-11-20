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

#import "HyBidAdMobMediationRewardedCustomEvent.h"
#import "HyBidAdMobUtils.h"

@interface HyBidAdMobMediationRewardedCustomEvent() <HyBidRewardedAdDelegate, GADMediationRewardedAd>
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property(nonatomic, weak, nullable) id<GADMediationRewardedAdEventDelegate> delegate;
@end

@implementation HyBidAdMobMediationRewardedCustomEvent

- (void)dealloc {
    self.rewardedAd = nil;
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    [self.delegate willPresentFullScreenView];
    if ([self.rewardedAd respondsToSelector:@selector(showFromViewController:)]) {
        [self.rewardedAd showFromViewController:viewController];
    } else {
        [self.rewardedAd show];
    }
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler
{
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidAdMobUtils areExtrasValid:serverParameter]) {
        if ([HyBidAdMobUtils appToken:serverParameter] != nil || [[HyBidAdMobUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[HyBidAdMobUtils zoneID:serverParameter] andWithDelegate:self];
            self.rewardedAd.isMediation = YES;
            self.delegate = completionHandler(self, nil);
            [self.rewardedAd load];
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"Failed rewarded ad fetch. Missing required server extras."];
        return;
    }
}

#pragma mark - HyBidRewardedAdDelegate

- (void)onReward {
    NSLog(@"On Reward.");
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:0] decimalValue]];
    GADAdReward *reward = [[GADAdReward alloc] initWithRewardType:@"hybid_reward" rewardAmount:amount];
    [self.delegate didRewardUserWithReward:reward];
}

- (void)rewardedDidDismiss {
    NSLog(@"rewardedDidDismiss");
    [self.delegate willDismissFullScreenView];
    [self.delegate didDismissFullScreenView];
}

- (void)rewardedDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)rewardedDidLoad {
    NSLog(@"rewardedDidLoad");
    [self.delegate willPresentFullScreenView];
}

- (void)rewardedDidTrackClick {
    NSLog(@"rewardedDidTrackClick");
    [self.delegate reportClick];
}

- (void)rewardedDidTrackImpression {
    [self.delegate reportImpression];
    NSLog(@"Rewarded Did Track Impression.");
}

+ (GADVersionNumber)adSDKVersion {
    GADVersionNumber version = {0};
    version.majorVersion = 2;
    version.minorVersion = 3;
    version.patchVersion = 0;
    
    return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

+ (GADVersionNumber)version {
    GADVersionNumber version = {0};
    version.majorVersion = 2;
    version.minorVersion = 3;
    version.patchVersion = 0;
    return version;
}
@end
