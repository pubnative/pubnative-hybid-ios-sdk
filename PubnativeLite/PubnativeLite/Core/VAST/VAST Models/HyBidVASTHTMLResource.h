// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTHTMLResource : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithHTMLResourceXMLElement:(HyBidXMLElementEx *)htmlResourceXMLElement;

/**
 A HTML code snippet (within a CDATA element)
 */
- (NSString *)content;

@end
