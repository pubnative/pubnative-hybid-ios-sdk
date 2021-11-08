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

#import "HyBidRemoteConfigParameter.h"

@implementation HyBidRemoteConfigParameter

+ (NSString *)ttl                           { return @"ttl"; }
+ (NSString *)placementInfo;                { return @"placement_info"; }
+ (NSString *)measurement;                  { return @"measurement"; }
+ (NSString *)timeout;                      { return @"timeout"; }
+ (NSString *)placements;                   { return @"placements"; }
+ (NSString *)viewability;                  { return @"viewability"; }
+ (NSString *)type;                         { return @"type"; }
+ (NSString *)adSources;                    { return @"ad_sources"; }
+ (NSString *)appConfig;                    { return @"app_config"; }
+ (NSString *)appToken;                     { return @"app_token"; }
+ (NSString *)api;                          { return @"api"; }
+ (NSString *)enabledProtocols;             { return @"enabled_protocols"; }
+ (NSString *)enabledAPIs;                  { return @"enabled_apis"; }

@end
