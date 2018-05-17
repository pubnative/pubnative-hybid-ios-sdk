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

#import "PNLiteDemoPNLiteBannerViewController.h"
#import <PubnativeLite/PubnativeLite.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteBannerViewController () <PNLiteAdRequestDelegate, PNLiteBannerPresenterDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (nonatomic, strong) PNLiteBannerAdRequest *bannerAdRequest;
@property (nonatomic, strong) PNLiteBannerPresenter *bannerPresenter;
@property (nonatomic, strong) PNLiteBannerPresenterFactory *bannerPresenterFactory;

@end

@implementation PNLiteDemoPNLiteBannerViewController

- (void)dealloc
{
    self.bannerAdRequest = nil;
    self.bannerPresenter = nil;
    self.bannerPresenterFactory = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"PNLite Banner";
    [self.bannerLoaderIndicator stopAnimating];
}

- (IBAction)requestBannerTouchUpInside:(id)sender
{
    self.bannerContainer.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    self.bannerAdRequest = [[PNLiteBannerAdRequest alloc] init];
    [self.bannerAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
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
        self.bannerPresenterFactory = [[PNLiteBannerPresenterFactory alloc] init];
        self.bannerPresenter = [self.bannerPresenterFactory createBannerPresenterWithAd:ad withDelegate:self];
        if (self.bannerPresenter == nil) {
            NSLog(@"PubNativeLite - Error: Could not create valid banner presenter");
            return;
        } else {
            [self.bannerPresenter load];
        }
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PNLite Demo" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
    
    if (request == self.bannerAdRequest) {
        [self.bannerLoaderIndicator stopAnimating];
    }
}

- (void)removeAllSubViewsFrom:(UIView *)view
{
    NSArray *viewsToRemove = [view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

#pragma mark - PNLiteAdRequestDelegate

- (void)bannerPresenter:(PNLiteBannerPresenter *)bannerPresenter didLoadWithBanner:(UIView *)banner
{
    [self removeAllSubViewsFrom:self.bannerContainer];
    [self.bannerContainer addSubview:banner];
    self.bannerContainer.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)bannerPresenter:(PNLiteBannerPresenter *)bannerPresenter didFailWithError:(NSError *)error
{
    NSLog(@"Banner Presenter %@ failed with error: %@",bannerPresenter,error.localizedDescription);
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)bannerPresenterDidClick:(PNLiteBannerPresenter *)bannerPresenter
{
    NSLog(@"Banner Presenter %@ did click:",bannerPresenter);
}

@end
