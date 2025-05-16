// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidRewardedAdRequest.h"

@implementation HyBidRewardedAdRequest

- (HyBidAdSize *)adSize {
    return HyBidAdSize.SIZE_INTERSTITIAL;
}

- (BOOL)isRewarded {
    return YES;
}
@end
