// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "ISVerveUtils.h"

NSString *const ISVerveAdapterKeyZoneID = @"zoneId";
NSString *const ISVerveAdapterKeyAppToken = @"appToken";

@implementation ISVerveUtils

+ (BOOL)isAppTokenValid:(ISAdData *)adData {
    return ([ISVerveUtils appToken:adData] && [ISVerveUtils appToken:adData].length != 0);
}

+ (BOOL)isZoneIDValid:(ISAdData *)adData {
    return ([ISVerveUtils zoneID:adData] && [ISVerveUtils zoneID:adData].length != 0);
}

+ (NSString *)appToken:(ISAdData *)adData {
    return [adData getString:ISVerveAdapterKeyAppToken];
}

+ (NSString *)zoneID:(ISAdData *)adData {
    return [adData getString:ISVerveAdapterKeyZoneID];
}

+ (NSString *)mediationVendor {
    return @"lp";
}

@end
