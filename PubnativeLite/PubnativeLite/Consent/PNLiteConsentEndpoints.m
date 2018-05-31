//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "PNLiteConsentEndpoints.h"

NSString *const kScheme = @"https://";
NSString *const kAuthority = @"backend.pubnative.net/";
NSString *const kConsentPath = @"consent/";
NSString *const kAPIVersion = @"v1";
NSString *const kParamAppToken = @"/app_token";
NSString *const kParamDeviceID = @"/did";
NSString *const kParamDeviceType = @"/did_type";

@implementation PNLiteConsentEndpoints

+ (NSString *)checkConsentURLWithAppToken:(NSString *)appToken withDeviceID:(NSString *)deviceID withDeviceType:(NSString *)deviceType
{
    NSString *urlString = [[NSString alloc] init];
    urlString = [urlString stringByAppendingString:kScheme];
    urlString = [urlString stringByAppendingString:kAuthority];
    urlString = [urlString stringByAppendingString:kConsentPath];
    urlString = [urlString stringByAppendingString:kAPIVersion];
    urlString = [urlString stringByAppendingString:kParamAppToken];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"/%@",appToken]];
    urlString = [urlString stringByAppendingString:kParamDeviceID];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"/%@",deviceID]];
    urlString = [urlString stringByAppendingString:kParamDeviceType];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"/%@",deviceType]];
    return urlString;
}

+ (NSString *)consentURL
{
    NSString *urlString = [[NSString alloc] init];
    urlString = [urlString stringByAppendingString:kScheme];
    urlString = [urlString stringByAppendingString:kAuthority];
    urlString = [urlString stringByAppendingString:kConsentPath];
    urlString = [urlString stringByAppendingString:kAPIVersion];
    return urlString;
}
@end
