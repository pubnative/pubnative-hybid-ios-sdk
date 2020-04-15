//
//  Copyright © 2019 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
