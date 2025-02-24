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

#import "PNLiteDemoPNLiteInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteInterstitialViewController () <HyBidInterstitialAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet UISwitch *adCachingSwitch;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showAdTopConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isUsingOpenRTB;
@property (weak, nonatomic) IBOutlet UISegmentedControl *adFormatSwitch;

@end

@implementation PNLiteDemoPNLiteInterstitialViewController

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"HyBid Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
    self.showAdTopConstraint.constant = 8.0;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.adFormatSwitch.accessibilityIdentifier = @"openRTBAdFormatSwitch";
    self.adFormatSwitch.hidden = YES;
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
    [self.interstitialAd setIsAutoCacheOnLoad: self.adCachingSwitch.isOn];
    if (self.isUsingOpenRTB.selectedSegmentIndex == 0) {
        [self.interstitialAd load];
    } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        if (self.adFormatSwitch.selectedSegmentIndex == 0) {
            [self.interstitialAd setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdBanner];
        } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
            [self.interstitialAd setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdVideo];
        }
        [self.interstitialAd loadExchangeAd];
    }
}

- (IBAction)requestTypeChanged:(id)sender {
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1){
        self.adFormatSwitch.hidden = NO;
    } else{
        self.adFormatSwitch.hidden = YES;
    }
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if (self.interstitialAd.isReady) {
        [self.interstitialAd show];
    }
}

- (IBAction)adCachingSwitchValueChanged:(UISwitch *)sender {
    self.prepareButton.hidden = sender.isOn;
    self.showAdTopConstraint.constant = sender.isOn ? 8.0 : 46.0;
    [self.showAdButton setNeedsDisplay];
}

- (IBAction)prepareButtonTapped:(UIButton *)sender {
    [self.interstitialAd prepare];
    self.prepareButton.enabled = NO;
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        [self setCreativeIDLabelWithString:self.interstitialAd.ad.openRTBCreativeID];
    } else {
        [self setCreativeIDLabelWithString:self.interstitialAd.ad.creativeID];
    }
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    self.prepareButton.enabled = !self.adCachingSwitch.isOn;
    self.showAdButton.enabled = YES;
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)interstitialDidFailWithError:(NSError *)error {
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)interstitialDidTrackClick {
    NSLog(@"Interstitial did track click");
}

- (void)interstitialDidTrackImpression {
    NSLog(@"Interstitial did track impression");
}

- (void)interstitialDidDismiss {
    NSLog(@"Interstitial did dismiss");
    self.showAdButton.hidden = YES;
    self.showAdButton.enabled = NO;
    self.prepareButton.enabled = NO;
}

@end
