// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "PNLiteDemoBaseViewController.h"
#import "Markup.h"
#import "HyBidDemoEnumConstants.h"

@interface PNLiteDemoMarkupDetailViewController : PNLiteDemoBaseViewController

@property (nonatomic, strong) Markup *markup;
@property (weak, nonatomic) UIButton *debugButton;
@property (nonatomic, strong) NSString *creativeID;
@property (nonatomic, strong) NSString *creativeURL;
@property (nonatomic, strong) NSString *urTemplate;
@property (nonatomic, assign) BOOL urWrap;

@end
