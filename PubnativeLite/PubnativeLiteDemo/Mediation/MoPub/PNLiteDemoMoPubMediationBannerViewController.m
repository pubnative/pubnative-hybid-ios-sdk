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
#import <MoPubSDK/MPAdView.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubMediationBannerViewController () <MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, strong) MPAdView *moPubBanner;

@end

@implementation PNLiteDemoMoPubMediationBannerViewController

- (void)dealloc {
    self.moPubBanner = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"MoPub Mediation Banner";
    [self.bannerLoaderIndicator stopAnimating];
    self.moPubBanner = [[MPAdView alloc] initWithAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubMediationBannerAdUnitIDKey]];
    [self.moPubBanner setFrame:CGRectMake(0, 0, self.bannerContainer.frame.size.width, self.bannerContainer.frame.size.height)];
    self.moPubBanner.delegate = self;
    [self.moPubBanner stopAutomaticallyRefreshingContents];
    [self.bannerContainer addSubview:self.moPubBanner];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.bannerContainer.hidden = YES;
    self.inspectRequestButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    [self.moPubBanner loadAd];
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
    NSLog(@"adViewDidLoadAd");
    if (self.moPubBanner == view) {
        self.bannerContainer.hidden = NO;
        self.inspectRequestButton.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
    }
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"adViewDidFailToLoadAd");
    if (self.moPubBanner == view) {
        self.inspectRequestButton.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:@"MoPub Banner did fail to load."];
    }
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
    NSLog(@"willPresentModalViewForAd");
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
    NSLog(@"didDismissModalViewForAd");
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view {
    NSLog(@"willLeaveApplicationFromAd");
}

@end
