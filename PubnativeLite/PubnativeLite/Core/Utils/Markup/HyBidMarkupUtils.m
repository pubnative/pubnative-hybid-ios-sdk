//
//  Copyright © 2020 PubNative. All rights reserved.
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
