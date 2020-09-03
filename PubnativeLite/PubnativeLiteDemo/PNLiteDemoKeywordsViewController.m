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

#import "PNLiteDemoKeywordsViewController.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoKeywordsViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *allKeywordsTextView;
@property (weak, nonatomic) IBOutlet UITextField *keywordTextField;
@property (nonatomic, strong) NSString *newlyAddedKeyword;

@end

@implementation PNLiteDemoKeywordsViewController

- (void)dealloc {
    self.newlyAddedKeyword = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Keywords";
    self.allKeywordsTextView.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoKeywordsKey];
}

- (IBAction)handleTap:(UIGestureRecognizer *)recognizer {
    if (!([self.keywordTextField.text length] > 0)) {
        self.keywordTextField.text = nil;
        [self.keywordTextField resignFirstResponder];
    }
}

- (IBAction)addKeywordTouchUpInside:(UIButton *)sender {
    [self.keywordTextField resignFirstResponder];
    if ([self.newlyAddedKeyword length] > 0) {
        if ([self.allKeywordsTextView.text length] > 0) {
            self.allKeywordsTextView.text = [self.allKeywordsTextView.text stringByAppendingString:[NSString stringWithFormat:@",%@",self.newlyAddedKeyword]];
        } else {
        self.allKeywordsTextView.text = [self.allKeywordsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@",self.newlyAddedKeyword]];
        }
        self.newlyAddedKeyword = nil;
    }
}

- (IBAction)clearKeywordsTouchUpInside:(UIButton *)sender {
    self.allKeywordsTextView.text = @"";
}

- (IBAction)saveKeywordsTouchUpInside:(UIButton *)sender {
    if ([self.allKeywordsTextView.text length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.allKeywordsTextView.text forKey:kHyBidDemoKeywordsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kHyBidDemoKeywordsKey];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    self.newlyAddedKeyword = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

@end
