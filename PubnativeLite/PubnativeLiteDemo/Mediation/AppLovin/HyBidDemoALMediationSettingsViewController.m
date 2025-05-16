// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoALMediationSettingsViewController.h"
#import "PNLiteDemoSettings.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface HyBidDemoALMediationSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nativeAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *bannerAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mRectAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *rewardedAdUnitIDTextField;
@end

@implementation HyBidDemoALMediationSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"AppLovin Mediation Settings";
    self.nativeAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationNativeAdUnitIDKey];
    self.bannerAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationBannerAdUnitIDKey];
    self.mRectAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationMRectAdUnitIDKey];
    self.interstitialAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationInterstitialAdUnitIDKey];
    self.rewardedAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationRewardedAdUnitIDKey];
}

- (IBAction)saveAppLovinMediationSettingsTouchUpInside:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.nativeAdUnitIDTextField.text forKey:kHyBidALMediationNativeAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.bannerAdUnitIDTextField.text forKey:kHyBidALMediationBannerAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.mRectAdUnitIDTextField.text forKey:kHyBidALMediationMRectAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.interstitialAdUnitIDTextField.text forKey:kHyBidALMediationInterstitialAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.rewardedAdUnitIDTextField.text forKey:kHyBidALMediationRewardedAdUnitIDKey];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openAppLovinMediationDebuggerTouchUpInside:(UIButton *)sender
{
    [[ALSdk shared] showMediationDebugger];
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
