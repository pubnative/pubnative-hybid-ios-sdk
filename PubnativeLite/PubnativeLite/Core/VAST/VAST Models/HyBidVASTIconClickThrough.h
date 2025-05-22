// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTIconClickThrough : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIconClickThroughXMLElement:(HyBidXMLElementEx *)iconClickThroughXMLElement;

- (NSString *)content;

@end
