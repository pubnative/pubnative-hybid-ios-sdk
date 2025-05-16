// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoISSettingsViewController.h"
#import "PNLiteDemoSettings.h"
#import "IronSource/IronSource.h"

@interface HyBidDemoISSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *bannerAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *rewardedAdUnitIDTextField;
@end

@implementation HyBidDemoISSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"IS Settings";
    self.appIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey];
    self.bannerAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISBannerAdUnitIdKey];
    self.interstitialAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISInterstitialAdUnitIdKey];
    self.rewardedAdUnitIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISRewardedAdUnitIdKey];
}

- (IBAction)saveISSettingsTouchUpInside:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.appIDTextField.text forKey:kHyBidISAppIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.bannerAdUnitIDTextField.text forKey:kHyBidISBannerAdUnitIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.interstitialAdUnitIDTextField.text forKey:kHyBidISInterstitialAdUnitIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.rewardedAdUnitIDTextField.text forKey:kHyBidISRewardedAdUnitIdKey];
    
    LPMInitRequestBuilder *requestBuilder = [[LPMInitRequestBuilder alloc] initWithAppKey:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey]];
    LPMInitRequest *initRequest = [requestBuilder build];
    [LevelPlay initWithRequest:initRequest completion:^(LPMConfiguration * _Nullable config, NSError * _Nullable error) {
        if(error) {
            // There was an error on initialization. Take necessary actions or retry
        } else {
            // Initialization was successful. You can now create ad objects and load ads or perform other tasks
        }
    }];
    
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
