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

#import "PNLiteDemoDFPBannerViewController.h"
#import <PubnativeLite/PubnativeLite.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface PNLiteDemoDFPBannerViewController () <PNLiteAdRequestDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (nonatomic, strong) DFPBannerView *dfpBanner;
@property (nonatomic, strong) PNLiteBannerAdRequest *bannerAdRequest;

@end

@implementation PNLiteDemoDFPBannerViewController

- (void)dealloc
{
    self.dfpBanner = nil;
    self.bannerAdRequest = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"DFP Banner";
    
    [self.bannerLoaderIndicator stopAnimating];
    self.dfpBanner = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.dfpBanner.delegate = self;
    self.dfpBanner.adUnitID = [PNLiteDemoSettings sharedInstance].dfpBannerAdUnitID;
    self.dfpBanner.rootViewController = self;
    [self.bannerContainer addSubview:self.dfpBanner];
}

- (IBAction)requestBannerTouchUpInside:(id)sender
{
    self.bannerContainer.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    self.bannerAdRequest = [[PNLiteBannerAdRequest alloc] init];
    [self.bannerAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
    NSLog(@"adViewDidReceiveAd");
    if (self.dfpBanner == adView) {
        self.bannerContainer.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
    }
}

- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.dfpBanner == adView) {
        [self.bannerLoaderIndicator stopAnimating];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"PNLite Demo"
                                              message:error.localizedDescription
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:dismissAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillPresentScreen");
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewDidDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    NSLog(@"adViewWillLeaveApplication");
}

#pragma mark - PNLiteAdRequestDelegate

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    
    if (request == self.bannerAdRequest) {
        DFPRequest *request = [DFPRequest request];
        request.customTargeting = [PNLitePrebidUtils createPrebidKeywordsDictionaryWithAd:ad withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
        [self.dfpBanner loadRequest:request];
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
    
    if (request == self.bannerAdRequest) {
        [self.bannerLoaderIndicator stopAnimating];
    }
}

@end
