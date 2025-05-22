// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidMarkupUtils.h"
#import "HyBidError.h"
#import "HyBidVASTParserError.h"

@implementation HyBidMarkupUtils

+ (void)isVastXml:(NSString*) adContent completion:(isVASTXmlCompletionBlock)block {    NSError* error = NULL;
    NSRegularExpression* regexUppercase = [NSRegularExpression regularExpressionWithPattern:@"(<VAST[\\s\\S]*?>)[\\s\\S]*<\\/VAST>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression* regexLowercase = [NSRegularExpression regularExpressionWithPattern:@"(<vast[\\s\\S]*?>)[\\s\\S]*<\\/vast>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *upperCaseMatch = [regexUppercase firstMatchInString:adContent options:0 range:NSMakeRange(0, [adContent length])];
    NSTextCheckingResult *lowerCaseMatch = [regexLowercase firstMatchInString:adContent options:0 range:NSMakeRange(0, [adContent length])];
    
    HyBidVASTModel *localVASTModel = [[HyBidVASTModel alloc] initWithData:[adContent dataUsingEncoding:NSUTF8StringEncoding]];

        // Check if contains VAST
        if (upperCaseMatch || lowerCaseMatch) {
            if ([[localVASTModel ads] count] > 0) {
                block(YES, nil);
            } else {
                HyBidVASTParserError *error = [HyBidVASTParserError initWithError: [NSError hyBidNullAd] errorTagURLs: localVASTModel.errors];
                block(YES, error);
            }
        } else {
            block(NO, nil);
        }
}
@end
