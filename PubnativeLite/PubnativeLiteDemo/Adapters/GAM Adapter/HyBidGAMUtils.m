// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGAMUtils.h"

NSString *const PNLiteGAMAdapterKeyZoneID = @"pn_zone_id";

@implementation HyBidGAMUtils

+ (BOOL)areExtrasValid:(NSString *)extras {
    if ([HyBidGAMUtils zoneID:extras]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)zoneID:(NSString *)extras {
    return [HyBidGAMUtils valueWithKey:PNLiteGAMAdapterKeyZoneID fromExtras:extras];
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

// v: 3.6.1-beta2
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
