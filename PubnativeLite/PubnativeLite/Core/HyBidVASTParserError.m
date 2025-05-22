// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTParserError.h"

@implementation HyBidVASTParserError

+ (instancetype)initWithError:(NSError *)error errorTagURLs:(HyBidVASTErrorTagURLs)errorTagURLs {
    return [[HyBidVASTParserError alloc] initWithError:error errorTagURLs:errorTagURLs];
}

+ (instancetype)initWithParserErrorType:(HyBidVASTParserErrorType)parserErrorType {
    return [[HyBidVASTParserError alloc] initWithParserErrorType:parserErrorType];
}

+ (instancetype)initWithParserErrorType:(HyBidVASTParserErrorType)parserErrorType errorTagURLs:(HyBidVASTErrorTagURLs)errorTagURLs {
    return [[HyBidVASTParserError alloc] initWithParserErrorType:parserErrorType errorTagURLs:errorTagURLs];
}

- (instancetype)initWithError:(NSError *)error {
    return [self initWithDomain:error.domain code:error.code userInfo:error.userInfo];
}

- (instancetype)initWithError:(NSError *)error errorTagURLs:(HyBidVASTErrorTagURLs)errorTagURLs {
    self = [self initWithError: error];
    if (self) {
        self.errorTagURLs = errorTagURLs;
    }
    return self;
}

- (instancetype)initWithParserErrorType:(HyBidVASTParserErrorType)parserErrorType {
    
    NSError *parseError = [NSError hyBidParseError];
    
    switch(parserErrorType) {
        case 0: // HyBidVASTParserError_None
            parseError = [NSError hyBidUnknownError];
            break;
        case 1: // HyBidVASTParserError_XMLParse
            parseError = [NSError hyBidParseError];
            break;
        case 2: // HyBidVASTParserError_SchemaValidation
            parseError = [NSError hyBidVASTParserSchemaValidationError];
            break;
        case 3: // HyBidVASTParserError_TooManyWrappers
            parseError = [NSError hyBidVASTParserTooManyWrappersError];
            break;
        case 4: // HyBidVASTParserError_NoCompatibleMediaFile
            parseError = [NSError hyBidVASTParserNoCompatibleMediaFileError];
            break;
        case 5: // HyBidVASTParserError_NoInternetConnection
            parseError = [NSError hyBidVASTParserNoInternetConnectionError];
            break;
        case 6: // HyBidVASTParserError_MovieTooShort
            parseError = [NSError hyBidVASTParserMovieTooShortError];
            break;
        case 7: // HyBidVASTParserError_BothAdAndErrorPresentInRootResponse
            parseError = [NSError hyBidVASTBothAdAndErrorPresentInRootResponse];
            break;
        case 8: // HyBidVASTParserError_NoAdResponse:
            parseError = [NSError hyBidVASTNoAdResponse];
            break;
    }
    
    self = [self initWithError: parseError];
    if (self) {
        self.parserErrorType = parserErrorType;
    }
    
    return self;
}

- (instancetype)initWithParserErrorType:(HyBidVASTParserErrorType)parserErrorType
                         errorTagURLs:(HyBidVASTErrorTagURLs)errorTagURLs {
    self = [self initWithParserErrorType:parserErrorType];
    if (self) {
        self.errorTagURLs = errorTagURLs;
    }
    return self;
}

@end
