//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "HyBid.h"
#import "HyBidUserDataManager.h"
#import "PNLiteLocationManager.h"
#import "HyBidDisplayManager.h"
#import "PNLiteAdFactory.h"
#import "HyBidDiagnosticsManager.h"
#import "HyBidATOMFlow.h"
#import "HyBidConfigManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

BOOL isInitialized = NO;

@implementation HyBid

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
        [[HyBidConfigManager sharedManager] requestConfigWithCompletion:^(HyBidConfig *config, NSError *error) {
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

+ (NSString *)getCustomRequestSignalData:(NSString *)mediationVendorName {
    PNLiteAdRequestModel* adRequestModel = [[PNLiteAdFactory alloc]createAdRequestWithZoneID:@"" withAppToken:@"" withAdSize:HyBidAdSize.SIZE_INTERSTITIAL withSupportedAPIFrameworks:nil withIntegrationType:IN_APP_BIDDING isRewarded:false isUsingOpenRTB:false mediationVendorName:mediationVendorName];
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

+ (void)setReporting:(BOOL)enabled {
    [HyBidSDKConfig sharedConfig].reporting = enabled;
}

+ (void)rightToBeForgotten {
    for (NSString *key in [HyBidGDPR allGDPRKeys]) { [NSUserDefaults.standardUserDefaults removeObjectForKey: key]; }
}

@end
