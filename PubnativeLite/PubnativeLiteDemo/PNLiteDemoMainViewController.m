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
#import <StoreKit/SKOverlay.h>
#import <StoreKit/SKOverlayConfiguration.h>

#define EASY_FORECAST_APP_ID @"1382171002"

@interface PNLiteDemoMainViewController () <UITextFieldDelegate, SKOverlayDelegate>

@property (weak, nonatomic) IBOutlet UITextField *zoneIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *standaloneButton;
@property (weak, nonatomic) IBOutlet UIButton *headerBiddingButton;
@property (weak, nonatomic) IBOutlet UIButton *mediationButton;
@property (weak, nonatomic) IBOutlet UIButton *showRecommendedAppButton;

@end

@implementation PNLiteDemoMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)chooseAdFormatTouchUpInside:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.zoneIDTextField.text forKey:kHyBidDemoZoneIDKey];
}

- (IBAction)showRecommendedAppTouchUpInside:(UIButton *)sender {
    if (@available(iOS 14.0, *)) {
        SKOverlayAppConfiguration *configuration = [[SKOverlayAppConfiguration alloc]
                                                    initWithAppIdentifier:EASY_FORECAST_APP_ID
                                                    position:SKOverlayPositionBottomRaised];
        configuration.userDismissible = YES;
        // For setting additional value for a key; (for example, a value for measuring the effectiveness of an ad campaign.) we can call setAdditionalValue:forKey: method on the configuration.
        // For more information check here: https://developer.apple.com/documentation/storekit/skoverlayappconfiguration
        SKOverlay *overlay = [[SKOverlay alloc] initWithConfiguration:configuration];
        overlay.delegate = self;
        [overlay presentInScene:self.view.window.windowScene];
    } else {
        // SKOverlay & SKOverlayAppConfiguration are available starting from iOS 14.0+. If current device's iOS version is lower than that, fallback code must run here.
        [self showAlertControllerWithMessage:@"SKOverlay is available from iOS 14.0"];
    }
}

- (IBAction)handleTap:(UIGestureRecognizer *)recognizer {
    if (!([self.zoneIDTextField.text length] > 0)) {
        self.zoneIDTextField.text = nil;
        [self.zoneIDTextField resignFirstResponder];
    }
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

#pragma mark SKOverlayDelegate
- (void)storeOverlay:(SKOverlay *)overlay willStartPresentation:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    
}

- (void)storeOverlay:(SKOverlay *)overlay didFinishPresentation:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    
}

- (void)storeOverlay:(SKOverlay *)overlay willStartDismissal:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    
}

- (void)storeOverlay:(SKOverlay *)overlay didFinishDismissal:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    
}

- (void)storeOverlay:(SKOverlay *)overlay didFailToLoadWithError:(NSError *)error  API_AVAILABLE(ios(14.0)){
    
}

@end
