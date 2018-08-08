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

#import "PNLiteDemoDFPMRectViewController.h"
#import <PubnativeLite/PubnativeLite.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface PNLiteDemoDFPMRectViewController () <PNLiteAdRequestDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mRectContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (weak, nonatomic) IBOutlet UITextView *impressionIDTextView;
@property (nonatomic, strong) DFPBannerView *dfpMrect;
@property (nonatomic, strong) PNLiteMRectAdRequest *mRectAdRequest;

@end

@implementation PNLiteDemoDFPMRectViewController

- (void)dealloc
{
    self.dfpMrect = nil;
    self.mRectAdRequest = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"DFP MRect";
    
    [self.mRectLoaderIndicator stopAnimating];
    self.dfpMrect = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
    self.dfpMrect.delegate = self;
    self.dfpMrect.adUnitID = [PNLiteDemoSettings sharedInstance].dfpMRectAdUnitID;
    self.dfpMrect.rootViewController = self;
    [self.mRectContainer addSubview:self.dfpMrect];
}

- (IBAction)requestMRectTouchUpInside:(id)sender
{
    self.mRectContainer.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    self.mRectAdRequest = [[PNLiteMRectAdRequest alloc] init];
    [self.mRectAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
}

- (void)showAlertControllerWithMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"I have a bad feeling about this... 🙄"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestMRectTouchUpInside:nil];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
    NSLog(@"adViewDidReceiveAd");
    if (self.dfpMrect == adView) {
        self.mRectContainer.hidden = NO;
        [self.mRectLoaderIndicator stopAnimating];
    }
}

- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.dfpMrect == adView) {
        [self.mRectLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
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
    
    if (request == self.mRectAdRequest) {
        DFPRequest *request = [DFPRequest request];
        request.customTargeting = [PNLitePrebidUtils createPrebidKeywordsDictionaryWithAd:ad withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
        [self.dfpMrect loadRequest:request];
        self.impressionIDTextView.text = ad.impressionID;
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    if (request == self.mRectAdRequest) {
        [self.mRectLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}

@end
