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

#import "PNLiteDemoMoPubConsentViewController.h"
#import <MoPubSDK/MoPub.h>

@interface PNLiteDemoMoPubConsentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *consentResultValueLabel;

@end

@implementation PNLiteDemoMoPubConsentViewController

- (void)viewWillAppear:(BOOL)animated
{
    BOOL isConsentDialogReady = [[MoPub sharedInstance] isConsentDialogReady];
    
    if (!isConsentDialogReady) {
        [self loadConsent];
    }
    
    [self setConsentStatus];
}

- (void)loadConsent
{
    [[MoPub sharedInstance] loadConsentDialogWithCompletion:^(NSError *error){
        if (error != nil) {
            self.consentResultValueLabel.text = @"Unknown";
            self.consentResultValueLabel.accessibilityValue = @"Unknown";
        }
    }];
}

- (void)setConsentStatus
{
    MPConsentStatus status = [[MoPub sharedInstance] currentConsentStatus];
    [self setConsentLabelValueFromStatus:status];
}

- (IBAction)askConsentButtonTapped:(id)sender {
    [[MoPub sharedInstance] showConsentDialogFromViewController:self didShow:nil didDismiss:^{
        [self setConsentStatus];
    }];
}

- (IBAction)checkButtonTapped:(id)sender {
    [self setConsentStatus];
}

- (void)setConsentLabelValueFromStatus: (MPConsentStatus)status
{
    switch (status) {
        case MPConsentStatusUnknown:
            self.consentResultValueLabel.text = @"Unknown";
            self.consentResultValueLabel.accessibilityValue = @"Unknown";
            break;
        case MPConsentStatusDenied:
            self.consentResultValueLabel.text = @"Denied";
            self.consentResultValueLabel.accessibilityValue = @"Denied";
            break;
        case MPConsentStatusDoNotTrack:
            self.consentResultValueLabel.text = @"Do Not Track";
            self.consentResultValueLabel.accessibilityValue = @"Do Not Track";
            break;
        case MPConsentStatusPotentialWhitelist:
            self.consentResultValueLabel.text = @"Potential Whitelist";
            self.consentResultValueLabel.accessibilityValue = @"Potential Whitelist";
            break;
        case MPConsentStatusConsented:
            self.consentResultValueLabel.text = @"Accepted";
            self.consentResultValueLabel.accessibilityValue = @"Accepted";
            break;
    }
}

@end
