// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTUniversalAdId : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUniversalAdIdXMLElement:(HyBidXMLElementEx *)universalAdIdXMLElement;

/**
 A string used to identify the URL for the registry website where the unique creative ID is cataloged. Default value is “unknown.”
 */
- (NSString *)idRegistry;

/**
 A string identifying the unique creative identifier. Default value is “unknown”
 */
- (NSString *)universalAdId;

@end
