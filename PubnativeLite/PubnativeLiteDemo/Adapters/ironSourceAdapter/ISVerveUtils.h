// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "IronSource/ISAdData.h"

@interface ISVerveUtils : NSObject

+ (BOOL)isAppTokenValid:(ISAdData *)adData;
+ (BOOL)isZoneIDValid:(ISAdData *)adData;
+ (NSString *)appToken:(ISAdData *)adData;
+ (NSString *)zoneID:(ISAdData *)adData;
+ (NSString *)mediationVendor;

@end
