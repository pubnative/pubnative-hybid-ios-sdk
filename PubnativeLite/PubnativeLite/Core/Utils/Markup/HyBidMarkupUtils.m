// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidMarkupUtils.h"
#import "HyBidError.h"
#import "HyBidVASTParserError.h"
#import "HyBidVASTParser.h"
#import "PNLiteVASTXMLUtil.h"

@implementation HyBidMarkupUtils

+ (void)isVastXml:(NSString*) adContent completion:(isVASTXmlCompletionBlock)block {
    NSMutableCharacterSet *ignoredLeadingCharacters = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
    [ignoredLeadingCharacters addCharactersInString:@"\uFEFF"];
    NSString *trimmedAdContent = [adContent stringByTrimmingCharactersInSet:ignoredLeadingCharacters];
    if (![trimmedAdContent hasPrefix:@"<"]) {
        block(NO, nil);
        return;
    }

    NSData *adContentData = [HyBidVASTParser removingVastFirstLineParamsFrom:trimmedAdContent];
    if (!adContentData) {
        block(NO, nil);
        return;
    }

    if (!validateXMLDocSyntax(adContentData)) {
        block(NO, nil);
        return;
    }

    HyBidVASTModel *localVASTModel = [[HyBidVASTModel alloc] initWithData:adContentData];

    NSString *rootElementName = [localVASTModel rootElementName];
    if (!rootElementName || [rootElementName caseInsensitiveCompare:@"VAST"] != NSOrderedSame) {
        block(NO, nil);
        return;
    }

    if ([[localVASTModel ads] count] > 0) {
        block(YES, nil);
        return;
    }

    HyBidVASTParserError *parserError = [HyBidVASTParserError initWithError: [NSError hyBidNullAd] errorTagURLs: localVASTModel.errors];
    block(YES, parserError);
}
@end
