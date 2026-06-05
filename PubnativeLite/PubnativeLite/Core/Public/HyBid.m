// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBid.h"
#import "HyBidUserDataManager.h"
#import "PNLiteLocationManager.h"
#import "HyBidDisplayManager.h"
#import "PNLiteAdFactory.h"
#import "HyBidDiagnosticsManager.h"
#import "HyBidATOMFlow.h"
#import "HyBidConfigManager.h"
#import "HyBidStringUtils.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

BOOL isInitialized = NO;

@implementation HyBid

static SDKIntegrationType _sdkIntegrationType = SDKIntegrationTypeHyBid;

+ (void)setCoppa:(BOOL)enabled {
    [HyBidConsentConfig sharedConfig].coppa = enabled;
}

+ (void)setAppStoreAppID:(NSString *)appID {
    [HyBidSDKConfig sharedConfig].appID = appID;
}

+ (void)setTargeting:(HyBidTargetingModel *)targeting {
    [HyBidSDKConfig sharedConfig].targeting = targeting;
}

+ (void)setTestMode:(BOOL)enabled {
    [HyBidSDKConfig sharedConfig].test = enabled;
}

+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion {
    if (!appToken || appToken.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"App Token is nil or empty and required."];
        isInitialized = NO;
    } else {
        [HyBidSDKConfig sharedConfig].appToken = appToken;
        [HyBidViewabilityManager sharedInstance];
        isInitialized = YES;
        HyBidConfigManager *configManager = [HyBidConfigManager new];
        [configManager requestConfigWithCompletion:^(HyBidConfig *config, NSError *error) {
            if (error == nil) {
                if (config.atomEnabled) {
                    [HyBidSDKConfig sharedConfig].atomEnabled = config.atomEnabled;
                } else {
                    [HyBidSDKConfig sharedConfig].atomEnabled = NO;
                }
            } else {
                [HyBidSDKConfig sharedConfig].atomEnabled = NO;
            }
            [HyBidATOMFlow initFlow];
        }];
        [HyBidDiagnosticsManager printDiagnosticsLogWithEvent:HyBidDiagnosticsEventInitialisation];
        [[HyBidSessionManager sharedInstance] setStartSession];
        [[HyBidSessionManager sharedInstance] setAgeOfAppSinceCreated];
    }
    if (completion != nil) {
        completion(isInitialized);
    }
}

+ (BOOL)isInitialized {
    return isInitialized;
}

+ (void)setLocationUpdates:(BOOL)enabled {
    [HyBidLocationConfig sharedConfig].locationUpdatesEnabled = enabled;
}

+ (void)setLocationTracking:(BOOL)enabled {
    [HyBidLocationConfig sharedConfig].locationTrackingEnabled = enabled;
}

+ (NSString *)sdkVersion {
    return HyBidConstants.HYBID_SDK_VERSION;
}

+ (HyBidReportingManager *)reportingManager {
    return HyBidReportingManager.sharedInstance;
}

+ (NSString *)getSDKVersionInfo {
    return [HyBidDisplayManager getDisplayManagerVersion];
}

+ (NSString *)getCustomRequestSignalData {
    return [self getCustomRequestSignalData:nil];
}

+ (NSString *)getMinimizedCustomRequestSignalData {
    return [self getCustomRequestSignalData:nil minimize:YES];
}

+ (NSString *)getCustomRequestSignalData:(NSString *)mediationVendorName {
    return [self getCustomRequestSignalData:mediationVendorName minimize:NO];
}

+ (NSString *)getCustomRequestSignalData:(NSString *)mediationVendorName minimize:(BOOL)minimize {
    PNLiteAdRequestModel* adRequestModel = [[PNLiteAdFactory alloc]createAdRequestWithZoneID:@"" withAppToken:@"" withAdSize:HyBidAdSize.SIZE_INTERSTITIAL withSupportedAPIFrameworks:nil withIntegrationType:IN_APP_BIDDING isRewarded:NO isUsingOpenRTB:NO mediationVendorName:mediationVendorName];
    if (minimize) {
        [adRequestModel.requestParameters removeObjectForKey:HyBidRequestParameter.skAdNetworkAdNetworkIDs];
    }
    HyBidAdRequest* adRequest = [[HyBidAdRequest alloc]init];
    NSURL* url = [adRequest requestURLFromAdRequestModel:adRequestModel];
    if (!url) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Signal Data URL is nil"];
        return nil;
    }
    NSString *logMessage = [NSString stringWithFormat:@"Signal Data Parameters String: %@", url.query];
    [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:logMessage];
    return url.query;
}

+ (NSString*)getEncodedCustomRequestSignalData {
    return [self encodeToBase64: [self getCustomRequestSignalData]];
}

+ (NSString *)getEncodedMinimizedCustomRequestSignalData {
    return [self encodeToBase64: [self getMinimizedCustomRequestSignalData]];
}

+ (NSString*)getEncodedCustomRequestSignalData:(NSString*) mediationVendorName {
    return [self encodeToBase64: [self getCustomRequestSignalData:mediationVendorName minimize:NO]];
}

+ (NSString*)getEncodedCustomRequestSignalData:(NSString*) mediationVendorName minimize:(BOOL)minimize  {
    return [self encodeToBase64: [self getCustomRequestSignalData:mediationVendorName minimize:minimize]];
}

+ (NSString *)encodeToBase64:(NSString *)string {
    NSString *empty = @"";
    if (!string) {
        return empty;
    }
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return empty;
    }
    
    NSString *base64Encoded = [data base64EncodedStringWithOptions:0];
    if (![base64Encoded isKindOfClass:[NSString class]]) {
        return empty;
    }
    
    NSString *urlSafe = [HyBidStringUtils safeReplaceInValue:base64Encoded target:@"+" replacement:@"-"] ?: base64Encoded;
    urlSafe = [HyBidStringUtils safeReplaceInValue:urlSafe target:@"/" replacement:@"_"] ?: urlSafe;
    urlSafe = [HyBidStringUtils safeTrimInValue:urlSafe characterSet:[NSCharacterSet characterSetWithCharactersInString:@"="]] ?: urlSafe;

    return urlSafe ?: empty;
}

+ (void)setReporting:(BOOL)enabled {
    [HyBidSDKConfig sharedConfig].reporting = enabled;
}

+ (void)rightToBeForgotten {
    for (NSString *key in [HyBidGDPR allGDPRKeys]) { [NSUserDefaults.standardUserDefaults removeObjectForKey: key]; }
}

+ (SDKIntegrationType)getIntegrationType {
    return _sdkIntegrationType;
}

+ (void)setIntegrationType:(SDKIntegrationType)integrationType {
    if (integrationType == 0) {
        _sdkIntegrationType = SDKIntegrationTypeHyBid;
    } else {
        _sdkIntegrationType = integrationType;
    }
}
@end

