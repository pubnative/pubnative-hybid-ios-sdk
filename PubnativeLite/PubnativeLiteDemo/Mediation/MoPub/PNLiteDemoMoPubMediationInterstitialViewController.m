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
#import "MPInterstitialAdController.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubMediationInterstitialViewController () <MPInterstitialAdControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, strong) MPInterstitialAdController *moPubInterstitial;

@end

@implementation PNLiteDemoMoPubMediationInterstitialViewController

- (void)dealloc
{
    self.moPubInterstitial = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Mediation Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
    
    if(self.moPubInterstitial == nil) {
        self.moPubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:[PNLiteDemoSettings sharedInstance].moPubMediationInterstitialAdUnitID];
        self.moPubInterstitial.delegate = self;
    }
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender
{
    self.inspectRequestButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    [self.moPubInterstitial loadAd];
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialDidLoadAd");
    self.inspectRequestButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self.moPubInterstitial showFromViewController:self];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialDidFailToLoadAd");
    self.inspectRequestButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"I have a bad feeling about this... 🙄"
                                          message:@"MoPub Interstitial did fail to load."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestInterstitialTouchUpInside:nil];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialWillAppear");
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialDidAppear");
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialWillDisappear");
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialDidDisappear");
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialDidExpire");
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialDidReceiveTapEvent");
}

@end
