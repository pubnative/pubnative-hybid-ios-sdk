// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTAdParameters : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAdParametersXMLElement:(HyBidXMLElementEx *)adParametersXMLElement;

- (NSString *)xmlEncoded;

- (NSString *)content;

@end
