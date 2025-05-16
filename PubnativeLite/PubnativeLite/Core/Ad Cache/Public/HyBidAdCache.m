// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
