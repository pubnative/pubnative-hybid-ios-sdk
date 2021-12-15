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

#import "HyBidRemoteConfigAppConfig.h"
#import "HyBidRemoteConfigParameter.h"

@implementation NSString (EnumParser)

- (HyBidApiType)apiTypeFromString
{
    NSDictionary<NSString *, NSNumber *> *apiTypes = @{
        @"open_rtb"  : @(HyBidApiOpenRTB),
        @"online_api": @(HyBidApiLegacy)
    };
    
    return apiTypes[self].integerValue;
}

@end

@implementation HyBidRemoteConfigAppConfig

- (void)dealloc {
    self.appToken = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([[dictionary objectForKey:HyBidRemoteConfigParameter.appToken] respondsToSelector:@selector(stringValue)]) {
            self.appToken = [dictionary[HyBidRemoteConfigParameter.appToken] stringValue];
        }
        else {
            self.appToken = dictionary[HyBidRemoteConfigParameter.appToken];
        }
        
        if ([[dictionary objectForKey:HyBidRemoteConfigParameter.api] respondsToSelector:@selector(stringValue)]) {
            self.apiType = [[dictionary[HyBidRemoteConfigParameter.api] stringValue] apiTypeFromString];
        }
        else {
            self.apiType = [dictionary[HyBidRemoteConfigParameter.api] apiTypeFromString];
        }
        self.enabledProtocols = dictionary[HyBidRemoteConfigParameter.enabledProtocols];
        self.enabledAPIs = dictionary[HyBidRemoteConfigParameter.enabledAPIs];
        self.features = [[HyBidRemoteConfigAppFeatures alloc] initWithDictionary:dictionary[HyBidRemoteConfigParameter.features]];
    }
    return self;
}

@end
