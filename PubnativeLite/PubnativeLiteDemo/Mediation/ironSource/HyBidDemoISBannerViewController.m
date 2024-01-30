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

#import "HyBidDemoISBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "IronSource/IronSource.h"

@interface HyBidDemoISBannerViewController () <LevelPlayBannerDelegate, ISInitializationDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) ISBannerView *ironSourceBanner;

@end

@implementation HyBidDemoISBannerViewController

- (void)dealloc {
    [IronSource destroyBanner:self.ironSourceBanner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"IS Banner";
    [IronSource initWithAppKey:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey] adUnits:@[IS_BANNER] delegate:self];
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self destroyBanner];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    if (self.ironSourceBanner) {
        [self destroyBanner];
    }
    [self requestAd];
}

- (void)destroyBanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.ironSourceBanner) {
            [IronSource destroyBanner:self.ironSourceBanner];
            self.ironSourceBanner = nil;
        }
    });
}

- (void)requestAd {
    [self clearDebugTools];
    self.bannerContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    [IronSource setLevelPlayBannerDelegate:self];
    [IronSource loadBannerWithViewController:self size:ISBannerSize_BANNER];
}

#pragma mark - LevelPlayBannerDelegate

- (void)didLoad:(ISBannerView *)bannerView withAdInfo:(ISAdInfo *)adInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ironSourceBanner = bannerView;
        self.ironSourceBanner.frame = CGRectMake(0, 0, self.bannerContainer.frame.size.width, self.bannerContainer.frame.size.height);
        self.bannerContainer.hidden = NO;
        self.debugButton.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
        [self.bannerContainer addSubview:self.ironSourceBanner];

        [self.bannerContainer setIsAccessibilityElement:NO];
        [self.bannerContainer setAccessibilityContainerType:UIAccessibilityContainerTypeSemanticGroup];
    });
}

- (void)didFailToLoadWithError:(NSError *)error{
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"IronSource Banner did fail to load with message:%@", error.localizedDescription]];
}

- (void)didClickWithAdInfo:(ISAdInfo *)adInfo{
    NSLog(@"didClickAd");
}

- (void)didLeaveApplicationWithAdInfo:(ISAdInfo *)adInfo{
    NSLog(@"didLeaveApplication");
}

- (void)didPresentScreenWithAdInfo:(ISAdInfo *)adInfo{
    NSLog(@"didPresentScreen");
}

- (void)didDismissScreenWithAdInfo:(ISAdInfo *)adInfo{
    NSLog(@"didDismissScreen");
}

#pragma mark - ISInitializationDelegate

- (void)initializationDidComplete {
    
}

@end
