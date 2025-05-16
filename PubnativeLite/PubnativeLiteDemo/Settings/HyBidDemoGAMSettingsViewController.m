// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGAMSettingsViewController.h"
#import "PNLiteDemoSettings.h"

@interface HyBidDemoGAMSettingsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *bannerAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mRectAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *leaderboardAdUnitIDTextField;

@end

@implementation HyBidDemoGAMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAM Settings";
    self.bannerAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGAMBannerAdUnitIDKey];
    self.mRectAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGAMMRectAdUnitIDKey];
    self.interstitialAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGAMInterstitialAdUnitIDKey];
    self.leaderboardAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGAMLeaderboardAdUnitIDKey];
}

- (IBAction)saveGAMSettingsTouchUpInside:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.bannerAdUnitIDTextField.text forKey:kHyBidGAMBannerAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.mRectAdUnitIDTextField.text forKey:kHyBidGAMMRectAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.interstitialAdUnitIDTextField.text forKey:kHyBidGAMInterstitialAdUnitIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.leaderboardAdUnitIDTextField.text forKey:kHyBidGAMLeaderboardAdUnitIDKey];
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
