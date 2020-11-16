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

#import "PNLiteDemoAdMobMediationRewardedViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface PNLiteDemoAdMobMediationRewardedViewController () <GADRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, strong) GADRewardedAd *adMobRewarded;

@end

@implementation PNLiteDemoAdMobMediationRewardedViewController

- (void)dealloc {
    self.adMobRewarded = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AdMob Mediation Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    self.adMobRewarded = [self createAndLoadRewarded];
    [self requestAd];
}
- (IBAction)showRewardedTouchUpInside:(id)sender {
    if (self.adMobRewarded.isReady) {
        [self.adMobRewarded presentFromRootViewController:self delegate:self];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    GADRequest *request = [GADRequest request];
    [self.adMobRewarded loadRequest:request completionHandler:^(GADRequestError * _Nullable error) {
        if (error) {
            NSLog(@"Ad loaded with error: %@", [error localizedDescription]);
        } else {
            NSLog(@"rewardedDidReceiveAd");
            self.inspectRequestButton.hidden = NO;
            [self.rewardedLoaderIndicator stopAnimating];
        }
    }];
}

- (GADRewardedAd *)createAndLoadRewarded {
    GADRewardedAd *rewarded = [[GADRewardedAd alloc] initWithAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidAdMobMediationRewardedAdUnitIDKey]];
    return rewarded;
}

#pragma mark GADRewardedAdDelegate

- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
    userDidEarnReward:(nonnull GADAdReward *)reward
{
    NSLog(@"rewardedAd:userDidEarnReward:");
}

- (void)rewardedAd:(nonnull GADRewardedAd *)rewardedAd
    didFailToPresentWithError:(nonnull NSError *)error
{
    NSLog(@"rewarded:didFailToPresentWithError: %@", [error localizedDescription]);
    self.inspectRequestButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)rewardedAdDidPresent:(nonnull GADRewardedAd *)rewardedAd
{
    NSLog(@"rewardedAdDidPresent");
}

- (void)rewardedAdDidDismiss:(nonnull GADRewardedAd *)rewardedAd
{
    NSLog(@"rewardedAdDidDismiss");
}

@end
