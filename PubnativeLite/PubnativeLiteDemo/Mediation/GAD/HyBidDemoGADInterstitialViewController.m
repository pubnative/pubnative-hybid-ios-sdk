//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import "HyBidDemoGADInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADInterstitialViewController () <GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, strong) GAMInterstitialAd *gadInterstitial;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@end

@implementation HyBidDemoGADInterstitialViewController

- (void)dealloc {
    self.gadInterstitial = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAD Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    GAMRequest *request = [GAMRequest request];
    [GAMInterstitialAd loadWithAdManagerAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADInterstitialAdUnitIDKey]
                                         request:request
                               completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            self.inspectRequestButton.hidden = NO;
            [self.interstitialLoaderIndicator stopAnimating];
            [self showAlertControllerWithMessage:error.localizedDescription];
            return;
        }
        self.inspectRequestButton.hidden = NO;
        self.showAdButton.hidden = NO;
        [self.interstitialLoaderIndicator stopAnimating];
        self.gadInterstitial = ad;
        self.gadInterstitial.fullScreenContentDelegate = self;
    }];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if (self.gadInterstitial) {
        [self.gadInterstitial presentFromRootViewController:self];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

#pragma mark GADFullScreenContentDelegate

- (void)adDidPresentFullScreenContent:(id)ad {
    NSLog(@"Ad did present full screen content.");
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSLog(@"Ad failed to present full screen content with error %@.", [error localizedDescription]);
}

- (void)adDidDismissFullScreenContent:(id)ad {
    NSLog(@"Ad did dismiss full screen content.");
    self.showAdButton.hidden = YES;
}

@end
