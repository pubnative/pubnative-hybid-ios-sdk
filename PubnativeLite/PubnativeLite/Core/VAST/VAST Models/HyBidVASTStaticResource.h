// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTStaticResource : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithStaticResourceXMLElement:(HyBidXMLElementEx *)staticResourceXMLElement;

// MARK: - Attributes

- (NSString *)creativeType;

// MARK: - Elements

- (NSString *)content;

@end
