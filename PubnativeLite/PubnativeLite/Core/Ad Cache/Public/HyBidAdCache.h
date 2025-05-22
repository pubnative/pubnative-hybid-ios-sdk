// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

@interface HyBidAdCache : NSObject

@property(nonatomic, strong) NSMutableDictionary *adCache;

+ (instancetype)sharedInstance;
- (void)putAdToCache:(HyBidAd *)ad withZoneID:(NSString *)zoneID;
- (HyBidAd *)retrieveAdFromCacheWithZoneID:(NSString *)zoneID;

@end
