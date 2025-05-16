// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTParserError.h"

typedef void (^isVASTXmlCompletionBlock)(BOOL isVAST, HyBidVASTParserError *error);

@interface HyBidMarkupUtils : NSObject

+ (void)isVastXml:(NSString*) adContent completion:(isVASTXmlCompletionBlock)block;

@end
