//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidDemoISRewardedViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "IronSource/IronSource.h"

@interface HyBidDemoISRewardedViewController () <LevelPlayRewardedVideoDelegate, ISInitializationDelegate>

@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@end

@implementation HyBidDemoISRewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"IS Rewarded";
    [IronSource initWithAppKey:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey] adUnits:@[IS_REWARDED_VIDEO] delegate:self];
    [IronSource setLevelPlayRewardedVideoDelegate:self];
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.enabled = [IronSource hasRewardedVideo];
}

- (IBAction)showAdTouchUpInside:(UIButton *)sender {
    if ([IronSource hasRewardedVideo]) {
        [IronSource showRewardedVideoWithViewController:self];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

#pragma mark - LevelPlayRewardedVideoDelegate

- (void)hasAvailableAdWithAdInfo:(ISAdInfo *)adInfo {
    self.showAdButton.enabled = YES;
    self.debugButton.hidden = NO;
    NSLog(@"hasAvailableAd");
}

- (void)hasNoAvailableAd {
    self.showAdButton.enabled = NO;
    self.debugButton.hidden = NO;
    NSLog(@"hasNoAvailableAd");
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo withAdInfo:(ISAdInfo *)adInfo {
    NSLog(@"User did receive reward: %@ with amount: %@", placementInfo.rewardName, placementInfo.rewardAmount);
}

- (void)didFailToShowWithError:(NSError *)error andAdInfo:(ISAdInfo *)adInfo {
    NSLog(@"Failed to show rewarded ad with error: %@", [error localizedDescription]);
}

- (void)didOpenWithAdInfo:(ISAdInfo *)adInfo {
    NSLog(@"rewardedVideoDidOpen");
}

- (void)didCloseWithAdInfo:(ISAdInfo *)adInfo {
    self.showAdButton.enabled = NO;
}

- (void)didClick:(ISPlacementInfo *)placementInfo withAdInfo:(ISAdInfo *)adInfo {
    NSLog(@"didClickRewardedVideo");
}

#pragma mark - ISInitializationDelegate

- (void)initializationDidComplete {
    
}

@end
