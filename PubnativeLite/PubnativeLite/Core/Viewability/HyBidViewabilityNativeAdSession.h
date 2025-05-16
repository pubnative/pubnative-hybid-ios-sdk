// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityAdSession.h"

@interface HyBidViewabilityNativeAdSession : HyBidViewabilityAdSession

- (OMIDPubnativenetAdSession*)createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts;

@end

