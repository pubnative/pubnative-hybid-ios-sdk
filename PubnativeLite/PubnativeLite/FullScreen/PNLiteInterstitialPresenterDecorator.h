// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidInterstitialPresenter.h"
#import "HyBidAdTracker.h"

@interface PNLiteInterstitialPresenterDecorator : HyBidInterstitialPresenter <HyBidInterstitialPresenterDelegate>

//@property (nonatomic) NSObject<HyBidInterstitialPresenterDelegate> *interstitialPresenterDelegate;

- (instancetype)initWithInterstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidInterstitialPresenterDelegate> *)delegate;

@end
