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

#import "HyBidDemoALMRectViewController.h"
#import "PNLiteDemoSettings.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface HyBidDemoALMRectViewController () <MAAdViewAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *mRectContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) MAAdView *appLovinMRect;

@end

@implementation HyBidDemoALMRectViewController

- (void)dealloc {
    self.appLovinMRect = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"AppLovin Mediation MRect";
    [self.mRectLoaderIndicator stopAnimating];
    self.appLovinMRect = [[MAAdView alloc] initWithAdUnitIdentifier: [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationMRectAdUnitIDKey]];
    self.appLovinMRect.delegate = self;
    self.appLovinMRect.frame = CGRectMake(0, 0, self.mRectContainer.frame.size.width, self.mRectContainer.frame.size.height);
    self.appLovinMRect.backgroundColor = [UIColor clearColor];
    [self.mRectContainer addSubview:self.appLovinMRect];
}

- (IBAction)requestMRectTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.mRectContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    [self.appLovinMRect loadAd];
}
#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad {
    [self.appLovinMRect stopAutoRefresh];
    self.mRectContainer.hidden = NO;
    self.debugButton.hidden = NO;
    [self.mRectLoaderIndicator stopAnimating];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.mRectLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin MRect did fail to load with message:%@", error.message]];
}

- (void)didClickAd:(MAAd *)ad {
    NSLog(@"didClickAd");
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.mRectLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin MRect did fail to display with message:%@", error.message]];
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
