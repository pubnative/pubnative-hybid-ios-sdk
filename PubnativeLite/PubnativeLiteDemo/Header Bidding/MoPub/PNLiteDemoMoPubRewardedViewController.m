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

#import "PNLiteDemoMoPubRewardedViewController.h"
#import <MoPubSDK/MPRewardedAds.h>
#import "HyBidRewardedAdRequest.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubRewardedViewController () <HyBidAdRequestDelegate, MPRewardedAdsDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) HyBidRewardedAdRequest *rewardedAdRequest;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet UISwitch *adCachingSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showAdTopConstraint;

@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation PNLiteDemoMoPubRewardedViewController


- (void)dealloc
{
    self.rewardedAdRequest = nil;
    self.ad = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Header Bidding Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
    
    self.showAdTopConstraint.constant = 8.0;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    [self requestAd];
}

- (IBAction)adCachingSwitchValueChanged:(UISwitch *)sender {
    self.prepareButton.hidden = sender.isOn;
    self.showAdTopConstraint.constant = sender.isOn ? 8.0 : 46.0;
    [self.showAdButton setNeedsDisplay];
}

- (IBAction)prepareButtonTapped:(UIButton *)sender {
    if (self.ad != nil && self.rewardedAdRequest != nil) {
        [self.rewardedAdRequest cacheAd:self.ad];
    }
}

- (IBAction)showRewardedTouchUpInside:(id)sender {
    NSString *adUnitId = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey];
    
    if ([[MPRewardedAds availableRewardsForAdUnitID:adUnitId] firstObject] != nil) {
        MPReward *reward = [[MPRewardedAds availableRewardsForAdUnitID:adUnitId] firstObject];
        [MPRewardedAds presentRewardedAdForAdUnitID:adUnitId fromViewController:self withReward:reward];
    }
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    
    self.rewardedAdRequest = [[HyBidRewardedAdRequest alloc] init];
    [self.rewardedAdRequest setIsAutoCacheOnLoad:self.adCachingSwitch.isOn];
    [self.rewardedAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - MPRewardedAdsDelegate

- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdDidLoadAd");
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    self.prepareButton.enabled = !self.adCachingSwitch.isOn;
    self.showAdButton.enabled = YES;
    [self.rewardedLoaderIndicator stopAnimating];
}

- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    NSLog(@"rewardedAdDidFailToLoadAd, %@", error.localizedDescription);
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.debugButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:@"MoPub Rewarded did fail to load."];
}

- (void)rewardedAdDidExpireForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdDidExpire");
}

- (void)rewardedAdDidFailToShowForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    NSLog(@"rewardedAdDidFailToLoadAd");
    [self showAlertControllerWithMessage:@"MoPub Rewarded did fail to show."];
}

- (void)rewardedAdWillPresentForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdWillPresent");
}

- (void)rewardedAdDidPresentForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdDidPresent");
}

- (void)rewardedAdWillDismissForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdWillDismiss");
    self.showAdButton.hidden = YES;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
}

- (void)rewardedAdDidDismissForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdDidDismiss");
}

- (void)rewardedAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdDidReceiveTapEvent");
}

- (void)rewardedAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdWillLeaveApplication");
}

- (void)rewardedAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPReward *)reward {
    NSLog(@"rewardedAdShouldReward");
}

- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData {
    NSLog(@"rewardedAdDidTrackImpression");
}

#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    [self setCreativeIDLabelWithString:ad.creativeID];
    self.ad = ad;
    
    if (request == self.rewardedAdRequest) {
        self.debugButton.hidden = NO;
        
        NSString *keywords = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsStringWithAd:ad];

        [MPRewardedAds setDelegate:self forAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey]];
        [MPRewardedAds loadRewardedAdWithAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey] keywords:keywords userDataKeywords:nil mediationSettings:nil];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    self.ad = nil;
    if (request == self.rewardedAdRequest) {
        self.debugButton.hidden = NO;
        [self.rewardedLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
        [MPRewardedAds loadRewardedAdWithAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey] withMediationSettings:nil];
    }
}

@end
