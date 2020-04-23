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

#import "VideoInterstitialViewController.h"

#ifdef STATIC_LIB
    #import <HyBidStatic/HyBidStatic.h>
#else
    #import <HyBid/HyBid.h>
#endif

@interface VideoInterstitialViewController () <VWInterstitialVideoAdDelegate>

@property (nonatomic, strong) VWInterstitialVideoAd *videoInterstitialAd;

@end

@implementation VideoInterstitialViewController

- (void)dealloc {
    self.videoInterstitialAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    self.videoInterstitialAd = [VWInterstitialVideoAd new];
    self.videoInterstitialAd.allowAutoPlay = YES;
    self.videoInterstitialAd.allowAudioOnStart = YES;
    self.videoInterstitialAd.delegate = self;
    VWVideoAdRequest * adRequest = [VWVideoAdRequest requestWithContentCategoryID:VWContentCategoryNewsAndInformation];
    adRequest.minDuration = @(10);
    adRequest.maxDuration = @(90);
    [self.videoInterstitialAd loadRequest:adRequest];
}

- (void)showAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"I have a bad feeling about this... 🙄"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestAd];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - VWInterstitialVideoAdDelegate

- (void)interstitialVideoAdReceiveAd:(VWInterstitialVideoAd *)interstitialVideoAd {
    NSLog(@"Video Interstitial Ad did load:");
    [interstitialVideoAd presentFromViewController:self];
}

- (void)interstitialVideoAd:(VWInterstitialVideoAd *)interstitialVideoAd didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Video Interstitial Ad did fail with error: %@",error.localizedDescription);
       [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)interstitialVideoAdWillPresentAd:(VWInterstitialVideoAd *)interstitialVideoAd {
    NSLog(@"Video Interstitial Ad will present:");
}

- (void)interstitialVideoAdWillDismissAd:(VWInterstitialVideoAd *)interstitialVideoAd {
    NSLog(@"Video Interstitial Ad will dismiss:");
}

- (void)interstitialVideoAdDidDismissAd:(VWInterstitialVideoAd *)interstitialVideoAd {
    NSLog(@"Video Interstitial Ad did dismiss:");
}

@end
