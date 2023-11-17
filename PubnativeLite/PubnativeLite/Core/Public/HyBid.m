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

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

BOOL isInitialized = NO;

#define kATOM_API_KEY @"39a34d8d-dd1d-4fbf-aa96-fdc5f0329451"

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
        [HyBidDiagnosticsManager printDiagnosticsLogWithEvent:HyBidDiagnosticsEventInitialisation];
        [[HyBidSessionManager sharedInstance] setStartSession];
        [[HyBidSessionManager sharedInstance] setAgeOfAppSinceCreated];
        [self startATOM];
    }
    if (completion != nil) {
        completion(isInitialized);
    }
}

+ (void)startATOM
{
    #if __has_include(<ATOM/ATOM-Swift.h>)
    NSError *atomError = nil;
    [Atom startWithApiKey:kATOM_API_KEY isTest:NO error:&atomError withCallback:^(BOOL isSuccess) {
        if (isSuccess) {
            NSArray *atomCohorts = [Atom getCohorts];
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: [[NSString alloc] initWithFormat: @"Received ATOM cohorts: %@", atomCohorts], NSStringFromSelector(_cmd)]];
        } else {
            NSString *atomInitResultMessage = [[NSString alloc] initWithFormat:@"Coultdn't initialize ATOM with error: %@", [atomError localizedDescription]];
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: atomInitResultMessage, NSStringFromSelector(_cmd)]];
        }
    }];
    #endif
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
    PNLiteAdRequestModel* adRequestModel = [[PNLiteAdFactory alloc]createAdRequestWithZoneID:@"" withAppToken:@"" withAdSize:HyBidAdSize.SIZE_INTERSTITIAL withSupportedAPIFrameworks:nil withIntegrationType:IN_APP_BIDDING isRewarded:false mediationVendorName:mediationVendorName];
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

@end
