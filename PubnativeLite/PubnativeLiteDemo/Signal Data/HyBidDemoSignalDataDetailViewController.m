//
//  Copyright © 2020 PubNative. All rights reserved.
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


#import "HyBidDemoSignalDataDetailViewController.h"
#import <HyBid/HyBid.h>

@interface HyBidDemoSignalDataDetailViewController () <HyBidAdViewDelegate>

@property (weak, nonatomic) IBOutlet HyBidAdView *bannerAdView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdViewContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdViewContainerHeightConstraint;

@end

@implementation HyBidDemoSignalDataDetailViewController

- (void)dealloc {
    self.signalData = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch ([self.signalData.placement integerValue]) {
        case 0: {
            self.bannerAdViewContainerWidthConstraint.constant = 320;
            self.bannerAdViewContainerHeightConstraint.constant = 50;
            self.bannerAdView.adSize = HyBidAdSize.SIZE_320x50;
            break;
        }
        case 1: {
            self.bannerAdViewContainerWidthConstraint.constant = 300;
            self.bannerAdViewContainerHeightConstraint.constant = 250;
            self.bannerAdView.adSize = HyBidAdSize.SIZE_300x250;
            break;
        }
        case 2: {
            self.bannerAdViewContainerWidthConstraint.constant = 728;
            self.bannerAdViewContainerHeightConstraint.constant = 90;
            self.bannerAdView.adSize = HyBidAdSize.SIZE_728x90;
            break;
        }
        default:
            break;
    }
    
    [self.bannerAdView renderAdWithContent:self.signalData.text withDelegate:self];

}


- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
    self.bannerAdView.hidden = NO;
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track impression:");
}

@end
