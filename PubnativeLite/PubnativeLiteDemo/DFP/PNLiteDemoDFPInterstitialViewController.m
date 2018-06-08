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

#import "PNLiteDemoDFPInterstitialViewController.h"
#import <PubnativeLite/PubnativeLite.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface PNLiteDemoDFPInterstitialViewController () <PNLiteAdRequestDelegate, GADInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (nonatomic, strong) DFPInterstitial *dfpInterstitial;
@property (nonatomic, strong) PNLiteInterstitialAdRequest *interstitialAdRequest;

@end

@implementation PNLiteDemoDFPInterstitialViewController

- (void)dealloc
{
    self.dfpInterstitial = nil;
    self.interstitialAdRequest = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"DFP Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
    self.dfpInterstitial = [self createAndLoadInterstitial];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender
{
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAdRequest = [[PNLiteInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
}

- (DFPInterstitial *)createAndLoadInterstitial
{
    DFPInterstitial *interstitial = [[DFPInterstitial alloc] initWithAdUnitID:[PNLiteDemoSettings sharedInstance].dfpInterstitialAdUnitID];
    interstitial.delegate = self;
    return interstitial;
}

#pragma mark GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    NSLog(@"interstitialDidReceiveAd");
    [self.interstitialLoaderIndicator stopAnimating];
    if (self.dfpInterstitial.isReady) {
        [self.dfpInterstitial presentFromRootViewController:self];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    NSLog(@"interstitialWillPresentScreen");
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    NSLog(@"interstitialWillDismissScreen");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    NSLog(@"interstitialDidDismissScreen");
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    NSLog(@"interstitialWillLeaveApplication");
}

#pragma mark - PNLiteAdRequestDelegate

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    if (request == self.interstitialAdRequest) {
        DFPRequest *request = [DFPRequest request];
        request.customTargeting = [PNLitePrebidUtils createPrebidKeywordsDictionaryWithAd:ad withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
        [self.dfpInterstitial loadRequest:request];
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"PNLite Demo"
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    [self.interstitialLoaderIndicator stopAnimating];
}

@end
