// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

typedef enum {
    HyBidDiagnosticsEventInitialisation,
    HyBidDiagnosticsEventAdRequest,
    HyBidDiagnosticsEventUnknown
} HyBidDiagnosticsEvent;

@interface HyBidDiagnosticsManager : NSObject

+ (void)printDiagnosticsLog;
+ (void)printDiagnosticsLogWithEvent:(HyBidDiagnosticsEvent)event;

@end
