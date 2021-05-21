//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "PNLiteDemoMoPubMediationInterstitialViewController.h"
#import <MoPubSDK/MPInterstitialAdController.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubMediationInterstitialViewController () <MPInterstitialAdControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) MPInterstitialAdController *moPubInterstitial;

@end

@implementation PNLiteDemoMoPubMediationInterstitialViewController

- (void)dealloc {
    self.moPubInterstitial = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Mediation Interstitial";
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
    self.moPubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubMediationInterstitialAdUnitIDKey]];
    self.moPubInterstitial.delegate = self;
    [self.moPubInterstitial loadAd];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if (self.moPubInterstitial.ready) {
        [self.moPubInterstitial showFromViewController:self];
    }
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidLoadAd");
    self.inspectRequestButton.hidden = NO;
    self.showAdButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error {
    NSLog(@"interstitialDidFailToLoadAd");
    self.inspectRequestButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:@"MoPub Interstitial did fail to load."];
}

- (void)interstitialWillPresent:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialWillPresent");
}

- (void)interstitialDidPresent:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidPresent");
}

- (void)interstitialWillDismiss:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialWillDismiss");
    self.showAdButton.hidden = YES;
}

- (void)interstitialDidDismiss:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidDismiss");
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidExpire");
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidReceiveTapEvent");
}

@end
