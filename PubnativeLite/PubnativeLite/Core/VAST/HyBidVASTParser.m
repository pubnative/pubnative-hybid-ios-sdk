// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTParser.h"
#import "PNLiteVASTXMLUtil.h"
#import "HyBidVASTModel.h"
#import "HyBidVASTSchema.h"
#import "HyBidXMLEx.h"
#import "HyBidVASTParserError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

NSInteger const HyBidVASTModel_MaxRecursiveDepth = 5;
BOOL const HyBidVASTModel_ValidateWithSchema = NO;

@interface HyBidVASTModel ()

- (void)addVASTDocument:(NSData *)vastDocument;
- (void)addVASTString:(NSData *)vastString;

@end

@interface HyBidVASTParser ()

@property (nonatomic, strong) HyBidVASTModel *vastModel;

- (HyBidVASTParserError *)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth;


@end

@implementation HyBidVASTParser

- (id)init {
    self = [super init];
    if (self) {
        self.vastModel = [[HyBidVASTModel alloc] init];
    }
    if (self) {
          static NSMutableArray *sharedArray = nil;
          static dispatch_once_t onceToken;
          dispatch_once(&onceToken, ^{
              sharedArray = [NSMutableArray array];
          });

          self.vastArray = sharedArray;
    }
    return self;
}

- (void)dealloc {
    self.vastModel = nil;
}

#pragma mark - "public" methods

- (void)parseWithUrl:(NSURL *)url completion:(HyBidVastParserCompletionBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *vastData = [NSData dataWithContentsOfURL:url];
        HyBidVASTParserError *vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

- (void)parseWithData:(NSData *)vastData completion:(HyBidVastParserCompletionBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        HyBidVASTParserError *vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

#pragma mark - "private" method

- (HyBidVASTParserError *)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth {
    NSString *vastDataString = nil;
    
    @try {
        vastDataString = [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Parsing VAST data failed with error: %@", exception.reason]];
    }
    
    if (!vastDataString) {
        return [HyBidVASTParserError initWithParserErrorType: HyBidVASTParserError_XMLParse];
    }
    
    vastData = [self removingVastFirstLineParamsFrom: vastDataString];
    @synchronized (self.vastArray) {
        [self.vastArray addObject:vastData];
    }

    if (depth > HyBidVASTModel_MaxRecursiveDepth) {
        self.vastModel = nil;
        return [HyBidVASTParserError initWithParserErrorType: HyBidVASTParserError_TooManyWrappers];
    }
    
    // sanity check
    __unused NSString *content = [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];
    
    // Validate the basic XML syntax of the VAST document.
    BOOL isValid;
    isValid = validateXMLDocSyntax(vastData);
    if (!isValid) {
        self.vastModel = nil;
        return [HyBidVASTParserError initWithParserErrorType: HyBidVASTParserError_XMLParse];
    }

    if (HyBidVASTModel_ValidateWithSchema) {
        
        // Using header data
        NSData *HyBidVASTSchemaData = [NSData dataWithBytesNoCopy:hybid_vast_2_0_1_xsd
                                                        length:hybid_vast_2_0_1_xsd_len
                                                freeWhenDone:NO];
        isValid = validateXMLDocAgainstSchema(vastData, HyBidVASTSchemaData);
        if (!isValid) {
            self.vastModel = nil;
            return [HyBidVASTParserError initWithParserErrorType: HyBidVASTParserError_SchemaValidation];
        }
    }
    
    [self.vastModel addVASTDocument:vastData];
    [self.vastModel addVASTString:vastData];

    // Check if VAST is comming with at least 1 no-ad response error
    if ([self.vastModel errors].count > 0) {
        if(self.vastModel.ads.count > 0) {
            self.vastModel = nil;
            return [HyBidVASTParserError initWithParserErrorType: HyBidVASTParserError_BothAdAndErrorPresentInRootResponse];
        } else {
            HyBidVASTParserError *error = [HyBidVASTParserError initWithParserErrorType: HyBidVASTParserError_NoAdResponse errorTagURLs: self.vastModel.errors];
            self.vastModel = nil;
            return error;
        }
    }
    
    // Check to see whether this is a wrapper ad. If so, process it.
    NSString *query = @"//VASTAdTagURI";
    NSArray *results = performXMLXPathQuery(vastData, query);
    // Validating to use VASTAdTagURI just from wrappers and not from InLine
    NSString *inLineQuery = @"//InLine";
    NSArray *inLineResults = performXMLXPathQuery(vastData, inLineQuery);

    if ([results count] > 0 && inLineResults.count == 0) {
        NSString *url;
        NSDictionary *node = results[0];
        // Checking if CDATA does not exist and content is not empty. Then proceed with raw URL
        if ([node[@"nodeContent"] length] > 0 && [node[@"nodeChildArray"] count] == 0) {
            // this is for string data
            url =  node[@"nodeContent"];
        } else {
            // this is for CDATA
            NSArray *childArray = node[@"nodeChildArray"];
            if ([childArray count] > 0) {
                // we assume that there's only one element in the array
                url = ((NSDictionary *)childArray[0])[@"nodeContent"];
                url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *urlWithPercentEncoding = url;
                url = [url stringByRemovingPercentEncoding];
                vastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
                BOOL isVASTDataWithPercentEncoding = NO;
                if (!vastData) {
                    vastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[urlWithPercentEncoding stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
                    isVASTDataWithPercentEncoding = YES;
                }
                
                if(vastData) {
                    vastDataString = [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];
                    vastData = [self removingVastFirstLineParamsFrom: vastDataString];
                    if (!validateXMLDocSyntax(vastData) && !isVASTDataWithPercentEncoding) {
                        vastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[urlWithPercentEncoding stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
                        vastDataString = [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];
                        vastData = [self removingVastFirstLineParamsFrom: vastDataString];
                    }
                    @synchronized (self.vastArray) {
                        [self.vastArray addObject:vastData];
                    }
                    [self.vastModel addVASTString:vastData];
                }
            }
        }
        return [self parseRecursivelyWithData:vastData depth:(depth + 1)];
    }
    
    return [HyBidVASTParserError initWithParserErrorType: HyBidVASTParserError_None];
}

- (NSData *)removingVastFirstLineParamsFrom:(NSString *)vastDataString {
    // having XML namespace in the XML causes parsing issues
    // therefore we are replacing the starting <VAST> line
    NSString *regexExp = @"<VAST .*?>";
    NSError *error = NULL;
    if (vastDataString == nil) {
        return [@"" dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexExp options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:vastDataString options:0 range: NSMakeRange(0, [vastDataString length])];

    NSString *newXmlString = vastDataString;

    if ([match numberOfRanges] > 0) {
        NSString *matchedString = [vastDataString substringWithRange:[match rangeAtIndex:0]];

        HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:vastDataString];
        NSString *vastVersion = [[parser rootElement] attribute:@"version"];

        if (vastVersion != nil) {
            NSString *customVASTLine = [[NSString alloc] initWithFormat: @"<VAST version=\"%@\">", vastVersion];
            newXmlString = [vastDataString stringByReplacingOccurrencesOfString:matchedString withString:customVASTLine options:0 range:NSMakeRange(0, [vastDataString length])];
        }
    }

    return [newXmlString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)content:(NSDictionary *)node {
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }
    
    // this is for CDATA
    NSArray *childArray = node[@"nodeChildArray"];
    if ([childArray count] > 0) {
        // we assume that there's only one element in the array
        return ((NSDictionary *)childArray[0])[@"nodeContent"];
    }
    
    return nil;
}

@end
