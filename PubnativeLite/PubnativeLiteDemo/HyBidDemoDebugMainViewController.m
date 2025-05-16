// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoDebugMainViewController.h"
#import "PNLiteRequestInspector.h"
#import <HyBid/HyBid.h>

@interface HyBidDemoDebugMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UIButton *sdkEventsButton;
@property (weak, nonatomic) IBOutlet UIButton *beaconsButton;

@end

@implementation HyBidDemoDebugMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Debug";
}

-(void)viewWillAppear:(BOOL)animated {
    PNLiteRequestInspectorModel *lastRequest = [PNLiteRequestInspector sharedInstance].lastInspectedRequest;
    if (lastRequest) {
        self.inspectRequestButton.hidden = !lastRequest.url;
        self.beaconsButton.hidden = !lastRequest.response;
    }
    
    if ([HyBid reportingManager].events.count > 0) {
        self.sdkEventsButton.hidden = NO;
    }
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
