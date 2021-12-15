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

#import "PNLiteDemoPNLiteSettingsViewController.h"
#import "PNLiteDemoSettings.h"
#import <HyBid/HyBid.h>

@interface PNLiteDemoPNLiteSettingsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *appTokenTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *openRTBApiURLTextField;
@property (weak, nonatomic) IBOutlet UIButton *testModeButton;
@property (weak, nonatomic) IBOutlet UIButton *coppaModeButton;
@property (weak, nonatomic) IBOutlet UIButton *notSetButton;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UISwitch *viewabilitySwitch;
@property (nonatomic, assign) BOOL testModeSelected;
@property (nonatomic, assign) BOOL coppaModeSelected;
@property (nonatomic, strong) HyBidTargetingModel *targetingModel;
@property (nonatomic, strong) NSString *gender;
@end

@implementation PNLiteDemoPNLiteSettingsViewController

- (void)dealloc {
    self.targetingModel = nil;
    self.gender = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"HyBid Settings";
    self.appTokenTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey];
    self.testModeSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kHyBidDemoTestModeKey];
    self.coppaModeSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kHyBidDemoCOPPAModeKey];
    self.targetingModel = [PNLiteDemoSettings sharedInstance].targetingModel;
    self.gender = [PNLiteDemoSettings sharedInstance].targetingModel.gender;
    self.apiURLTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAPIURLKey];
    self.openRTBApiURLTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoOpenRTBAPIURLKey];
    [self setInitialStateForModeButtons];
    [self setInitialStateForGenderButtons];
    if (self.targetingModel.age.integerValue > 0) {
        self.ageTextField.text = [NSString stringWithFormat:@"%@",[PNLiteDemoSettings sharedInstance].targetingModel.age];
    }
}

- (void)setInitialStateForModeButtons {
    if (self.testModeSelected) {
        self.testModeButton.selected = YES;
        [self.testModeButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    } else {
        self.testModeButton.selected = NO;
        [self.testModeButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    }
    
    if (self.coppaModeSelected) {
        self.coppaModeButton.selected = YES;
        [self.coppaModeButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    } else {
        self.coppaModeButton.selected = NO;
        [self.coppaModeButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    }
}

- (void)setInitialStateForGenderButtons {
    if ([self.targetingModel.gender isEqualToString:@"m"]) {
        self.notSetButton.selected = NO;
        self.maleButton.selected = YES;
        self.femaleButton.selected = NO;
        [self.notSetButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
        [self.maleButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
        [self.femaleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    } else if ([self.targetingModel.gender isEqualToString:@"f"]) {
        self.notSetButton.selected = NO;
        self.maleButton.selected = NO;
        self.femaleButton.selected = YES;
        [self.notSetButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
        [self.maleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
        [self.femaleButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    } else {
        self.notSetButton.selected = YES;
        self.maleButton.selected = NO;
        self.femaleButton.selected = NO;
        [self.notSetButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
        [self.maleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
        [self.femaleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    }
}

- (IBAction)handleTap:(UIGestureRecognizer *)recognizer {
    if (!([self.ageTextField.text length] > 0)) {
        self.ageTextField.text = nil;
        [self.ageTextField resignFirstResponder];
    }
}

- (IBAction)savePNLiteSettingsTouchUpInside:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.appTokenTextField.text forKey:kHyBidDemoAppTokenKey];
    [PNLiteDemoSettings sharedInstance].targetingModel = [self configureTargetingModel];
    [[NSUserDefaults standardUserDefaults] setBool:self.testModeSelected forKey:kHyBidDemoTestModeKey];
    [[NSUserDefaults standardUserDefaults] setBool:self.coppaModeSelected forKey:kHyBidDemoCOPPAModeKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.apiURLTextField.text forKey:kHyBidDemoAPIURLKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.openRTBApiURLTextField.text forKey:kHyBidDemoOpenRTBAPIURLKey];
    
    [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:^(BOOL success) {
        if (success) {
            NSLog(@"Initialisation completed");
        }
    }];
    [HyBidSettings sharedInstance].apiURL = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAPIURLKey];
    [HyBidSettings sharedInstance].openRtbApiURL = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoOpenRTBAPIURLKey];
    [HyBid setTargeting:[PNLiteDemoSettings sharedInstance].targetingModel];
    if (self.testModeSelected) {
        [HyBid setTestMode:YES];
    } else {
        [HyBid setTestMode:NO];
    }
    if (self.coppaModeSelected) {
        [HyBid setCoppa:YES];
    } else {
        [HyBid setCoppa:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (HyBidTargetingModel *)configureTargetingModel {
    if (([self.ageTextField.text length] > 0) && (self.ageTextField.text.integerValue > 0)) {
        self.targetingModel.age = [NSNumber numberWithInt:[self.ageTextField.text intValue]];
    }
    self.targetingModel.gender = self.gender;
    self.targetingModel.interests = [[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoKeywordsKey] componentsSeparatedByString:@","];
    return self.targetingModel;
}

- (IBAction)notSetTouchUpInside:(UIButton *)sender {
    self.notSetButton.selected = YES;
    self.maleButton.selected = NO;
    self.femaleButton.selected = NO;
    [self.notSetButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.maleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.femaleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.gender = nil;
}

- (IBAction)maleTouchUpInside:(UIButton *)sender {
    self.notSetButton.selected = NO;
    self.maleButton.selected = YES;
    self.femaleButton.selected = NO;
    [self.notSetButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.maleButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.femaleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.gender = @"m";
}

- (IBAction)femaleTouchUpInside:(UIButton *)sender {
    self.notSetButton.selected = NO;
    self.maleButton.selected = NO;
    self.femaleButton.selected = YES;
    [self.notSetButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.maleButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.femaleButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    self.gender = @"f";
}

- (IBAction)testingModeTouchUpInside:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    } else {
        [sender setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    }
    self.testModeSelected = sender.selected;
}

- (IBAction)coppaModeTouchUpInside:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    } else {
        [sender setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    }
    self.coppaModeSelected = sender.selected;
}

- (IBAction)viewabilitySwitchValueChanged:(UISwitch *)sender {
    [HyBidViewabilityManager sharedInstance].viewabilityMeasurementEnabled = sender.on;
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
