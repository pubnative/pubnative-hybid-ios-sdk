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

#import "PNLiteDemoMoPubInterstitialVideoViewController.h"
#import <HyBid/HyBid.h>
#import <MoPubSDK/MPInterstitialAdController.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubInterstitialVideoViewController () <HyBidAdRequestDelegate, MPInterstitialAdControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) MPInterstitialAdController *moPubInterstitial;
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;

@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet UISwitch *adCachingSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showAdTopConstraint;

@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation PNLiteDemoMoPubInterstitialVideoViewController

- (void)dealloc {
    self.moPubInterstitial = nil;
    self.interstitialAdRequest = nil;
    self.ad = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Header Bidding Interstitial Video";
    [self.interstitialLoaderIndicator stopAnimating];
    
    self.showAdTopConstraint.constant = 8.0;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest setIsAutoCacheOnLoad:self.adCachingSwitch.isOn];
    [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

- (IBAction)showInterstitialVideoAdButtonTapped:(UIButton *)sender {
    if (self.moPubInterstitial.ready) {
        [self.moPubInterstitial showFromViewController:self];
    }
}

- (IBAction)adCachingSwitchValueChanged:(UISwitch *)sender {
    self.prepareButton.hidden = sender.isOn;
    self.showAdTopConstraint.constant = sender.isOn ? 8.0 : 46.0;
    [self.showAdButton setNeedsDisplay];
}

- (IBAction)prepareButtonTapped:(UIButton *)sender {
    if (self.ad != nil && self.interstitialAdRequest != nil) {
        [self.interstitialAdRequest cacheAd:self.ad];
    }
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidLoadAd");
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    self.prepareButton.enabled = !self.adCachingSwitch.isOn;
    self.showAdButton.enabled = YES;
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial withError:(NSError *)error {
    NSLog(@"interstitialDidFailToLoadAd");
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
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
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
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

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    [self setCreativeIDLabelWithString:ad.creativeID];
    self.ad = ad;
    
    if (request == self.interstitialAdRequest) {
        self.debugButton.hidden = NO;
        self.moPubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingInterstitialVideoAdUnitIDKey]];
        self.moPubInterstitial.delegate = self;
        [self.moPubInterstitial setKeywords:[HyBidHeaderBiddingUtils createHeaderBiddingKeywordsStringWithAd:ad]];
        [self.moPubInterstitial loadAd];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    self.ad = nil;
    if (request == self.interstitialAdRequest) {
        self.debugButton.hidden = NO;
        [self.interstitialLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
        [self.moPubInterstitial loadAd];
    }
}

@end
