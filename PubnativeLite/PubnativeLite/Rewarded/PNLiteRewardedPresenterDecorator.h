// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidRewardedPresenter.h"
#import "HyBidAdTracker.h"

@interface PNLiteRewardedPresenterDecorator : HyBidRewardedPresenter <HyBidRewardedPresenterDelegate>

- (instancetype)initWithRewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate;

@end
