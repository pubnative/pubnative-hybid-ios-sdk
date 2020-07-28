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

#import "PNLiteDemoConsentStringsViewController.h"
#import <HyBid/HyBid.h>

#define kCCPAPublicPrivacyKey @"IABUSPrivacy_String"
#define kGDPRPublicConsentKey @"IABConsent_ConsentString"

@interface PNLiteDemoConsentStringsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *gdprConsentStringTextField;
@property (weak, nonatomic) IBOutlet UITextField *ccpaPrivacyStringTextField;

@end

@implementation PNLiteDemoConsentStringsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gdprConsentStringTextField.text = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
    self.ccpaPrivacyStringTextField.text = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
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
