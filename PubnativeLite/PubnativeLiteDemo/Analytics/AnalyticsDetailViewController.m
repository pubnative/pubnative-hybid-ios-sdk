// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "AnalyticsDetailViewController.h"

@interface AnalyticsDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UITextView *eventJSONTextView;

@end

@implementation AnalyticsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eventTypeLabel.text = self.event.eventType;
    self.eventJSONTextView.text = [self.event toJSON];
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
