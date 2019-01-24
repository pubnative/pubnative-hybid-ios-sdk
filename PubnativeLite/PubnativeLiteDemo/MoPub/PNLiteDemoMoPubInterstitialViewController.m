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

#import "PNLiteDemoMoPubInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "MPInterstitialAdController.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubInterstitialViewController () <HyBidAdRequestDelegate, MPInterstitialAdControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, strong) MPInterstitialAdController *moPubInterstitial;
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;

@end

@implementation PNLiteDemoMoPubInterstitialViewController

- (void)dealloc {
    self.moPubInterstitial = nil;
    self.interstitialAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
    
    if(!self.moPubInterstitial) {
        self.moPubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:[PNLiteDemoSettings sharedInstance].moPubInterstitialAdUnitID];
        self.moPubInterstitial.delegate = self;
    }
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
}

- (void)showAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"I have a bad feeling about this... 🙄"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestInterstitialTouchUpInside:nil];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidLoadAd");
    [self.interstitialLoaderIndicator stopAnimating];
    [self.moPubInterstitial showFromViewController:self];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidFailToLoadAd");
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:@"MoPub Interstitial did fail to load."];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialWillAppear");
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidAppear");
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialWillDisappear");
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidDisappear");
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidExpire");
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidReceiveTapEvent");
}

#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    if (request == self.interstitialAdRequest) {
        self.inspectRequestButton.hidden = NO;
        [self.moPubInterstitial setKeywords:[HyBidPrebidUtils createPrebidKeywordsStringWithAd:ad]];
        [self.moPubInterstitial loadAd];
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
