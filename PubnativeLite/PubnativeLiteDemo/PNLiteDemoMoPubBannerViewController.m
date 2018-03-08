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
#import <PubnativeLite/PubnativeLite.h>
#import "MPAdView.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubBannerViewController () <PNLiteAdRequestDelegate, MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIView *mRectContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;

@property (nonatomic, strong) MPAdView *moPubBanner;
@property (nonatomic, strong) MPAdView *moPubMrect;
@property (nonatomic, strong) PNLiteBannerAdRequest *bannerAdRequest;
@property (nonatomic, strong) PNLiteMRectAdRequest *mRectAdRequest;

@end

@implementation PNLiteDemoMoPubBannerViewController

- (void)dealloc
{
    self.moPubBanner = nil;
    self.moPubMrect = nil;
    self.bannerAdRequest = nil;
    self.mRectAdRequest = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Banner";

    [self.bannerLoaderIndicator stopAnimating];
    [self.mRectLoaderIndicator stopAnimating];
    
    self.moPubBanner = [[MPAdView alloc] initWithAdUnitId:[PNLiteDemoSettings sharedInstance].moPubBannerAdUnitID
                                                     size:MOPUB_BANNER_SIZE];
    self.moPubBanner.delegate = self;
    [self.moPubBanner stopAutomaticallyRefreshingContents];
    [self.bannerContainer addSubview:self.moPubBanner];
    
    self.moPubMrect = [[MPAdView alloc] initWithAdUnitId:[PNLiteDemoSettings sharedInstance].moPubMRectAdUnitID
                                                    size:MOPUB_MEDIUM_RECT_SIZE];
    self.moPubMrect.delegate = self;
    [self.moPubMrect stopAutomaticallyRefreshingContents];
    [self.mRectContainer addSubview:self.moPubMrect];
}

- (IBAction)requestBannerTouchUpInside:(id)sender
{
    self.bannerContainer.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    self.bannerAdRequest = [[PNLiteBannerAdRequest alloc] init];
    [self.bannerAdRequest requestAdWithDelegate:self withZoneID:@"2"];
}

- (IBAction)requestMRectTouchUpInside:(id)sender
{
    self.mRectContainer.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    self.mRectAdRequest = [[PNLiteMRectAdRequest alloc] init];
    [self.mRectAdRequest requestAdWithDelegate:self withZoneID:@"3"];
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    NSLog(@"adViewDidLoadAd");
    if (self.moPubBanner == view) {
        self.bannerContainer.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
    } else if (self.moPubMrect == view) {
        self.mRectContainer.hidden = NO;
        [self.mRectLoaderIndicator stopAnimating];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    NSLog(@"adViewDidFailToLoadAd");
    if (self.moPubBanner == view) {
        [self.bannerLoaderIndicator stopAnimating];
    } else if (self.moPubMrect == view) {
        [self.mRectLoaderIndicator stopAnimating];
    }
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
    NSLog(@"willPresentModalViewForAd");
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
    NSLog(@"didDismissModalViewForAd");
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view
{
    NSLog(@"willLeaveApplicationFromAd");
}

#pragma mark - PNLiteAdRequestDelegate

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    
    if (request == self.bannerAdRequest) {
        [self.moPubBanner setKeywords:[PNLitePrebidUtils createPrebidKeywordsWithAd:ad withZoneID:@"2"]];
        [self.moPubBanner loadAd];
    } else if (request == self.mRectAdRequest) {
        [self.moPubMrect setKeywords:[PNLitePrebidUtils createPrebidKeywordsWithAd:ad withZoneID:@"3"]];
        [self.moPubMrect loadAd];
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    if (request == self.bannerAdRequest) {
        [self.bannerLoaderIndicator stopAnimating];
    } else if (request == self.mRectAdRequest) {
        [self.mRectLoaderIndicator stopAnimating];
    }
}

@end
