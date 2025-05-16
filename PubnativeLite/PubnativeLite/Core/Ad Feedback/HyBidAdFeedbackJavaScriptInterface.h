// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidMRAIDView.h"

@interface HyBidAdFeedbackJavaScriptInterface : NSObject

- (void)submitDataWithZoneID:(NSString *)zoneID withMRAIDView:(HyBidMRAIDView *)mraidView;

@end
