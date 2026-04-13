// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityAdSession.h"
#import "HyBidOMIDAdSessionWrapper.h"

@interface HyBidViewabilityNativeAdSession : HyBidViewabilityAdSession

- (HyBidOMIDAdSessionWrapper*) createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts;

@end


