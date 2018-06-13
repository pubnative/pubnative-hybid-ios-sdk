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

@interface PNLiteDemoPNLiteBannerViewController () <PNLiteAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet PNLiteBannerAdView *bannerAdView;

@end

@implementation PNLiteDemoPNLiteBannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"PNLite Banner";
    [self.bannerLoaderIndicator stopAnimating];
}

- (IBAction)requestBannerTouchUpInside:(id)sender
{
    self.bannerAdView.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    [self.bannerAdView loadWithZoneID:[PNLiteDemoSettings sharedInstance].zoneID andWithDelegate:self];
}

#pragma mark - PNLiteAdViewDelegate

-(void)adViewDidLoad
{
    NSLog(@"Banner Ad View did load:");
    self.bannerAdView.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)adViewDidFailWithError:(NSError *)error
{
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)adViewDidTrackClick
{
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression
{
    NSLog(@"Banner Ad View did track impression:");
}

@end
