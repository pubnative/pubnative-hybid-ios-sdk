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

#import "PNLiteDemoMoPubMRectViewController.h"
#import <PubnativeLite/PubnativeLite.h>
#import "MPAdView.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubMRectViewController () <PNLiteAdRequestDelegate, MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mRectContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (nonatomic, strong) MPAdView *moPubMrect;
@property (nonatomic, strong) PNLiteMRectAdRequest *mRectAdRequest;

@end

@implementation PNLiteDemoMoPubMRectViewController

- (void)dealloc
{
    self.moPubMrect = nil;
    self.mRectAdRequest = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"MRect";
    
    [self.mRectLoaderIndicator stopAnimating];
    self.moPubMrect = [[MPAdView alloc] initWithAdUnitId:[PNLiteDemoSettings sharedInstance].moPubMRectAdUnitID
                                                    size:MOPUB_MEDIUM_RECT_SIZE];
    self.moPubMrect.delegate = self;
    [self.moPubMrect stopAutomaticallyRefreshingContents];
    [self.mRectContainer addSubview:self.moPubMrect];
}

- (IBAction)requestMRectTouchUpInside:(id)sender
{
    self.mRectContainer.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    self.mRectAdRequest = [[PNLiteMRectAdRequest alloc] init];
    [self.mRectAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    NSLog(@"adViewDidLoadAd");
    if (self.moPubMrect == view) {
        self.mRectContainer.hidden = NO;
        [self.mRectLoaderIndicator stopAnimating];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    NSLog(@"adViewDidFailToLoadAd");
    if (self.moPubMrect == view) {
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
    
    if (request == self.mRectAdRequest) {
        [self.moPubMrect setKeywords:[PNLitePrebidUtils createPrebidKeywordsStringWithAd:ad withZoneID:[PNLiteDemoSettings sharedInstance].zoneID]];
        [self.moPubMrect loadAd];
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PNLite Demo" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
    
     if (request == self.mRectAdRequest) {
        [self.mRectLoaderIndicator stopAnimating];
    }
}

@end
