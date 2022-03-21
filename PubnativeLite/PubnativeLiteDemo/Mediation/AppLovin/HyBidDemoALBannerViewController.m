//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidDemoALBannerViewController.h"
#import "PNLiteDemoSettings.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface HyBidDemoALBannerViewController () <MAAdViewAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) MAAdView *appLovinBanner;

@end

@implementation HyBidDemoALBannerViewController

- (void)dealloc {
    self.appLovinBanner = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"AppLovin Mediation Banner";
    [self.bannerLoaderIndicator stopAnimating];
    self.appLovinBanner = [[MAAdView alloc] initWithAdUnitIdentifier: [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationBannerAdUnitIDKey]];
    self.appLovinBanner.delegate = self;
    self.appLovinBanner.frame = CGRectMake(0, 0, self.bannerContainer.frame.size.width, self.bannerContainer.frame.size.height);
    self.appLovinBanner.backgroundColor = [UIColor clearColor];
    [self.bannerContainer addSubview:self.appLovinBanner];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.bannerContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    [self.appLovinBanner loadAd];
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad {
    [self.appLovinBanner stopAutoRefresh];
    self.bannerContainer.hidden = NO;
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin Banner did fail to load with message:%@", error.message]];
}

- (void)didClickAd:(MAAd *)ad {
    NSLog(@"didClickAd");
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin Banner did fail to display with message:%@", error.message]];
}

- (void)didDisplayAd:(nonnull MAAd *)ad {
    NSLog(@"didDisplayAd");
}

- (void)didHideAd:(nonnull MAAd *)ad {
    NSLog(@"didHideAd");
}

#pragma mark - MAAdViewAdDelegate Protocol

- (void)didExpandAd:(MAAd *)ad {
    NSLog(@"didExpandAd");
}

- (void)didCollapseAd:(MAAd *)ad {
    NSLog(@"didCollapseAd");
}

@end
