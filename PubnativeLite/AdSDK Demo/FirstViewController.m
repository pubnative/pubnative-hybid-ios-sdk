//
//  FirstViewController.m
//  AdSDK Demo
//
//  Created by Eros Garcia Ponte on 25.03.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "FirstViewController.h"
#import <HyBid/HyBid.h>

@interface FirstViewController () <HyBidAdViewDelegate>

@property (weak, nonatomic) IBOutlet HyBidAdView *bannerAdView;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    self.bannerAdView.adSize = HyBidAdSize.SIZE_320x50;
    [self.bannerAdView loadWithDelegate:self];
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

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
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
