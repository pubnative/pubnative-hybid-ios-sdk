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

#import "PNLiteDemoPNLiteNativeAdViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "HyBidSKAdNetworkViewController.h"

@interface PNLiteDemoPNLiteNativeAdViewController () <HyBidNativeAdLoaderDelegate, HyBidNativeAdDelegate, HyBidNativeAdFetchDelegate>

@property (weak, nonatomic) IBOutlet UIView *nativeAdContainer;
@property (weak, nonatomic) IBOutlet UIView *nativeAdContentInfo;
@property (weak, nonatomic) IBOutlet UIImageView *nativeAdIcon;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdTitle;
@property (weak, nonatomic) IBOutlet HyBidStarRatingView *nativeAdRating;
@property (weak, nonatomic) IBOutlet UIView *nativeAdBanner;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdBody;
@property (weak, nonatomic) IBOutlet UIButton *nativeCallToAction;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nativeAdLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) HyBidNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) HyBidNativeAd *nativeAd;
@end

@implementation PNLiteDemoPNLiteNativeAdViewController

- (void)dealloc {
    self.nativeAdLoader = nil;
    [self.nativeAd stopTracking];
    self.nativeAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"HyBid Native Ad";
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (IBAction)requestNativeAdTouchUpInside:(id)sender {
    [self reportEvent:HyBidReportingEventType.AD_REQUEST adFormat: HyBidReportingAdFormat.NATIVE properties:nil];
    [self requestAd];
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearLastInspectedRequest];
    self.nativeAdContainer.hidden = YES;
    self.inspectRequestButton.hidden = YES;
    [self.nativeAdLoaderIndicator startAnimating];
    self.nativeAdLoader = [[HyBidNativeAdLoader alloc] init];
    [self.nativeAdLoader loadNativeAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidNativeAdLoaderDelegate

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd {
    NSLog(@"Native Ad: %@ did load",nativeAd);
    self.inspectRequestButton.hidden = NO;
    self.nativeAd = nativeAd;
    [self setCreativeIDLabelWithString:self.nativeAd.ad.creativeID];
    [self.nativeAd fetchNativeAdAssetsWithDelegate:self];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error {
    NSLog(@"Native Ad did fail with error: %@",error.localizedDescription);
    self.inspectRequestButton.hidden = NO;
    [self.nativeAdLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

#pragma mark - HyBidNativeAdFetchDelegate

- (void)nativeAdDidFinishFetching:(HyBidNativeAd *)nativeAd {
    HyBidNativeAdRenderer *renderer = [[HyBidNativeAdRenderer alloc] init];
    renderer.contentInfoView = self.nativeAdContentInfo;
    renderer.iconView = self.nativeAdIcon;
    renderer.titleView = self.nativeAdTitle;
    renderer.starRatingView = self.nativeAdRating;
    renderer.bannerView = self.nativeAdBanner;
    renderer.bodyView = self.nativeAdBody;
    renderer.callToActionView = self.nativeCallToAction;
    
    [self.nativeAd renderAd:renderer];
    self.nativeAdContainer.hidden = NO;
    [self.nativeAd startTrackingView:self.nativeAdContainer withDelegate:self];
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (void)nativeAd:(HyBidNativeAd *)nativeAd didFailFetchingWithError:(NSError *)error {
    NSLog(@"Native Ad did fail with error: %@",error.localizedDescription);
    [self.nativeAdLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

#pragma mark - HyBidNativeAdDelegate

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view {
    NSLog(@"Native Ad did track impression:");
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd {
    NSLog(@"Native Ad did track click:");
}

- (void)displaySkAdNetworkViewController:(NSDictionary *)productParameters
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters:productParameters];
        [self presentViewController:skAdnetworkViewController animated:true completion:nil];
    });
}

@end
