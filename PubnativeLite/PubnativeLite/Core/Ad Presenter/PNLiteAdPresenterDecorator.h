// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdPresenter.h"
#import "HyBidAdTracker.h"

@interface PNLiteAdPresenterDecorator : HyBidAdPresenter <HyBidAdPresenterDelegate>

- (instancetype)initWithAdPresenter:(HyBidAdPresenter *)adPresenter
                      withAdTracker:(HyBidAdTracker *)adTracker
                       withDelegate:(NSObject<HyBidAdPresenterDelegate> *)delegate;

@end
