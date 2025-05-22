// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTClickThrough : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClickThroughXMLElement:(HyBidXMLElementEx *)clickThroughXMLElement;

/**
 A unique ID for the clickthrough.
 */
- (NSString *)id;

/**
 a URI to the advertiser’s site that the media player opens when a viewer clicks the ad.
 */
- (NSString *)content;

@end
