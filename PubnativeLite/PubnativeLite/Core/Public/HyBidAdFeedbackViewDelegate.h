// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@protocol HyBidAdFeedbackViewDelegate<NSObject>
@optional
- (void)adFeedbackViewIsReady;
- (void)adFeedbackViewDidLoad;
- (void)adFeedbackViewDidFailWithError:( NSError * _Nonnull )error;
- (void)adFeedbackViewDidDismiss;

@end
