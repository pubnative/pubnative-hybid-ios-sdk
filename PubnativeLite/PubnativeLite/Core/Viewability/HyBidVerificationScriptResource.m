// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVerificationScriptResource.h"

@implementation HyBidVerificationScriptResource

static NSString *const RESPONSE_KEY_CONFIG = @"config";
static NSString *const PATTERN_SRC_VALUE = @"src=\"(.*?)\"";
static NSString *const PATTERN_VENDORKEY_VALUE = @"vk=(.*?);";
static NSString *const KEY_HASH = @"#";

@synthesize url,vendorKey,params;

//Parsing Viewability dictionary from ad server response into url, vendorkey and params

- (void)hyBidVerificationScriptResource:(NSDictionary *)jsonDic {
    NSString *configString = jsonDic[RESPONSE_KEY_CONFIG];
    if (configString.length == 0) {
        return;
    }
    
    NSRegularExpression *regexSrc = [NSRegularExpression regularExpressionWithPattern:PATTERN_SRC_VALUE
                                                                              options:0 error:NULL];
    NSTextCheckingResult *srcStringMatcher = [regexSrc firstMatchInString:configString options:0 range:NSMakeRange(0, [configString length])];
    if (srcStringMatcher != nil) {
        NSString *src = [configString substringWithRange:[srcStringMatcher rangeAtIndex:1]];
        NSArray *arrVerificationScriptResource = [src componentsSeparatedByString:KEY_HASH];
        url = arrVerificationScriptResource[0];
        params = arrVerificationScriptResource[1];
        
        NSRegularExpression *regexVK = [NSRegularExpression regularExpressionWithPattern:PATTERN_VENDORKEY_VALUE
                                                                                 options:0 error:NULL];
        NSTextCheckingResult *vkStringMatcher = [regexVK firstMatchInString:configString options:0 range:NSMakeRange(0, [configString length])];
        if (vkStringMatcher != nil) {
            vendorKey = [configString substringWithRange:[vkStringMatcher rangeAtIndex:1]];
        }
    }
}

@end
