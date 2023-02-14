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

#import "HyBidDemoLegacyAPITesterMainViewController.h"
#import "HyBidDemoLegacyAPITesterDetailViewController.h"
#import <HyBid/HyBid.h>
#import "UITextView+KeyboardDismiss.h"

@interface HyBidDemoLegacyAPITesterMainViewController () <HyBidInterstitialAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardedButton;
@property (weak, nonatomic) IBOutlet UITextView *adReponseTextView;
@property (nonatomic, retain) NSNumber *placement;
@property (nonatomic, strong) NSString *adReponse;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;

@end

@implementation HyBidDemoLegacyAPITesterMainViewController

- (void)dealloc {
    self.adReponse = nil;
    self.interstitialAd = nil;
    self.rewardedAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.adReponseTextView addDismissKeyboardButtonWithTitle:@"Done" withTarget:self withSelector:@selector(dismissKeyboard)];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)loadAdReponseTouchUpInside:(UIButton *)sender {
    [self requestAd];
}

- (BOOL)canRequestAd {
    if (self.adReponseTextView.text.length <= 0 || !self.adReponseTextView.text) {
        [self showAlertControllerWithMessage:@"Please input some ad reponse data."];
        return NO;
    } else if (!self.placement){
        [self showAlertControllerWithMessage:@"Please choose a placement."];
        return NO;
    } else {
        self.adReponse = self.adReponseTextView.text;
        return YES;
    }
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    if ([self canRequestAd]) {
        switch ([self.placement integerValue]) {
            case 0:
            case 1:
            case 2: {
                HyBidDemoLegacyAPITesterDetailViewController *legacyAPITesterDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HyBidDemoLegacyAPITesterDetailViewController"];
                legacyAPITesterDetailVC.adResponse = self.adReponse;
                legacyAPITesterDetailVC.placement = self.placement;
                legacyAPITesterDetailVC.debugButton = self.debugButton;
                [self.navigationController presentViewController:legacyAPITesterDetailVC animated:YES completion:nil];
                break;
            }
            case 3:
                self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
                [self.interstitialAd prepareAdWithAdReponse:self.adReponse];
                break;
            case 4:
                self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:nil andWithDelegate:self];
                [self.rewardedAd prepareAdWithAdReponse:self.adReponse];
                break;
            default:
                break;
        }
    }
}

- (IBAction)bannerTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)mRectTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)leaderboardTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)interstitialTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)rewardedTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    [self.interstitialAd show];
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
    [self.rewardedAd show];
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

