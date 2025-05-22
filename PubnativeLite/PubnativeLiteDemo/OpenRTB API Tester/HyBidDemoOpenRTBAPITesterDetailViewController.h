// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "PNLiteDemoBaseViewController.h"
#import "HyBidDemoEnumConstants.h"

@interface HyBidDemoOpenRTBAPITesterDetailViewController : PNLiteDemoBaseViewController

@property (nonatomic, strong) NSString *adResponse;
@property (nonatomic) HyBidMarkupPlacement placement;
@property (weak, nonatomic) UIButton *debugButton;

@end
