//
//  MPFullscreenAdAdapter+Reward.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdViewConstant.h"
#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Reward.h"
#import "MPLogging.h"
#import "MPRewardedVideo+Internal.h"

@implementation MPFullscreenAdAdapter (Reward)

- (NSTimeInterval)rewardCountdownDuration {
    NSTimeInterval duration = self.configuration.rewardedDuration;
    if (self.configuration.hasValidRewardFromMoPubSDK && duration <= 0) {
        duration = kDefaultRewardCountdownTimerIntervalInSeconds;
    }
    
    return duration;
}

- (void)provideRewardToUser:(MPReward *)reward
 forRewardCountdownComplete:(BOOL)isForRewardCountdownComplete
            forUserInteract:(BOOL)isForUserInteract {
    // Only provide a reward to the user if the ad is Rewarded.
    if (!self.configuration.isRewarded) {
        return;
    }
    
    // Note: Do not hold back the reward if `isRewardExpected` is NO, because it's possible that
    // the rewarded is not defined in the ad response / ad configuration, but is defined after
    // the reward condition has been satisfied (for 3rd party ad SDK's).
    
    if (NO == isForRewardCountdownComplete &&
        NO == (isForUserInteract && self.configuration.rewardedPlayableShouldRewardOnClick)) {
        /*
         Disallow trying to provide the reward when the reward countdown is not complete
         and it's triggered by user interaction but the "x-should-reward-on-click" flag is off.
         */
        return;
    }
    
    if (self.isUserRewarded) {
        return;
    }
    self.isUserRewarded = YES;
    
    // Server side reward tracking:
    // The original URL comes from the value of "x-rewarded-video-completion-url" in ad response.
    NSURL *url = self.rewardedVideoCompletionUrlByAppendingClientParams;
    if (url != nil) {
        [[MPRewardedVideo sharedInstance] startRewardedVideoConnectionWithUrl:url];
    }
    
    // Client side reward handling:
    if (reward.isCurrencyTypeSpecified == NO) {
        // Third party ad adapters do not have access to `MPAdConfiguration` and thus have no access
        // to the selected reward. As a result, they might return an unspecified reward while the
        // user actually selected one.
        reward = self.configuration.selectedReward;
    }
    
    MPLogInfo(@"MoPub user should be rewarded: %@", reward.debugDescription);
    if ([self.adapterDelegate respondsToSelector:@selector(adShouldRewardUserForAdapter:reward:)]) {
        [self.adapterDelegate adShouldRewardUserForAdapter:self reward:reward];;
    }
}

@end
