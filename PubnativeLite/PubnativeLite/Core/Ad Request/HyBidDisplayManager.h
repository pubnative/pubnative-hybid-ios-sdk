// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidIntegrationType.h"

@interface HyBidDisplayManager : NSObject

+ (NSString*)getDisplayManagerVersion;
+ (NSString*)getDisplayManagerVersionWithIntegrationType:(IntegrationType)integrationType;
+ (NSString*)getDisplayManagerVersionWithIntegrationType:(IntegrationType)integrationType andWithMediationVendor:(NSString *)mediationVendor;

+ (NSString*)setDisplayManager:(IntegrationType)integrationType;
+ (NSString*)getDisplayManager;

@end
