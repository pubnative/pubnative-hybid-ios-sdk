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

#import "HyBidDemoChartboostMRectViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import <ChartboostSDK/Chartboost.h>

@interface HyBidDemoChartboostMRectViewController () <CHBBannerDelegate>

@property (weak, nonatomic) IBOutlet UIView *mRectContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitch;
@property (nonatomic, strong) CHBBanner *mRect;

@end

@implementation HyBidDemoChartboostMRectViewController

- (void)dealloc {
    self.mRect = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Chartboost Mediation MRect";
    [self.mRectLoaderIndicator stopAnimating];
}

- (IBAction)requestMRectTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.mRectContainer.hidden = YES;
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    self.mRect = [[CHBBanner alloc] initWithSize:CHBBannerSizeMedium location:self.videoSwitch.isOn ? [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostMRectVideoPositionKey] : [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostMRectHTMLPositionKey] delegate:self];
    [self.mRect cache];
}

- (IBAction)showMRectAdButtonTapped:(UIButton *)sender {
    if (self.mRect.isCached) {
        [self.mRectContainer addSubview:self.mRect];
        self.mRectContainer.hidden = NO;
        [self.mRect showFromViewController:self];
    } else {
        NSLog(@"Tried to show a MRect ad before it is cached");
    }
}

#pragma mark - CHBBannerDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didCacheAd: %@ %@", [event.ad class], [self statusWithError:error]]);
    if (error) {
        self.showAdButton.hidden = YES;
    } else {
        self.showAdButton.hidden = NO;
    }
    [self.mRectLoaderIndicator stopAnimating];
    self.debugButton.hidden = NO;
}

- (void)willShowAd:(CHBShowEvent *)event {
    NSLog(@"%@", [NSString stringWithFormat:@"willShowAd: %@", [event.ad class]]);
}

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didShowAd: %@ %@", [event.ad class], [self statusWithError:error]]);
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didClickAd: %@ %@", [event.ad class], [self statusWithError:error]]);
}

- (void)didRecordImpression:(CHBImpressionEvent *)event {
    NSLog(@"%@", [NSString stringWithFormat:@"didRecordImpression: %@", [event.ad class]]);
}

- (NSString *)statusWithError:(id)error {
    return error ? [NSString stringWithFormat:@"FAILED (%@)", error] : @"SUCCESS";
}

@end
