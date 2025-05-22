// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoSettingsMainViewController.h"

@interface PNLiteDemoSettingsMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *demoAppVersionLabel;

@end

@implementation PNLiteDemoSettingsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.demoAppVersionLabel.text = [NSString stringWithFormat:@"HyBid Demo App v: %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    self.demoAppVersionLabel.accessibilityValue = [NSString stringWithFormat:@"HyBid Demo App v: %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

@end
