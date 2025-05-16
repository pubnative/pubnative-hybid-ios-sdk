// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidRewardedPresenter.h"

@interface HyBidMRAIDRewardedPresenter : HyBidRewardedPresenter

- (instancetype)initWithAd:(HyBidAd *)ad withSkipOffset: (NSInteger)skipOffset;

@property (nonatomic, readwrite, assign) NSInteger skipOffset;

@end
