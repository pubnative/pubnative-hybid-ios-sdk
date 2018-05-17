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
#import <PubnativeLite/PubnativeLite.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteInterstitialViewController () <PNLiteAdRequestDelegate, PNLiteInterstitialPresenterDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (nonatomic, strong) PNLiteInterstitialAdRequest *interstitialAdRequest;
@property (nonatomic, strong) PNLiteInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) PNLiteInterstitialPresenterFactory *interstitalPresenterFactory;

@end

@implementation PNLiteDemoPNLiteInterstitialViewController

- (void)dealloc
{
    self.interstitialAdRequest = nil;
    self.interstitialPresenter = nil;
    self.interstitalPresenterFactory = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"PNLite Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender
{
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAdRequest = [[PNLiteInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
}

#pragma mark - PNLiteAdRequestDelegate

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    if (request == self.interstitialAdRequest) {
        self.interstitalPresenterFactory = [[PNLiteInterstitialPresenterFactory alloc] init];
        self.interstitialPresenter = [self.interstitalPresenterFactory createInterstitalPresenterWithAd:ad withDelegate:self];
        if (self.interstitialPresenter == nil) {
            NSLog(@"PubNativeLite - Error: Could not create valid interstitial presenter");
            return;
        } else {
            [self.interstitialPresenter load];
        }
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PNLite Demo" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
    
    [self.interstitialLoaderIndicator stopAnimating];
}

#pragma mark - PNLiteInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    NSLog(@"Interstitial Presenter %@ did load:",interstitialPresenter);
    [self.interstitialLoaderIndicator stopAnimating];
    [self.interstitialPresenter show];
}

- (void)interstitialPresenterDidShow:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    NSLog(@"Interstitial Presenter %@ did show:",interstitialPresenter);
}

- (void)interstitialPresenterDidClick:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    NSLog(@"Interstitial Presenter %@ did click:",interstitialPresenter);
}

- (void)interstitialPresenterDidDismiss:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    NSLog(@"Interstitial Presenter %@ did dismiss:",interstitialPresenter);
}

- (void)interstitialPresenter:(PNLiteInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error
{
    NSLog(@"Interstitial Presenter %@ failed with error: %@",interstitialPresenter,error.localizedDescription);
    [self.interstitialLoaderIndicator stopAnimating];
}

@end
