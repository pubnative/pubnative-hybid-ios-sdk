// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTClickTracking : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClickTrackingXMLElement:(HyBidXMLElementEx *)clickTrackingXMLElement;

/**
 A unique ID for the click to be tracked.
 */
- (NSString *)id;

/**
 A URI for tracking when the ClickThrough is triggered.
 */
- (NSString *)content;

@end
