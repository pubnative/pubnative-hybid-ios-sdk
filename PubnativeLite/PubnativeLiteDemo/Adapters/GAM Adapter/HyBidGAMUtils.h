// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@import GoogleMobileAds;

@interface HyBidGAMUtils : NSObject

+ (BOOL)areExtrasValid:(NSString *)extras;
+ (NSString *)zoneID:(NSString *)extras;
+ (GADVersionNumber)adSDKVersion;
+ (GADVersionNumber)adapterVersion;
+ (Class<GADAdNetworkExtras>)networkExtrasClass;

@end
