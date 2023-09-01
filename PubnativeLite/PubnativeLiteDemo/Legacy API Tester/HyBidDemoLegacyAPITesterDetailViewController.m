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


#import "HyBidDemoLegacyAPITesterDetailViewController.h"
#import <HyBid/HyBid.h>

@interface HyBidDemoLegacyAPITesterDetailViewController () <HyBidAdViewDelegate, HyBidInterstitialAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *adViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) HyBidAdView *adView;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;

@end

@implementation HyBidDemoLegacyAPITesterDetailViewController

- (void)dealloc {
    self.adResponse = nil;
    self.debugButton = nil;
    self.adView = nil;
    self.interstitialAd = nil;
    self.rewardedAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.placement) {
        case HyBidDemoAppPlacementBanner:
        case HyBidDemoAppPlacementMRect:
        case HyBidDemoAppPlacementLeaderboard: {
            [self prepareAdViewForPlacement:self.placement];
            break;
        }
        case HyBidDemoAppPlacementInterstitial: {
            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
            if (self.adResponse != nil) {
                [self.interstitialAd prepareAdWithAdReponse: self.adResponse];
            }
            break;
        }
        case HyBidDemoAppPlacementRewarded: {
            self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:nil andWithDelegate:self];
            if (self.adResponse != nil) {
                [self.rewardedAd prepareAdWithAdReponse:self.adResponse];
            }
            break;
        }
        default:
            break;
    }
}

- (void)prepareAdViewForPlacement:(HyBidDemoAppPlacement)placement {
    switch (self.placement){
        case HyBidDemoAppPlacementBanner: {
            self.adViewContainerWidthConstraint.constant = 320;
            self.adViewContainerHeightConstraint.constant = 50;
            self.adView = [[HyBidAdView alloc] initWithSize:HyBidAdSize.SIZE_320x50];
            break;
        }
        case HyBidDemoAppPlacementMRect: {
            self.adViewContainerWidthConstraint.constant = 300;
            self.adViewContainerHeightConstraint.constant = 250;
            self.adView = [[HyBidAdView alloc] initWithSize:HyBidAdSize.SIZE_300x250];
            break;
        }
        case HyBidDemoAppPlacementLeaderboard: {
            self.adViewContainerWidthConstraint.constant = 728;
            self.adViewContainerHeightConstraint.constant = 90;
            self.adView = [[HyBidAdView alloc] initWithSize:HyBidAdSize.SIZE_728x90];
            break;
        }
        case HyBidDemoAppPlacementInterstitial:
        case HyBidDemoAppPlacementRewarded:
            break;
    }
    [self.adView setAccessibilityIdentifier:@"adViewLegacyAPI"];
    self.adView.delegate = self;
    [self.adViewContainer addSubview:self.adView];
    self.adView.hidden = YES;
    [self.adView renderAdWithAdResponse:self.adResponse withDelegate:self];
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)showButtonTouchUpInside:(UIButton *)sender {
    switch (self.placement) {
        case HyBidDemoAppPlacementBanner:
        case HyBidDemoAppPlacementMRect:
        case HyBidDemoAppPlacementLeaderboard:
            self.adView.hidden = NO;
            break;
        case HyBidDemoAppPlacementInterstitial:
            [self.interstitialAd show];
            [self.showAdButton setEnabled: NO];
            break;
        case HyBidDemoAppPlacementRewarded:
            [self.rewardedAd show];
            [self.showAdButton setEnabled: NO];
            break;
    }
}

- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
    self.showAdButton.hidden = NO;
    self.debugButton.hidden = NO;
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
    self.debugButton.hidden = NO;
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track impression:");
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    self.showAdButton.hidden = NO;
    self.debugButton.hidden = NO;
}

- (void)interstitialDidFailWithError:(NSError *)error {
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
    self.debugButton.hidden = NO;
}

- (void)interstitialDidTrackClick {
    NSLog(@"Interstitial did track click");
}

- (void)interstitialDidTrackImpression {
    NSLog(@"Interstitial did track impression");
}

- (void)interstitialDidDismiss {
    NSLog(@"Interstitial did dismiss");
}

#pragma mark - HyBidRewardedAdDelegate

-(void)rewardedDidLoad {
    NSLog(@"Rewarded did load");
    self.showAdButton.hidden = NO;
    self.debugButton.hidden = NO;
}

-(void)rewardedDidFailWithError:(NSError *)error {
    NSLog(@"Rewarded did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
    self.debugButton.hidden = NO;
}

-(void)rewardedDidTrackClick {
    NSLog(@"Rewarded did track click");
}

-(void)rewardedDidTrackImpression {
    NSLog(@"Rewarded did track impression");
}

-(void)rewardedDidDismiss {
    NSLog(@"Rewarded did dismiss");
}

- (void)onReward {
    NSLog(@"Rewarded did reward");
}

@end
