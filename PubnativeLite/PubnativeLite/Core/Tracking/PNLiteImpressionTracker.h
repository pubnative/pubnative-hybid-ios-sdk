// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "HyBid.h"

@protocol PNLiteImpressionTrackerDelegate <NSObject>
- (void)impressionDetectedWithView:(UIView*)view;
@end

@interface PNLiteImpressionTracker : NSObject

@property (nonatomic, weak) NSObject<PNLiteImpressionTrackerDelegate> *delegate;

@property (nonatomic, assign) HyBidImpressionTrackerMethod impressionTrackingMethod;

- (void)addView:(UIView*)view;
- (void)removeView:(UIView*)view;
- (void)clear;
- (void)determineViewbilityRemoteConfig: (HyBidAd*) ad;

@end
