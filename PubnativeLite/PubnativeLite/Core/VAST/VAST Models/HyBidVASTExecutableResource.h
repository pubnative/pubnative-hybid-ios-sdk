// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidXMLElementEx.h"

@interface HyBidVASTExecutableResource : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithExecutableResourceXMLElement:(HyBidXMLElementEx *)executableResourceXMLElement;

- (NSString *)language;

- (NSString *)apiFramework;

- (NSString *)url;

@end
