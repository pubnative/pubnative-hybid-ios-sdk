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
#import "HyBidSettings.h"
#import "HyBidUserDataManager.h"
#import "PNLiteLocationManager.h"
#import "HyBidConstants.h"
#import "HyBidRemoteConfigManager.h"
#import "HyBidDisplayManager.h"
#import "PNLiteAdFactory.h"
#import "HyBidDiagnosticsManager.h"

NSString *const HyBidBaseURL = @"https://api.pubnative.net";
NSString *const HyBidOpenRTBURL = @"https://dsp.pubnative.net";
BOOL isInitialized = NO;

@implementation HyBid

+ (void)setCoppa:(BOOL)enabled {
    [HyBidSettings sharedInstance].coppa = enabled;
}

+ (void)setAppStoreAppID:(NSString *)appID {
    [HyBidSettings sharedInstance].appID = appID;
}

+ (void)setTargeting:(HyBidTargetingModel *)targeting {
    [HyBidSettings sharedInstance].targeting = targeting;
}

+ (void)setTestMode:(BOOL)enabled {
    [HyBidSettings sharedInstance].test = enabled;
}

+ (void)setInterstitialActionBehaviour:(HyBidInterstitialActionBehaviour)behaviour {
    [HyBidSettings sharedInstance].interstitialActionBehaviour = behaviour;
}

+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion {
    if (!appToken || appToken.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"App Token is nil or empty and required."];
        isInitialized = NO;
    } else {
        [HyBidSettings sharedInstance].appToken = appToken;
        [HyBidSettings sharedInstance].apiURL = HyBidBaseURL;
        [HyBidSettings sharedInstance].openRtbApiURL = HyBidOpenRTBURL;
        [HyBidViewabilityManager sharedInstance];
        isInitialized = YES;
        [[HyBidRemoteConfigManager sharedInstance] initializeRemoteConfigWithCompletion:^(BOOL remoteConfigSuccess, HyBidRemoteConfigModel *remoteConfig) {}];
        [HyBidDiagnosticsManager printDiagnosticsLogWithEvent:HyBidDiagnosticsEventInitialisation];       
    }
    if (completion != nil) {
        completion(isInitialized);
    }
}

+ (BOOL)isInitialized {
    return isInitialized;
}

+ (void) setLocationUpdates:(BOOL)enabled {
    PNLiteLocationManager.locationUpdatesEnabled = enabled;
}

+ (void) setLocationTracking:(BOOL)enabled {
    PNLiteLocationManager.locationTrackingEnabled = enabled;
}

+ (NSString *)sdkVersion {
    return HYBID_SDK_VERSION;
}

+ (void)setInterstitialSkipOffset:(NSInteger)seconds {
    [self setVideoInterstitialSkipOffset:seconds];
    [self setHTMLInterstitialSkipOffset:seconds];
}

+ (void)setVideoInterstitialSkipOffset:(NSInteger)seconds {
    [HyBidSettings sharedInstance].videoSkipOffset = seconds;
}

+ (void)setHTMLInterstitialSkipOffset:(NSInteger)seconds {
    [HyBidSettings sharedInstance].htmlSkipOffset = seconds;
}

+ (void)setInterstitialCloseOnFinish:(BOOL)closeOnFinish {
    [HyBidSettings sharedInstance].closeOnFinish = closeOnFinish;
}

+ (HyBidReportingManager *)reportingManager {
    return HyBidReportingManager.sharedInstance;
}

+ (void)setVideoAudioStatus:(HyBidAudioStatus)audioStatus {
    [HyBidSettings sharedInstance].audioStatus = audioStatus;
}

+ (NSString *)getSDKVersionInfo {
    return [HyBidDisplayManager getDisplayManagerVersion];
}

+ (NSString *)getCustomRequestSignalData {
    if (!HyBid.isInitialized) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid SDK was not initialized. Please initialize it before getting Custom Request Signal Data. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process."];
        return @"";
    }
    
    PNLiteAdRequestModel* adRequestModel = [[PNLiteAdFactory alloc]createAdRequestWithZoneID:@"" withAdSize:HyBidAdSize.SIZE_INTERSTITIAL withSupportedAPIFrameworks:nil withIntegrationType:IN_APP_BIDDING isRewarded:false];
    
    HyBidAdRequest* adRequest = [[HyBidAdRequest alloc]init];
    NSURL* url = [adRequest requestURLFromAdRequestModel:adRequestModel];
    
    NSLog(@"requestParametersString %@", url.query);
    return url.query;
}

+ (void)setMRAIDExpand:(BOOL)enabled {
    [HyBidSettings sharedInstance].mraidExpand = enabled;
}

@end
