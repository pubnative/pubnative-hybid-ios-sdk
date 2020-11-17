//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import "PNLiteDemoAdMobMediationSettingsViewController.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoAdMobMediationSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *leaderboardAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *bannerAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mRectAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *rewardedAdUnitIDTextField;
@end

@implementation PNLiteDemoAdMobMediationSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"AdMob Mediation Settings";
    self.appIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidAdMobMediationAppIDKey];
    self.leaderboardAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidAdMobMediationLeaderboardAdUnitIDKey];
    self.bannerAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidAdMobMediationBannerAdUnitIDKey];
    self.mRectAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidAdMobMediationMRectAdUnitIDKey];
    self.interstitialAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidAdMobMediationInterstitialAdUnitIDKey];
    self.rewardedAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidAdMobMediationRewardedAdUnitIDKey];
}
- (IBAction)saveMoPubMediationSettingsTouchUpInside:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.appIDTextField.text forKey:kHyBidAdMobMediationAppIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.leaderboardAdUnitIDTextField.text forKey:kHyBidAdMobMediationLeaderboardAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.bannerAdUnitIDTextField.text forKey:kHyBidAdMobMediationBannerAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.mRectAdUnitIDTextField.text forKey:kHyBidAdMobMediationMRectAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.interstitialAdUnitIDTextField.text forKey:kHyBidAdMobMediationInterstitialAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.rewardedAdUnitIDTextField.text forKey:kHyBidAdMobMediationRewardedAdUnitIDKey];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

- (IBAction)rewardedAdUnitIDTextField:(id)sender {
}
@end
