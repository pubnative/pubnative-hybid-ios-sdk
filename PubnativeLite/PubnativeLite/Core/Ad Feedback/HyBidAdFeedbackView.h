// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

@protocol HyBidAdFeedbackViewDelegate<NSObject>

- (void)adFeedbackViewDidLoad;
- (void)adFeedbackViewDidFailWithError:(NSError *)error;

@end

@interface HyBidAdFeedbackView : UIView

@property (nonatomic, weak) NSObject <HyBidAdFeedbackViewDelegate> *delegate;

- (instancetype)initWithURL:(NSString *)url withZoneID:(NSString *)zoneID;
- (void)show;

@end
