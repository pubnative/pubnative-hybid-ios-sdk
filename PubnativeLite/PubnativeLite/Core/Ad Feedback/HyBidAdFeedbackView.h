// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

@interface HyBidAdFeedbackView : UIView

/// YES between `show` and the feedback view closing or failing.
@property (nonatomic, readonly) BOOL isShown;

- (instancetype)initWithURL:(NSString *)url withZoneID:(NSString *)zoneID;
- (void)show;

@end
