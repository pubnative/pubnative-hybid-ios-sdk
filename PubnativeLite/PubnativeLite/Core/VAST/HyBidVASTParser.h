// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTModel.h"
#import "HyBidVASTParserError.h"

@class HyBidVASTAd;
typedef void (^HyBidVastParserCompletionBlock)(HyBidVASTModel*, HyBidVASTParserError*);

@interface HyBidVASTParser : NSObject

@property (nonatomic, strong) NSMutableArray *vastArray;

- (void)parseWithUrl:(NSURL *)url completion:(HyBidVastParserCompletionBlock)block;

- (void)parseWithData:(NSData *)vastData completion:(HyBidVastParserCompletionBlock)block;

@end
