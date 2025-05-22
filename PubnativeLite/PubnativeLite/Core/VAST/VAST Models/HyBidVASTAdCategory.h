// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTAdCategory : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCategoryXMLElement:(HyBidXMLElementEx *)categoryXmlElement;

/**
 A URL for the organizational authority that produced the list being used to identify
 ad content category.
 */
- (NSString *)authority;

/**
 A string that provides a category code or label that identifies the ad content category.
 */
- (NSString *)category;

@end
