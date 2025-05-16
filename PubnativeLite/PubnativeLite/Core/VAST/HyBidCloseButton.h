// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidAd.h"

@interface HyBidCloseButton : UIButton

- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target ad:(HyBidAd *)ad;
- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target showSkipButton:(BOOL)showSkipButton ad:(HyBidAd *)ad;
- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target showSkipButton:(BOOL)showSkipButton useCustomClose:(BOOL)useCustomClose ad:(HyBidAd *)ad;
+ (CGSize)buttonSizeBasedOn:(HyBidAd *)ad;
+ (BOOL)isDefaultSize:(CGSize)size;
+ (CGSize)buttonDefaultSize;
@end
