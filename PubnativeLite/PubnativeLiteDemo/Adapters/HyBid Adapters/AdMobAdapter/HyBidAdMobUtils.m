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

#import "HyBidAdMobUtils.h"

NSString *const HyBidAdMobAdapterKeyZoneID = @"pn_zone_id";
NSString *const HyBidAdMobAdapterKeyAppToken = @"pn_app_token";
NSString *const HyBidAdMobAdapterKeyCPM = @"cpm";

@implementation HyBidAdMobUtils

+ (BOOL)areExtrasValid:(NSString *)extras {
    if ([HyBidAdMobUtils zoneID:extras] && [HyBidAdMobUtils appToken:extras]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)appToken:(NSString *)extras {
    return [HyBidAdMobUtils valueWithKey:HyBidAdMobAdapterKeyAppToken fromExtras:extras];
}

+ (NSString *)zoneID:(NSString *)extras {
    return [HyBidAdMobUtils valueWithKey:HyBidAdMobAdapterKeyZoneID fromExtras:extras];
}

+ (NSString *)eCPM:(NSString *)extras {
    return [HyBidAdMobUtils valueWithKey:HyBidAdMobAdapterKeyCPM fromExtras:extras];
}

+ (NSString *)valueWithKey:(NSString *)key
                fromExtras:(NSString *)extras {
    NSString *result = nil;
    NSData *jsonData = [extras dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        result = [NSString stringWithFormat:@"%@", [dictionary objectForKey:key]];
    }
    
    return result;
}

@end
