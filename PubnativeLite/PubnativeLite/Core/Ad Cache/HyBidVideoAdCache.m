// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVideoAdCache.h"

@implementation HyBidVideoAdCache

- (void)dealloc {
    self.videoAdCache = nil;
}

+ (instancetype)sharedInstance {
    static HyBidVideoAdCache *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HyBidVideoAdCache alloc] init];
        _sharedInstance.videoAdCache = [[NSMutableDictionary alloc] init];
    });
    return _sharedInstance;
}

- (void)putVideoAdCacheItemToCache:(HyBidVideoAdCacheItem *)videoAdCacheItem withZoneID:(NSString *)zoneID {
    [[HyBidVideoAdCache sharedInstance].videoAdCache setObject:videoAdCacheItem forKey:zoneID];
}

- (HyBidVideoAdCacheItem *)retrieveVideoAdCacheItemFromCacheWithZoneID:(NSString *)zoneID {
    HyBidVideoAdCacheItem *cachedVideoAdItem = [[HyBidVideoAdCache sharedInstance].videoAdCache objectForKey:zoneID];
    [[HyBidVideoAdCache sharedInstance].videoAdCache removeObjectForKey:zoneID];
    return cachedVideoAdItem;
}

@end
