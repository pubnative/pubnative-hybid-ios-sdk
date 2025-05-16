// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

@class PNLiteOrientationManager;

@protocol PNLiteOrientationManagerDelegate<NSObject>

- (void)orientationManagerDidChangeOrientation;

@end

@interface PNLiteOrientationManager : NSObject

@property (nonatomic, weak) NSObject <PNLiteOrientationManagerDelegate> *delegate;

+ (instancetype)sharedInstance;
+ (UIInterfaceOrientation)orientation;

@end
