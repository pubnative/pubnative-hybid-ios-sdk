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

#import "PNLiteDemoMainViewController.h"
#import "PNLiteDemoSettings.h"
#import "UITextField+KeyboardDismiss.h"

@interface PNLiteDemoMainViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *zoneIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *standaloneButton;
@property (weak, nonatomic) IBOutlet UIButton *headerBiddingButton;
@property (weak, nonatomic) IBOutlet UIButton *mediationButton;
@property (weak, nonatomic) IBOutlet UISwitch *publisherModeSwitch;

@end

@implementation PNLiteDemoMainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.publisherModeSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kHyBidDemoPublisherModeKey]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.zoneIDTextField addDismissKeyboardButtonWithTitle:@"Done" withTarget:self withSelector:@selector(dismissKeyboard)];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)chooseAdFormatTouchUpInside:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.zoneIDTextField.text forKey:kHyBidDemoZoneIDKey];
}

- (IBAction)handleTap:(UIGestureRecognizer *)recognizer {
    if (!([self.zoneIDTextField.text length] > 0)) {
        self.zoneIDTextField.text = nil;
        [self.zoneIDTextField resignFirstResponder];
    }
}

- (IBAction)publisherModeSwitchValueChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kHyBidDemoPublisherModeKey];
    UIAlertController *publisherModeAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Publisher Mode is: %s", sender.on ? "ON" : "OFF"]
                                                                               message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    [publisherModeAlert setValue:[[NSAttributedString alloc] initWithString:[PNLiteDemoSettings sharedInstance].publisherModeAlertMessage
                                                                 attributes:[PNLiteDemoSettings sharedInstance].publisherModeAlertAttributes]
                         forKey:@"attributedMessage"];
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [publisherModeAlert addAction:dismissAction];
    [self presentViewController:publisherModeAlert animated:YES completion:nil];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    self.standaloneButton.hidden = !textField.text.length;
    self.headerBiddingButton.hidden = !textField.text.length;
    self.mediationButton.hidden = !textField.text.length;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

@end
