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

#import "PNLiteDemoMoPubBannerViewController.h"
#import <HyBid/HyBid.h>
#import <MoPubSDK/MPAdView.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubBannerViewController () <HyBidAdRequestDelegate, MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) MPAdView *moPubBanner;
@property (nonatomic, strong) HyBidAdRequest *bannerAdRequest;

@end

@implementation PNLiteDemoMoPubBannerViewController

- (void)dealloc {
    self.moPubBanner = nil;
    self.bannerAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"MoPub Header Bidding Banner";

    [self.bannerLoaderIndicator stopAnimating];
    self.moPubBanner = [[MPAdView alloc] initWithAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingBannerAdUnitIDKey]];
    [self.moPubBanner setFrame:CGRectMake(0, 0, self.bannerContainer.frame.size.width, self.bannerContainer.frame.size.height)];
    self.moPubBanner.delegate = self;
    [self.moPubBanner stopAutomaticallyRefreshingContents];
    [self.bannerContainer addSubview:self.moPubBanner];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearLastInspectedRequest];
    self.bannerContainer.hidden = YES;
    self.inspectRequestButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    self.bannerAdRequest = [[HyBidAdRequest alloc] init];
    self.bannerAdRequest.adSize = HyBidAdSize.SIZE_320x50;
    [self.bannerAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
    NSLog(@"adViewDidLoadAd");
    if (self.moPubBanner == view) {
        self.bannerContainer.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
    }
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"adViewDidFailToLoadAd");
    if (self.moPubBanner == view) {
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
    
    if (request == self.bannerAdRequest) {
        self.inspectRequestButton.hidden = NO;
        [self.moPubBanner setKeywords:[HyBidHeaderBiddingUtils createHeaderBiddingKeywordsStringWithAd:ad]];
        [self.moPubBanner loadAd];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    if (request == self.bannerAdRequest) {
        self.inspectRequestButton.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}

@end
