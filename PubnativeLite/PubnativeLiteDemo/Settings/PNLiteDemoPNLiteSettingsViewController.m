// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
@property (weak, nonatomic) IBOutlet UISwitch *reportingSwitch;
@property (nonatomic, assign) BOOL testModeSelected;
@property (nonatomic, assign) BOOL coppaModeSelected;
@property (nonatomic, assign) BOOL reportingEnabled;
@property (nonatomic, strong) HyBidTargetingModel *targetingModel;
@property (weak, nonatomic) IBOutlet UILabel *atomStateTextField;
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
    self.reportingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kHyBidDemoReportingKey];
    self.targetingModel = [PNLiteDemoSettings sharedInstance].targetingModel;
    self.gender = [PNLiteDemoSettings sharedInstance].targetingModel.gender;
    self.apiURLTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAPIURLKey];
    self.openRTBApiURLTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoOpenRTBAPIURLKey];
    [self.reportingSwitch setOn:self.reportingEnabled];
    [self setInitialStateForModeButtons];
    [self setInitialStateForGenderButtons];
    if (self.targetingModel.age.integerValue > 0) {
        self.ageTextField.text = [NSString stringWithFormat:@"%@",[PNLiteDemoSettings sharedInstance].targetingModel.age];
    }
    self.atomStateTextField.text = HyBidReportingManager.sharedInstance.isAtomStarted ? @"Started" : @"Not Started";
    [self.atomStateTextField setAccessibilityLabel: self.atomStateTextField.text];
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
    [[NSUserDefaults standardUserDefaults] setBool:self.reportingEnabled forKey:kHyBidDemoReportingKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.apiURLTextField.text forKey:kHyBidDemoAPIURLKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.openRTBApiURLTextField.text forKey:kHyBidDemoOpenRTBAPIURLKey];
    [HyBidSDKConfig sharedConfig].apiURL = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAPIURLKey];
    [HyBidSDKConfig sharedConfig].openRtbApiURL = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoOpenRTBAPIURLKey];
    [HyBidSDKConfig sharedConfig].targeting = [PNLiteDemoSettings sharedInstance].targetingModel;
    if (self.testModeSelected) {
        [HyBidSDKConfig sharedConfig].test = YES;
    } else {
        [HyBidSDKConfig sharedConfig].test = NO;
    }
    if (self.coppaModeSelected) {
        [HyBidConsentConfig sharedConfig].coppa = YES;
    } else {
        [HyBidConsentConfig sharedConfig].coppa = NO;
    }
    [HyBid setReporting:self.reportingEnabled];
    
    [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:^(BOOL success) {
        if (success) {
            NSLog(@"Initialisation completed");
        }
    }];
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

- (IBAction)reportingSwitchValueChanged:(UISwitch *)sender {
    self.reportingEnabled = sender.on;
}

- (IBAction)sdkConfigButtonTouchUpInside:(UIButton *)sender {
    UIAlertController *sdkConfigURLAlert = [UIAlertController alertControllerWithTitle:kHyBidSDKConfigAlertTitle
                                                                               message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    [sdkConfigURLAlert setValue:[[NSAttributedString alloc] initWithString:[PNLiteDemoSettings sharedInstance].sdkConfigAlertMessage
                                                                attributes:[PNLiteDemoSettings sharedInstance].sdkConfigAlertAttributes]
                         forKey:@"attributedMessage"];
    
    [sdkConfigURLAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.placeholder = kHyBidSDKConfigAlertTextFieldPlaceholder;
    }];
    
    __weak UITextField *weakTextField = [sdkConfigURLAlert.textFields firstObject];
    UIAlertAction *testingURL = [UIAlertAction actionWithTitle:kHyBidSDKConfigAlertActionTitleForTesting
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction *action) {
        [[HyBidConfigManager sharedManager] setHyBidConfigURLToTestingWithURL:weakTextField.text];
        [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:nil];
    }];
    UIAlertAction *productionURL = [UIAlertAction actionWithTitle:kHyBidSDKConfigAlertActionTitleForProduction
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
        [[HyBidConfigManager sharedManager] setHyBidConfigURLToProduction];
        [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:nil];
    }];
    [sdkConfigURLAlert addAction:testingURL];
    [sdkConfigURLAlert addAction:productionURL];
    [self presentViewController:sdkConfigURLAlert animated:YES completion:nil];
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
