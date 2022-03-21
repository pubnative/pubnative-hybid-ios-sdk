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

#import "HyBidDemoALInterstitialViewController.h"
#import "PNLiteDemoSettings.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface HyBidDemoALInterstitialViewController () <MAAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;

@end

@implementation HyBidDemoALInterstitialViewController

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AppLovin Mediation Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationInterstitialAdUnitIDKey]];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if ([self.interstitialAd isReady]) {
        [self.interstitialAd showAd];
    }
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad {
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin Interstitial did fail to load with message:%@", error.message]];
}

- (void)didDisplayAd:(nonnull MAAd *)ad {
    NSLog(@"didDisplayAd");
}

- (void)didHideAd:(nonnull MAAd *)ad {
    NSLog(@"didHideAd");
}

- (void)didClickAd:(MAAd *)ad {
    NSLog(@"didClickAd");
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin Interstitial did fail to display with message:%@", error.message]];
}

@end
