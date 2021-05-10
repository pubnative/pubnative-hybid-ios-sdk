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

#import "PNLiteDemoPNLiteStickyBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "HyBidSKAdNetworkViewController.h"

@interface PNLiteDemoPNLiteStickyBannerViewController () <HyBidAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;

@property (nonatomic, strong) HyBidAdView *bannerAdView;
@property (nonatomic) BannerPosition bannerPosition;

@end

@implementation PNLiteDemoPNLiteStickyBannerViewController

- (void)dealloc {
    self.bannerAdView = nil;
    self.bannerLoaderIndicator = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bannerLoaderIndicator stopAnimating];
    self.navigationItem.title = @"HyBid Sticky Banner";
    self.bannerAdView = [[HyBidAdView alloc] initWithSize:[PNLiteDemoSettings sharedInstance].adSize];
    self.bannerPosition = TOP;
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    NSDictionary *properties=[[NSDictionary alloc] initWithObjectsAndKeys:self.bannerAdView.adSize.description , HyBidReportingCommon.AD_SIZE, nil];
    [self reportEvent:HyBidReportingEventType.AD_REQUEST adFormat: HyBidReportingAdFormat.BANNER properties:properties];
    [self requestAd];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0: // TOP
            self.bannerPosition = TOP;
            break;
        case 1: // BOTTOM
            self.bannerPosition = BOTTOM;
            break;
    }
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearLastInspectedRequest];
    self.bannerAdView.hidden = YES;
    self.inspectRequestButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    [self.bannerAdView loadWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] withPosition:self.bannerPosition andWithDelegate:self];
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
    [self setCreativeIDLabelWithString:self.bannerAdView.ad.creativeID];
    self.bannerAdView.hidden = NO;
    self.inspectRequestButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    self.inspectRequestButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track impression:");
}

@end
