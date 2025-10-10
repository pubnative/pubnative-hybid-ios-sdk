// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDisplayManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSString * const DISPLAY_MANAGER_NAME = @"HyBid";
NSString * const DISPLAY_MANAGER_ENGINE = @"sdkios";

NSString * const SMAATO_DISPLAY_MANAGER_NAME = @"Smaato";

@implementation HyBidDisplayManager

+ (NSString*)getDisplayManagerVersion {
    return [HyBidDisplayManager setDisplayManager:IN_APP_BIDDING];
}

+ (NSString *)getDisplayManagerVersionWithIntegrationType:(IntegrationType)integrationType
{
    return [self getDisplayManagerVersionWithIntegrationType:integrationType andWithMediationVendor:nil];
}

+ (NSString *)getDisplayManagerVersionWithIntegrationType:(IntegrationType)integrationType andWithMediationVendor:(NSString *)mediationVendor
{
    NSString *mediationValue = @"";
    
    if (mediationVendor != nil && [mediationVendor length] > 0) {
        mediationValue = [[NSString alloc] initWithFormat:@"_%@", mediationVendor];
    }
    
    return [[NSString alloc] initWithFormat:@"%@_%@%@_%@", DISPLAY_MANAGER_ENGINE, [HyBidIntegrationType integrationTypeToString:integrationType], mediationValue, HyBidConstants.HYBID_SDK_VERSION];
}

+ (NSString*)setDisplayManager:(IntegrationType)integrationType {
    return [NSString stringWithFormat:@"%@_%@_%@", DISPLAY_MANAGER_ENGINE, [HyBidIntegrationType integrationTypeToString:integrationType] ,HyBidConstants.HYBID_SDK_VERSION];
}

+ (NSString*)getDisplayManager {
    return DISPLAY_MANAGER_NAME;
}

+ (NSString *)getSmaatoDisplayManager {
    return SMAATO_DISPLAY_MANAGER_NAME;
}

+ (NSString *)getSmaatoDisplayManagerVersion {
    return [NSString stringWithFormat:@"sdk_%@", HyBidConstants.SMAATO_SDK_VERSION];
}

@end
