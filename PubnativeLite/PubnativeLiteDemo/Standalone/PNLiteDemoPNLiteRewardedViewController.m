//
//  PNLiteDemoPNLiteRewardedViewController.m
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "PNLiteDemoPNLiteRewardedViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "HyBidRewardedAd.h"

@interface PNLiteDemoPNLiteRewardedViewController () <HyBidRewardedAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;

@end

@implementation PNLiteDemoPNLiteRewardedViewController

- (void)dealloc {
    self.rewardedAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"HyBid Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    [self requestAd];
}

- (IBAction)showRewardedAdButtonTapped:(id)sender {
    if (self.rewardedAd.isReady) {
        [self.rewardedAd show];
    }
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    
    self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
    [self.rewardedAd load];
    
    NSDictionary *properties=[[NSDictionary alloc] initWithObjectsAndKeys:HyBidReportingAdFormat.REWARDED, HyBidReportingCommon.AD_FORMAT, nil];
    [self reportEvent:HyBidReportingEventType.AD_REQUEST properties:properties];
}

#pragma mark - HyBidRewardedAdDelegate

- (void)rewardedDidLoad {
    NSLog(@"Rewarded did load");
    self.inspectRequestButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
}

- (void)rewardedDidFailWithError:(NSError *)error {
    NSLog(@"Rewarded did fail with error: %@",error.localizedDescription);
    self.inspectRequestButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)rewardedDidTrackClick {
    NSLog(@"Rewarded did track click");
}

- (void)rewardedDidTrackImpression {
    NSLog(@"Rewarded did track impression");
}

- (void)rewardedDidDismiss {
    NSLog(@"Rewarded did dismiss");
}

- (void)onReward
{
    NSLog(@"Rewarded.");
}

@end
