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

@interface HyBidDemoISRewardedViewController () <LPMRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) LPMRewardedAd *rewardedAd;

@end

@implementation HyBidDemoISRewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"IS Rewarded";
    
    LPMInitRequestBuilder *requestBuilder = [[LPMInitRequestBuilder alloc] initWithAppKey:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey]];
    LPMInitRequest *initRequest = [requestBuilder build];
    [LevelPlay initWithRequest:initRequest completion:^(LPMConfiguration * _Nullable config, NSError * _Nullable error) {
        if(error) {
            // There was an error on initialization. Take necessary actions or retry
        } else {
            // Initialization was successful. You can now create ad objects and load ads or perform other tasks
        }
    }];
    
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    
    self.rewardedAd = [[LPMRewardedAd alloc] initWithAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISRewardedAdUnitIdKey]];
    self.rewardedAd.delegate = self;
    
    [self.rewardedAd loadAd];
}

- (IBAction)showAdTouchUpInside:(UIButton *)sender {
    if ([self.rewardedAd isAdReady]) {
        [self.rewardedAd showAdWithViewController: self placementName: NULL];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

#pragma mark - LPMRewardedAdDelegate

- (void)didLoadAdWithAdInfo:(LPMAdInfo *)adInfo {
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
}

- (void)didFailToLoadAdWithAdUnitId:(NSString *)adUnitId error:(NSError *)error {
    self.debugButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"ironSource Rewarded did fail to load: %@", error.localizedDescription]];
}

- (void)didChangeAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didChangeAdInfo");
}

- (void)didDisplayAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didDisplayAdWithAdInfo");
}

- (void)didFailToDisplayAdWithAdInfo:(LPMAdInfo *)adInfo error:(NSError *)error {
    NSLog(@"Failed to show rewarded ad with error: %@", [error localizedDescription]);
}

- (void)didClickAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didClickAdWithAdInfo");
}

- (void)didCloseAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didCloseAdWithAdInfo");
    self.showAdButton.enabled = NO;
}

- (void)didRewardAdWithAdInfo:(LPMAdInfo *)adInfo reward:(LPMReward *)reward {
    NSLog(@"User did receive reward: %@ with amount: %ld", reward.name, reward.amount);
}

@end
