// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidRewardedPresenter.h"
#import "HyBidAd.h"

@interface HyBidRewardedPresenterFactory : NSObject

- (HyBidRewardedPresenter *)createRewardedPresenterWithAd:(HyBidAd *)ad
                                       withHTMLSkipOffset:(NSUInteger)htmlSkipOffset
                                        withCloseOnFinish:(BOOL)closeOnFinish
                                             withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate;

@end
