// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@import GoogleMobileAds;

@interface HyBidGADUtils : NSObject

+ (BOOL)areExtrasValid:(NSString *)extras;
+ (NSString *)appToken:(NSString *)extras;
+ (NSString *)zoneID:(NSString *)extras;
+ (GADVersionNumber)adSDKVersion;
+ (GADVersionNumber)adapterVersion;
+ (Class<GADAdNetworkExtras>)networkExtrasClass;

@end
