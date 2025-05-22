// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVideoAdCacheItem.h"

@interface HyBidVideoAdCache : NSObject

@property(nonatomic, strong) NSMutableDictionary *videoAdCache;

+ (instancetype)sharedInstance;
- (void)putVideoAdCacheItemToCache:(HyBidVideoAdCacheItem *)videoAdCacheItem withZoneID:(NSString *)zoneID;
- (HyBidVideoAdCacheItem *)retrieveVideoAdCacheItemFromCacheWithZoneID:(NSString *)zoneID;

@end
