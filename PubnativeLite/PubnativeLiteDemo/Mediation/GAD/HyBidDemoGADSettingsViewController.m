// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGADSettingsViewController.h"
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *leaderboardAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *bannerAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mRectAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *nativeAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *rewardedAdUnitIDTextField;
@end

@implementation HyBidDemoGADSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"GAD Settings";
    self.appIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADAppIDKey];
    self.leaderboardAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADLeaderboardAdUnitIDKey];
    self.bannerAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADBannerAdUnitIDKey];
    self.nativeAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADNativeAdUnitIDKey];
    self.mRectAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADMRectAdUnitIDKey];
    self.interstitialAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADInterstitialAdUnitIDKey];
    self.rewardedAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADRewardedAdUnitIDKey];
}

- (IBAction)saveGADSettingsTouchUpInside:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.appIDTextField.text forKey:kHyBidGADAppIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.leaderboardAdUnitIDTextField.text forKey:kHyBidGADLeaderboardAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.bannerAdUnitIDTextField.text forKey:kHyBidGADBannerAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.nativeAdUnitIDTextField.text forKey:kHyBidGADNativeAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.mRectAdUnitIDTextField.text forKey:kHyBidGADMRectAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.interstitialAdUnitIDTextField.text forKey:kHyBidGADInterstitialAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.rewardedAdUnitIDTextField.text forKey:kHyBidGADRewardedAdUnitIDKey];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openGADMediationTesterTouchUpInside:(UIButton *)sender
{
    [[GADMobileAds sharedInstance] presentAdInspectorFromViewController:self
          completionHandler:^(NSError *error) {
        NSLog(@"Mediation debugger error");
    }];
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
