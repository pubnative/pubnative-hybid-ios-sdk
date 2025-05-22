// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTModel.h"
#import "HyBidVASTParserError.h"

typedef void (^videoAdProcessorCompletionBlock)(HyBidVASTModel *, HyBidVASTParserError *);

@interface HyBidVideoAdProcessor : NSObject

- (void)processVASTString:(NSString *)vastString completion:(videoAdProcessorCompletionBlock)block;

@end
