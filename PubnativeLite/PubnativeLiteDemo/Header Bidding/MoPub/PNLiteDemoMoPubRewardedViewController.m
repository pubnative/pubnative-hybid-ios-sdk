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
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) HyBidRewardedAdRequest *rewardedAdRequest;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@end

@implementation PNLiteDemoMoPubRewardedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Header Bidding Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    [self requestAd];
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
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    
    self.rewardedAdRequest = [[HyBidRewardedAdRequest alloc] init];
    [self.rewardedAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - MPRewardedAdsDelegate

- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID {
    NSLog(@"rewardedAdDidLoadAd");
    self.inspectRequestButton.hidden = NO;
    self.showAdButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
}

- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    NSLog(@"rewardedAdDidFailToLoadAd, %@", error.localizedDescription);
    self.inspectRequestButton.hidden = NO;
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
    
    if (request == self.rewardedAdRequest) {
        self.inspectRequestButton.hidden = NO;
        
        NSString *adUnitId = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey];
        NSString *keywords = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsStringWithAd:ad];

        [MPRewardedAds setDelegate:self forAdUnitId:adUnitId];
        [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitId keywords:keywords userDataKeywords:nil mediationSettings:nil];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    if (request == self.rewardedAdRequest) {
        self.inspectRequestButton.hidden = NO;
        [self.rewardedLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}

@end
