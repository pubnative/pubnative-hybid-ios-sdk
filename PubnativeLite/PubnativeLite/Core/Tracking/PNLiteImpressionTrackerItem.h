// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PNLiteImpressionTrackerItem : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) NSTimeInterval timestamp;

@end
