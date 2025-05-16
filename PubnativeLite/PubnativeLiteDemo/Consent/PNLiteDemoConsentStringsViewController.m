// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoSettings.h"
#import "PNLiteDemoConsentStringsViewController.h"
#import <HyBid/HyBid.h>

#define kCCPAPublicPrivacyKey @"IABUSPrivacy_String"
#define kGDPRPublicConsentKey @"IABConsent_ConsentString"
#define kGDPRPublicConsentV2Key @"IABTCF_TCString"

@interface PNLiteDemoConsentStringsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *gdprConsentStringTextField;
@property (weak, nonatomic) IBOutlet UITextField *ccpaPrivacyStringTextField;
@property (weak, nonatomic) IBOutlet UITextField *tcfConsentStringTextField;

@end

@implementation PNLiteDemoConsentStringsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gdprConsentStringTextField.text = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
    self.ccpaPrivacyStringTextField.text = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
    self.tcfConsentStringTextField.text = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
}

- (IBAction)setGDPRConsentStringTouchUpInside:(UIButton *)sender {
    if (self.gdprConsentStringTextField.text.length != 0) {
            [[NSUserDefaults standardUserDefaults] setObject:self.gdprConsentStringTextField.text forKey:kGDPRPublicConsentKey];
    }
}

- (IBAction)removeGDPRConsentStringTouchUpInside:(UIButton *)sender {
    self.gdprConsentStringTextField.text = @"";
    [[NSUserDefaults standardUserDefaults] setObject:self.gdprConsentStringTextField.text forKey:kGDPRPublicConsentKey];
}

- (IBAction)setCCPAPrivacyStringTouchUpInside:(UIButton *)sender {
    if (self.ccpaPrivacyStringTextField.text.length != 0) {
            [[NSUserDefaults standardUserDefaults] setObject:self.ccpaPrivacyStringTextField.text forKey:kCCPAPublicPrivacyKey];
    }
}

- (IBAction)removeCCPAPrivacyStringTouchUpInside:(UIButton *)sender {
    self.ccpaPrivacyStringTextField.text = @"";
    [[NSUserDefaults standardUserDefaults] setObject:self.ccpaPrivacyStringTextField.text forKey:kCCPAPublicPrivacyKey];
}

- (IBAction)setTCFConsentStringTouchUpInside:(UIButton *)sender {
    if (self.tcfConsentStringTextField.text.length != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.tcfConsentStringTextField.text forKey:kGDPRPublicConsentV2Key];
        //For QA Automation purposes initialize the SDK again
        [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:^(BOOL success) {}];
    }
}

- (IBAction)removeTCFConsentStringTouchUpInside:(UIButton *)sender {
    self.tcfConsentStringTextField.text = @"";
    [[NSUserDefaults standardUserDefaults] setObject:self.tcfConsentStringTextField.text forKey:kGDPRPublicConsentV2Key];
    //For QA Automation purposes initialize the SDK again
    [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:^(BOOL success) {}];
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
