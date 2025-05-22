// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoChartboostSettingsViewController.h"
#import "PNLiteDemoSettings.h"
#import <ChartboostSDK/Chartboost.h>

@interface HyBidDemoChartboostSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *appSignatureTextField;
@end

@implementation HyBidDemoChartboostSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Chartboost Settings";
    self.appIDTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostAppIDKey];
    self.appSignatureTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostAppSignatureKey];
}

- (IBAction)saveChartboostSettingsTouchUpInside:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.appIDTextField.text forKey:kHyBidChartboostAppIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.appSignatureTextField.text forKey:kHyBidChartboostAppSignatureKey];
    [Chartboost startWithAppID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostAppIDKey]
                  appSignature:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostAppSignatureKey]
                    completion:^(CHBStartError * _Nullable error) {
        if (error) {
            NSLog(@"Chartboost SDK initialization finished with error %@", error);
        } else {
            NSLog(@"Chartboost SDK initialization finished with success");
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
