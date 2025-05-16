// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoBaseViewController.h"
#import "PNLiteRequestInspector.h"
#if DEBUG
#import <FLEX/FLEX.h>
#endif

@interface PNLiteDemoBaseViewController ()

@end

@implementation PNLiteDemoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *flexButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gearIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFLEX)];
    [self.navigationItem setRightBarButtonItem:flexButton];
}

- (void)toggleFLEX {
#if DEBUG
    [[FLEXManager sharedManager] toggleExplorer];
#endif
}

- (void)requestAd {
    
}

- (void)clearDebugTools {
    [[HyBid reportingManager] clearAllReports];
    [PNLiteRequestInspector sharedInstance].lastInspectedRequest = nil;
}

- (void)clearTextFrom:(UITextView *)textView {
    textView.text = nil;
}

- (void)showAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"I have a bad feeling about this... 🙄"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestAd];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reportEvent:(NSString *)eventType adFormat:(NSString *)adFormat properties:(NSDictionary<NSString *,NSString *> *)properties {
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:eventType adFormat:adFormat properties:properties];
        [[HyBid reportingManager]reportEventFor:reportingEvent];
    }
}

@end
