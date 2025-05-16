// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoConsentManagementProviderViewController.h"


@interface PNLiteDemoConsentManagementProviderViewController ()

@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyURLButton;
@property (weak, nonatomic) IBOutlet UIButton *vendorListURLButton;
@property (weak, nonatomic) IBOutlet UILabel *currentConsentStatusLabel;

@end

@implementation PNLiteDemoConsentManagementProviderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareCanCollectDataIndicator];
}

- (void)prepareCanCollectDataIndicator {
    if ([[HyBidUserDataManager sharedInstance] canCollectData]) {
        self.currentConsentStatusLabel.text = @"Given";
        self.currentConsentStatusLabel.accessibilityValue = @"Given";
    } else {
        self.currentConsentStatusLabel.text = @"Rejected";
        self.currentConsentStatusLabel.accessibilityValue = @"Rejected";
    }
}

- (IBAction)checkConsentTouchUpInside:(UIButton *)sender {
    [self prepareCanCollectDataIndicator];
}

- (IBAction)pnOwnedTouchUpInside:(UIButton *)sender {
     /*
    // This would be the normal implementation for a regular publisher.
    // We remove this condition here for testing purposes
    if ([[HyBidUserDataManager sharedInstance] shouldAskConsent]) {
        [[HyBidUserDataManager sharedInstance] loadConsentPageWithCompletion:^(NSError * _Nullable error) {
            if (!error) {
                [[HyBidUserDataManager sharedInstance] showConsentPage:^{
                    // Consent Page Did Show Completion Block..
                } didDismiss:^{
                    // Consent Page Did Dismiss Completion Block..
                }];
            }
        }];
    } else {
        if (![HyBidSettings sharedInstance].advertisingId) {
            NSLog(@"Advertising ID (Device ID) is nil. Check for 'Limit Ad Tracking'.");
        } else {
            NSLog(@"Either consent has already been answered (If you want to try again please clear your app cache), or you are not in the GDPR zone.");
        }
    }
    */
    
    self.privacyPolicyURLButton.hidden = YES;
    self.vendorListURLButton.hidden = YES;
    [[HyBidUserDataManager sharedInstance] loadConsentPageWithCompletion:^(NSError * _Nullable error) {
        if (!error) {
            [[HyBidUserDataManager sharedInstance] showConsentPage:^{

            } didDismiss:^{

            }];
        }
    }];
}

- (IBAction)publisherOwnedTouchUpInside:(UIButton *)sender {
    [self.privacyPolicyURLButton setTitle:[[HyBidUserDataManager sharedInstance] privacyPolicyLink] forState:UIControlStateNormal];
    [self.vendorListURLButton setTitle:[[HyBidUserDataManager sharedInstance] vendorListLink] forState:UIControlStateNormal];
    self.privacyPolicyURLButton.hidden = NO;
    self.vendorListURLButton.hidden = NO;
}

- (IBAction)acceptConsentTouchUpInside:(UIButton *)sender {
    [[HyBidUserDataManager sharedInstance] grantConsent];
}

- (IBAction)rejectConsentTouchUpInside:(UIButton *)sender {
    [[HyBidUserDataManager sharedInstance] denyConsent];
}

- (IBAction)privacyPolicyURLTouchUpInside:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sender.titleLabel.text] options:@{} completionHandler:nil];
}

- (IBAction)vendorListURLTouchUpInside:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sender.titleLabel.text] options:@{} completionHandler:nil];
}

@end
