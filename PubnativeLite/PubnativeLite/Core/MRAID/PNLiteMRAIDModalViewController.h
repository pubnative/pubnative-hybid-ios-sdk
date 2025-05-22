// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

@class PNLiteMRAIDModalViewController;
@class PNLiteMRAIDOrientationProperties;

@protocol PNLiteMRAIDModalViewControllerDelegate <NSObject>

- (void)mraidModalViewControllerDidRotate:(PNLiteMRAIDModalViewController *)modalViewController;

@end

@interface PNLiteMRAIDModalViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<PNLiteMRAIDModalViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL willShowFeedbackScreen;


- (id)initWithOrientationProperties:(PNLiteMRAIDOrientationProperties *)orientationProperties;
- (void)forceToOrientation:(PNLiteMRAIDOrientationProperties *)orientationProperties;

@end
