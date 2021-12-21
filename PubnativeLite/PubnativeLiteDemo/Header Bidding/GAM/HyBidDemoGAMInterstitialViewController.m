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

#import "HyBidDemoGAMInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGAMInterstitialViewController () <HyBidAdRequestDelegate, GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) GAMInterstitialAd *gamInterstitialAd;
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;

@property (weak, nonatomic) IBOutlet UISwitch *adCachingSwitch;
@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showAdTopConstraint;

@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidDemoGAMInterstitialViewController

- (void)dealloc {
    self.gamInterstitialAd = nil;
    self.interstitialAdRequest = nil;
    self.ad = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAM Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
    self.showAdTopConstraint.constant = 8.0;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
    self.interstitialAdRequest.isAutoCacheOnLoad = self.adCachingSwitch.isOn;
    [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if (self.gamInterstitialAd) {
        [self.gamInterstitialAd presentFromRootViewController:self];
    } else {
        NSLog(@"Ad wasn't ready");
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
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
}


#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    self.ad = ad;
    
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", ad.creativeID];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", ad.creativeID];
    
    if (request == self.interstitialAdRequest) {
        self.debugButton.hidden = NO;
        GAMRequest *request = [GAMRequest request];
        request.customTargeting = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad];
        [GAMInterstitialAd loadWithAdManagerAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGAMInterstitialAdUnitIDKey]
                                             request:request
                                   completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
            if (error) {
                NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
                [self.interstitialLoaderIndicator stopAnimating];
                [self showAlertControllerWithMessage:error.localizedDescription];
                return;
            }
            [self.interstitialLoaderIndicator stopAnimating];
            self.gamInterstitialAd = ad;
            self.gamInterstitialAd.fullScreenContentDelegate = self;
            self.showAdButton.hidden = NO;
            self.prepareButton.enabled = !self.adCachingSwitch.isOn;
            self.showAdButton.enabled = YES;
        }];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    self.ad = nil;
    
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    
    if (request == self.interstitialAdRequest) {
        self.debugButton.hidden = NO;
        [self showAlertControllerWithMessage:error.localizedDescription];
        [self.interstitialLoaderIndicator stopAnimating];
    }
}

@end
