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

#import "PNLiteDemoMoPubSettingsViewController.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubSettingsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *bannerAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mRectAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mRectVideoAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialVideoAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *leaderboardAdUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *rewardedAdUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *headerBiddingRewardedAdUnitIDTextField;

@end

@implementation PNLiteDemoMoPubSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Header Bidding Settings";
    self.bannerAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingBannerAdUnitIDKey];
    self.mRectAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingMRectAdUnitIDKey];
    self.mRectVideoAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingMRectVideoAdUnitIDKey];
    self.interstitialAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingInterstitialAdUnitIDKey];
    self.interstitialVideoAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingInterstitialVideoAdUnitIDKey];
    self.headerBiddingRewardedAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey];
    self.leaderboardAdUnitTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubHeaderBiddingLeaderboardAdUnitIDKey];
    self.rewardedAdUnitTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidMoPubMediationRewardedAdUnitIDKey];
}

- (IBAction)saveMoPubSettingsTouchUpInside:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.bannerAdUnitIDTextField.text forKey:kHyBidMoPubHeaderBiddingBannerAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.mRectAdUnitIDTextField.text forKey:kHyBidMoPubHeaderBiddingMRectAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.mRectVideoAdUnitIDTextField.text forKey:kHyBidMoPubHeaderBiddingMRectVideoAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.interstitialAdUnitIDTextField.text forKey:kHyBidMoPubHeaderBiddingInterstitialAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.interstitialVideoAdUnitIDTextField.text forKey:kHyBidMoPubHeaderBiddingInterstitialVideoAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.headerBiddingRewardedAdUnitIDTextField.text forKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.leaderboardAdUnitTextField.text forKey:kHyBidMoPubHeaderBiddingLeaderboardAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.rewardedAdUnitTextField.text forKey:kHyBidMoPubMediationRewardedAdUnitIDKey];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

@end
