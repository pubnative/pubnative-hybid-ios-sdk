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

#import "PNLiteDemoMoPubMediationBannerViewController.h"
#import "MPAdView.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubMediationBannerViewController () <MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (nonatomic, strong) MPAdView *moPubBanner;

@end

@implementation PNLiteDemoMoPubMediationBannerViewController

- (void)dealloc
{
    self.moPubBanner = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"MoPub Mediation Banner";
    [self.bannerLoaderIndicator stopAnimating];
    self.moPubBanner = [[MPAdView alloc] initWithAdUnitId:[PNLiteDemoSettings sharedInstance].moPubMediationBannerAdUnitID
                                                     size:MOPUB_BANNER_SIZE];
    self.moPubBanner.delegate = self;
    [self.moPubBanner stopAutomaticallyRefreshingContents];
    [self.bannerContainer addSubview:self.moPubBanner];
}

- (IBAction)requestBannerTouchUpInside:(id)sender
{
    self.bannerContainer.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    [self.moPubBanner loadAd];
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    NSLog(@"adViewDidLoadAd");
    if (self.moPubBanner == view) {
        self.bannerContainer.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    NSLog(@"adViewDidFailToLoadAd");
    if (self.moPubBanner == view) {
        [self.bannerLoaderIndicator stopAnimating];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"I have a bad feeling about this... 🙄"
                                              message:@"MoPub Banner did fail to load."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self requestBannerTouchUpInside:nil];
        }];
        [alertController addAction:dismissAction];
        [alertController addAction:retryAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
    NSLog(@"willPresentModalViewForAd");
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
    NSLog(@"didDismissModalViewForAd");
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view
{
    NSLog(@"willLeaveApplicationFromAd");
}

@end
