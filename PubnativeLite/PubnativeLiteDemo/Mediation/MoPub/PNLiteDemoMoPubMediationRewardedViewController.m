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

#import "PNLiteDemoMoPubMediationRewardedViewController.h"
#import <MoPub/MPRewardedVideo.h>
#import <MoPub/MPRewardedVideoReward.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubMediationRewardedViewController () <MPRewardedVideoDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;

@end

@implementation PNLiteDemoMoPubMediationRewardedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Mediation Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    [self requestAd];
}

- (IBAction)showRewardedTouchUpInside:(id)sender {
    NSString *adUnitId = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubMediationRewardedAdUnitIDKey];
    
    if ([[MPRewardedVideo availableRewardsForAdUnitID:adUnitId] firstObject] != nil) {
        MPRewardedVideoReward *reward = [[MPRewardedVideo availableRewardsForAdUnitID:adUnitId] firstObject];
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitId fromViewController:self withReward:reward];
    }
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    
    NSString *adUnitId = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubMediationRewardedAdUnitIDKey];
    
    [MPRewardedVideo setDelegate:self forAdUnitId:adUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitId withMediationSettings:nil];
}

#pragma mark - MPRewardedAdControllerDelegate

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"rewardedDidLoadAd");
    self.inspectRequestButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
    NSLog(@"rewardedDidFailToLoadAd");
    self.inspectRequestButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:@"MoPub Rewarded did fail to load."];
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"rewardedDidExpire");
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
    NSLog(@"rewardedDidFailToPlay");
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"rewardedWillAppear");
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"rewardedDidAppear");
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"rewardedWillDisappear");
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"rewardedDidDisappear");
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"rewardedDidReceiveTapEvent");
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward
{
    NSLog(@"rewardedShouldReward");
}

- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData
{
    NSLog(@"rewardedDidTrackImpression");
}

@end
