// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGADUtils.h"

NSString *const HyBidGADAdapterKeyZoneID = @"pn_zone_id";
NSString *const HyBidGADAdapterKeyAppToken = @"pn_app_token";

@implementation HyBidGADUtils

+ (BOOL)areExtrasValid:(NSString *)extras {
    if ([HyBidGADUtils zoneID:extras] && [HyBidGADUtils appToken:extras]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)appToken:(NSString *)extras {
    return [HyBidGADUtils valueWithKey:HyBidGADAdapterKeyAppToken fromExtras:extras];
}

+ (NSString *)zoneID:(NSString *)extras {
    return [HyBidGADUtils valueWithKey:HyBidGADAdapterKeyZoneID fromExtras:extras];
}

+ (NSString *)valueWithKey:(NSString *)key
                fromExtras:(NSString *)extras {
    NSString *result = nil;
    if (!extras || [extras length] == 0) {
        return result;
    }
    
    NSData *jsonData = [extras dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return result;
    }
    
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        result = (NSString *)dictionary[key];
    }
    
    return result;
}

// v: 3.6.1
+ (GADVersionNumber)adSDKVersion {
    GADVersionNumber version = {0};
    version.majorVersion = 3;
    version.minorVersion = 6;
    version.patchVersion = 1;
    return version;
}

+ (GADVersionNumber)adapterVersion {
    GADVersionNumber version = {0};
    version.majorVersion = 3;
    version.minorVersion = 6;
    version.patchVersion = 1;
    return version;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

@end
