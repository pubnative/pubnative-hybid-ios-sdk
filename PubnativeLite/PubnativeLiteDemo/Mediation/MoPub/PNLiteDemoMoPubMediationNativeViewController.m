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

#import "PNLiteDemoMoPubMediationNativeViewController.h"
#import "PNLiteDemoMoPubMediationNativeView.h"
#import "PNLiteDemoSettings.h"
#import <MoPubSDK/MPNativeAdRequest.h>
#import <MoPubSDK/MPNativeAd.h>
#import <MoPubSDK/MPNativeAdDelegate.h>
#import <MoPubSDK/MPNativeAdRendererImageHandler.h>
#import <MoPubSDK/MPNativeAdRendererConfiguration.h>
#import <MoPubSDK/MPStaticNativeAdRendererSettings.h>
#import <MoPubSDK/MPStaticNativeAdRenderer.h>
#import <MoPubSDK/MPNativeAdRequestTargeting.h>
#import <MoPubSDK/MPNativeAdConstants.h>

@interface PNLiteDemoMoPubMediationNativeViewController () <MPNativeAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *nativeAdContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nativeAdLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, weak) UIView *nativeAdView;
@property (nonatomic, strong) MPNativeAdRequest *request;
@property (nonatomic, strong) MPNativeAd *nativeAd;
@property (nonatomic, strong) MPNativeAdRendererImageHandler *imageHandler;

@end

@implementation PNLiteDemoMoPubMediationNativeViewController

- (void)dealloc {
    self.request = nil;
    self.nativeAd = nil;
    self.imageHandler = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Mediation Native";
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
    
    if(!self.imageHandler) {
        self.imageHandler = [[MPNativeAdRendererImageHandler alloc] init];
    }
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    settings.renderingViewClass = [PNLiteDemoMoPubMediationNativeView class];
    MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
    config.supportedCustomEvents = @[@"HyBidMoPubMediationNativeAdCustomEvent"];
    
    self.request = [MPNativeAdRequest requestWithAdUnitIdentifier:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubMediationNativeAdUnitIDKey]
                                           rendererConfigurations:@[config]];
    
    MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
    targeting.desiredAssets = [NSSet setWithObjects:kAdTitleKey, kAdTextKey, kAdCTATextKey, kAdIconImageKey, kAdMainImageKey, kAdStarRatingKey, nil];
    self.request.targeting = targeting;
    
    __block PNLiteDemoMoPubMediationNativeViewController *strongSelf = self;
    [self.request startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if(!error) {
            self.inspectRequestButton.hidden = NO;
            [strongSelf processResponse:response];
        } else {
            self.inspectRequestButton.hidden = NO;
            [self showAlertControllerWithMessage:[NSString stringWithFormat:@"MoPub Mediation Native Ad - Downloading Error: %@", error]];
            NSLog(@"MoPub Mediation Native Ad - Downloading Error: %@", error);
        }
        [strongSelf.nativeAdLoaderIndicator stopAnimating];
        strongSelf = nil;
    }];
}

- (void)processResponse:(MPNativeAd *)ad {
    self.nativeAd = ad;
    self.nativeAd.delegate = self;
    
    NSError *error = nil;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = [ad retrieveAdViewWithError:&error];
    if(!error) {
        self.nativeAdView.frame = self.nativeAdContainer.bounds;
        [self.nativeAdContainer addSubview:self.nativeAdView];
        self.nativeAdContainer.hidden = NO;
    } else {
        [self showAlertControllerWithMessage:[NSString stringWithFormat:@"MoPub Mediation Native Ad - Rendering Error: %@", error]];
        NSLog(@"MoPub Mediation Native Ad - Rendering Error: %@", error);
    }
}

#pragma mark - MPNativeAdDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)willPresentModalForNativeAd:(MPNativeAd *)nativeAd {
    NSLog(@"willPresentModalForNativeAd");
}

- (void)didDismissModalForNativeAd:(MPNativeAd *)nativeAd {
    NSLog(@"didDismissModalForNativeAd");
}

- (void)willLeaveApplicationFromNativeAd:(MPNativeAd *)nativeAd {
    NSLog(@"willLeaveApplicationFromNativeAd");
}

@end
