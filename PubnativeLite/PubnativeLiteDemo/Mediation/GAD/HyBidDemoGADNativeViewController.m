//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidDemoGADNativeViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADNativeViewController () <GADNativeAdLoaderDelegate>

@property (weak, nonatomic) IBOutlet UIView *nativeAdContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nativeAdLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property(nonatomic, strong) GADAdLoader *adLoader;
@property(nonatomic, strong) GADNativeAdView *nativeAdView;

@end

@implementation HyBidDemoGADNativeViewController

- (void)dealloc {
    self.adLoader = nil;
    self.nativeAdView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAD Native";
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (IBAction)requestNativeAdTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.nativeAdContainer.hidden = YES;
    self.inspectRequestButton.hidden = YES;
    [self.nativeAdLoaderIndicator startAnimating];
    
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADNativeAdUnitIDKey]
                                       rootViewController:self
                                                  adTypes:@[ kGADAdLoaderAdTypeNative ]
                                                  options:@[ [[GADNativeAdViewAdOptions alloc] init] ]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}

#pragma mark GADNativeAdLoaderDelegate

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd {
    NSLog(@"Received native ad: %@", nativeAd);

    GADNativeAdView *nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"HyBidDemoGADNativeView" owner:nil options:nil].firstObject;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nativeAdView;
    self.nativeAdView.frame = self.nativeAdContainer.bounds;
    [self.nativeAdContainer addSubview:self.nativeAdView];
    self.nativeAdContainer.hidden = NO;

    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    [((UIButton *)nativeAdView.callToActionView)setTitle:nativeAd.callToAction
                                                forState:UIControlStateNormal];
    nativeAdView.callToActionView.userInteractionEnabled = NO;
    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    ((UIImageView *)nativeAdView.imageView).image = nativeAd.images.firstObject.image;
    nativeAdView.nativeAd = nativeAd;
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    if (self.adLoader == adLoader) {
        self.inspectRequestButton.hidden = NO;
        [self.nativeAdLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}
@end
