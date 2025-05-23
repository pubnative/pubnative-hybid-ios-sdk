// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HyBidVisibilityTrackerDelegate <NSObject>

- (void)checkVisibilityWithVisibleViews:(NSArray <UIView*>*)visibleViews andWithInvisibleViews:(NSArray<UIView*>*)invisibleViews;

@end

@interface HyBidVisibilityTracker : NSObject

@property (nonatomic, weak) NSObject <HyBidVisibilityTrackerDelegate> *delegate;

- (void)addView:(UIView*)view withMinVisibility:(CGFloat)minVisibility;
- (void)removeView:(UIView*)view;
- (void)clear;

@end
