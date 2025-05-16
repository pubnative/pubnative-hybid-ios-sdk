// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTCustomClick : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCustomClickXMLElement:(HyBidXMLElementEx *)customClickXMLElement;

/**
 A unique ID for the custom click to be tracked.
 */
- (NSString *)id;

/**
 A URI for tracking custom interactions.
 */
- (NSString *)content;

@end
