// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidXMLElementEx.h"

@interface HyBidVASTJavaScriptResource : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithJavaScriptResourceXMLElement:(HyBidXMLElementEx *)javaScriptResourceXMLElement;

- (NSString *)browserOptional;

- (NSString *)url;

@end
