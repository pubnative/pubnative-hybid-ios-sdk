// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "PNLiteDemoBaseViewController.h"
#import "SignalData.h"

@interface HyBidDemoSignalDataDetailViewController : PNLiteDemoBaseViewController

@property (nonatomic, strong) SignalData *signalData;
@property (weak, nonatomic) UIButton *debugButton;

@end
