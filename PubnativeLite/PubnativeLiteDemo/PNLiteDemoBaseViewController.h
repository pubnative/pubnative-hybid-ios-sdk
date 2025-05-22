// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import <HyBid/HyBid.h>

@interface PNLiteDemoBaseViewController : UIViewController

- (void)clearDebugTools;
- (void)clearTextFrom:(UITextView *)textView;
- (void)requestAd;
- (void)showAlertControllerWithMessage:(NSString *)message;
- (void)reportEvent:(NSString *)eventType adFormat:(NSString *)adFormat properties:(NSDictionary<NSString *,NSString *> *)properties;

@end
