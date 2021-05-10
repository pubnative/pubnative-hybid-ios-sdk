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

#import "HyBidDemoGADRewardedViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADRewardedViewController () <GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, strong) GADRewardedAd *gadRewarded;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@end

@implementation HyBidDemoGADRewardedViewController

- (void)dealloc {
    self.gadRewarded = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAD Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    [self requestAd];
}

- (IBAction)showRewardedTouchUpInside:(id)sender {
    
    if (self.gadRewarded) {
        [self.gadRewarded presentFromRootViewController:self
                               userDidEarnRewardHandler:^ {
            NSLog(@"User did earn rewarded.");
        }];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADRewardedAdUnitIDKey]
                            request:request
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
            self.inspectRequestButton.hidden = NO;
            [self.rewardedLoaderIndicator stopAnimating];
            [self showAlertControllerWithMessage:error.localizedDescription];
            return;
        }
        
        self.gadRewarded = ad;
        NSLog(@"Rewarded ad loaded.");
        self.gadRewarded.fullScreenContentDelegate = self;
        self.inspectRequestButton.hidden = NO;
        self.showAdButton.hidden = NO;
        [self.rewardedLoaderIndicator stopAnimating];
    }];
}

#pragma mark GADFullscreenContentDelegate

- (void)adDidPresentFullScreenContent:(id)ad {
    NSLog(@"Rewarded ad presented.");
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSLog(@"Rewarded ad failed to present with error: %@", [error localizedDescription]);
    self.inspectRequestButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adDidDismissFullScreenContent:(id)ad {
    NSLog(@"Rewarded ad dismissed.");
    self.showAdButton.hidden = YES;
}

@end
