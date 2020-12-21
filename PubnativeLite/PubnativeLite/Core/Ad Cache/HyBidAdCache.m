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

#import "HyBidAdCache.h"

@implementation HyBidAdCache

- (void)dealloc
{
    self.adCache = nil;
}

+ (instancetype)sharedInstance {
    static HyBidAdCache *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HyBidAdCache alloc] init];
        _sharedInstance.adCache = [[NSMutableDictionary alloc] init];
    });
    return _sharedInstance;
}

- (void)putAdToCache:(HyBidAd *)ad withZoneID:(NSString *)zoneID {
    [[HyBidAdCache sharedInstance].adCache setObject:ad forKey:zoneID];
}

- (HyBidAd *)retrieveAdFromCacheWithZoneID:(NSString *)zoneID {
    HyBidAd *cachedAd = [[HyBidAdCache sharedInstance].adCache objectForKey:zoneID];
    [[HyBidAdCache sharedInstance].adCache removeObjectForKey:zoneID];
    return cachedAd;
}

@end
