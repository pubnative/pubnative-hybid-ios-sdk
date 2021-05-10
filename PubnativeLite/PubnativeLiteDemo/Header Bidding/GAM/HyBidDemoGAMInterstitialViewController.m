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
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) GAMInterstitialAd *gamInterstitialAd;
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;

@end

@implementation HyBidDemoGAMInterstitialViewController

- (void)dealloc {
    self.gamInterstitialAd = nil;
    self.interstitialAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAM Interstitial";
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
    self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if (self.gamInterstitialAd) {
        [self.gamInterstitialAd presentFromRootViewController:self];
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


#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", ad.creativeID];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", ad.creativeID];
    
    if (request == self.interstitialAdRequest) {
        self.inspectRequestButton.hidden = NO;
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
        }];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    if (request == self.interstitialAdRequest) {
        self.inspectRequestButton.hidden = NO;
        [self showAlertControllerWithMessage:error.localizedDescription];
        [self.interstitialLoaderIndicator stopAnimating];
    }
}

@end
