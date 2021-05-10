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
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

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
    [self reportEvent:HyBidReportingEventType.AD_REQUEST adFormat: HyBidReportingAdFormat.REWARDED properties:nil];
    [self requestAd];
}

- (IBAction)showRewardedAdButtonTapped:(id)sender {
    if (self.rewardedAd.isReady) {
        [self.rewardedAd show];
    }
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearLastInspectedRequest];
    self.inspectRequestButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    
    self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
    [self.rewardedAd load];
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidRewardedAdDelegate

- (void)rewardedDidLoad {
    NSLog(@"Rewarded did load");
    [self setCreativeIDLabelWithString:self.rewardedAd.ad.creativeID];
    self.inspectRequestButton.hidden = NO;
    self.showAdButton.hidden = NO;
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
    self.showAdButton.hidden = YES;
}

- (void)onReward {
    NSLog(@"Rewarded.");
}

@end
