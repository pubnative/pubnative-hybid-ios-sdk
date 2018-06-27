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

@interface PNLiteDemoPNLiteInterstitialViewController () <PNLiteInterstitialAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (nonatomic, strong) PNLiteInterstitialAd *interstitialAd;

@end

@implementation PNLiteDemoPNLiteInterstitialViewController

- (void)dealloc
{
    self.interstitialAd = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"PubNative Lite Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender
{
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAd = [[PNLiteInterstitialAd alloc] initWithZoneID:[PNLiteDemoSettings sharedInstance].zoneID andWithDelegate:self];
    [self.interstitialAd load];
}

#pragma mark - PNLiteInterstitialAdDelegate

- (void)interstitialDidLoad
{
    NSLog(@"Interstitial did load");
    [self.interstitialLoaderIndicator stopAnimating];
    [self.interstitialAd show];
}

- (void)interstitialDidFailWithError:(NSError *)error
{
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
    [self.interstitialLoaderIndicator stopAnimating];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"PNLite Demo"
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)interstitialDidTrackClick
{
    NSLog(@"Interstitial did track click");
}

- (void)interstitialDidTrackImpression
{
    NSLog(@"Interstitial did track impression");
}

- (void)interstitialDidDismiss
{
    NSLog(@"Interstitial did dismiss");
}

@end
