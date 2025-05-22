// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTAdTrackingEventType.h"
#import "HyBidXMLElementEx.h"

@interface HyBidVASTTracking: NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTrackingXMLElement:(HyBidXMLElementEx *)trackingXMLElement;

- (NSString *)url;

- (NSString *)event;

- (NSString *)offset;

@end
