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

#import "HyBidDemoISInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "IronSource/IronSource.h"

@interface HyBidDemoISInterstitialViewController () <ISInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@end

@implementation HyBidDemoISInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"IS Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    [IronSource setInterstitialDelegate:self];
    [IronSource loadInterstitial];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if ([IronSource hasInterstitial]) {
        [IronSource showInterstitialWithViewController:self];
    }
}

#pragma mark - ISInterstitialDelegate

-(void)interstitialDidLoad {
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
}

-(void)interstitialDidFailToLoadWithError:(NSError *)error {
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"ironSource Interstitial did fail to load: %@", error.localizedDescription]];
}

-(void)interstitialDidClose {
    self.showAdButton.hidden = YES;
}

-(void)interstitialDidFailToShowWithError:(NSError *)error {
    NSLog(@"interstitialDidFailToShowWithError");
}

-(void)didClickInterstitial {
    NSLog(@"didClickInterstitial");
}

-(void)interstitialDidOpen {
    NSLog(@"interstitialDidOpen");
}

-(void)interstitialDidShow {
    NSLog(@"interstitialDidShow");
}

@end
