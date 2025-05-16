// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidInterstitialPresenter.h"
#import "HyBidAd.h"

@class HyBidSkipOffset;

@interface HyBidInterstitialPresenterFactory : NSObject

- (HyBidInterstitialPresenter *)createInterstitalPresenterWithAd:(HyBidAd *)ad
                                             withVideoSkipOffset:(HyBidSkipOffset *)videoSkipOffset
                                              withHTMLSkipOffset:(NSUInteger)htmlSkipOffset
                                               withCloseOnFinish:(BOOL)closeOnFinish
                                                    withDelegate:(NSObject<HyBidInterstitialPresenterDelegate> *)delegate;

@end
