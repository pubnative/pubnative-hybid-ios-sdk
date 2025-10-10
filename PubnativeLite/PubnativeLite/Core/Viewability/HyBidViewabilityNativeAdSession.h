// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityAdSession.h"
#import "OMIDAdSessionWrapper.h"

@interface HyBidViewabilityNativeAdSession : HyBidViewabilityAdSession

- (OMIDAdSessionWrapper*) createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts;

@end


