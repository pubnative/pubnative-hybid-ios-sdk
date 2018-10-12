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

@interface PNLiteDemoMainViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *zoneIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *nativeButton;
@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;

@end

@implementation PNLiteDemoMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)chooseAdFormatTouchUpInside:(UIButton *)sender
{
    [PNLiteDemoSettings sharedInstance].zoneID = self.zoneIDTextField.text;
}

- (IBAction)handleTap:(UIGestureRecognizer *)recognizer
{
    if (!([self.zoneIDTextField.text length] > 0)) {
        self.zoneIDTextField.text = nil;
        [self.zoneIDTextField resignFirstResponder];
    }
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.text.length) {
        self.nativeButton.hidden = NO;
        self.bannerButton.hidden = NO;
        self.mRectButton.hidden = NO;
        self.interstitialButton.hidden = NO;
    } else {
        self.nativeButton.hidden = YES;
        self.bannerButton.hidden = YES;
        self.mRectButton.hidden = YES;
        self.interstitialButton.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
