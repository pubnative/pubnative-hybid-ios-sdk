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

#import "HyBidRemoteConfigEndpoints.h"
#import "HyBidSettings.h"

NSString *const kRemoteConfigScheme = @"https";
NSString *const kRemoteConfigAuthority = @"hbrc.pubnative.net";
NSString *const kRemoteConfigPath = @"config";
NSString *const kRemoteConfigDefaultPath = @"default";
NSString *const kRemoteConfigAPIVersion = @"v1";

@implementation HyBidRemoteConfigEndpoints

+ (NSString *)remoteConfigURL {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kRemoteConfigScheme;
    components.host = kRemoteConfigAuthority;
    components.path = [NSString stringWithFormat:@"/%@/%@/%@/%@",kRemoteConfigPath,kRemoteConfigAPIVersion,kRemoteConfigDefaultPath,[HyBidSettings sharedInstance].appToken];
    
    return [NSString stringWithFormat:@"%@", components.URL];
}

@end
