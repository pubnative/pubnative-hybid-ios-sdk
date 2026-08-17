//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

@class HyBidAd;

@interface HyBidVASTPlayerPresentation : NSObject

+ (void)showPlayer:(UIViewController *)player onTopWithAd:(HyBidAd *)ad;
+ (void)showPlayer:(UIViewController *)player fromViewController:(UIViewController *)viewController;

@end
