// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//


@protocol HyBidCustomCTAViewDelegate <NSObject>
- (void)customCTADidLoadWithSuccess:(BOOL)success;
- (void)customCTADidShow;
- (void)customCTADidClick;
@end

