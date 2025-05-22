// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTModel.h"
#import "HyBidError.h"

typedef enum : NSInteger {
    HyBidVASTParserError_None,
    HyBidVASTParserError_XMLParse,
    HyBidVASTParserError_SchemaValidation,
    HyBidVASTParserError_TooManyWrappers,
    HyBidVASTParserError_NoCompatibleMediaFile,
    HyBidVASTParserError_NoInternetConnection,
    HyBidVASTParserError_MovieTooShort,
    HyBidVASTParserError_BothAdAndErrorPresentInRootResponse,
    HyBidVASTParserError_NoAdResponse
} HyBidVASTParserErrorType;

@interface HyBidVASTParserError: NSError

@property (nonatomic, strong) HyBidVASTErrorTagURLs errorTagURLs;
@property (nonatomic, assign) HyBidVASTParserErrorType parserErrorType;

+ (instancetype)initWithError:(NSError *)error errorTagURLs:(HyBidVASTErrorTagURLs)errorTagURLs;
+ (instancetype)initWithParserErrorType:(HyBidVASTParserErrorType)parserErrorType;
+ (instancetype)initWithParserErrorType:(HyBidVASTParserErrorType)parserErrorType
                         errorTagURLs:(HyBidVASTErrorTagURLs)errorTagURLs;
@end
