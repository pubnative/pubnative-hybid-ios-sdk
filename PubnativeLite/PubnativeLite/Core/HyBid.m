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
#if __has_include(<HyBidEdge/HyBidAudienceController.h>)
#import <HyBidEdge/HyBidEdge.h>
@import NumberEight;
@import Audiences;
#endif


NSString *const HyBidBaseURL = @"https://api.pubnative.net";
NSString *const HyBidOpenRTBURL = @"https://dsp.pubnative.net";
NSString *const NumberEightAPIToken = @"T954C5VJTIAXAGMUVPDU0TZMGEV2";

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

+ (void)setSessionTestMode:(BOOL)enabled {
    [HyBidSettings sharedInstance].sessionTest = enabled;
}

+ (void)initWithAppToken:(NSString *)appToken completion:(HyBidCompletionBlock)completion {
    if (!appToken || appToken.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"App Token is nil or empty and required."];
    } else {
        [HyBidSettings sharedInstance].appToken = appToken;
        [HyBidSettings sharedInstance].apiURL = HyBidBaseURL;
        [HyBidSettings sharedInstance].openRtbApiURL = HyBidOpenRTBURL;
        [HyBidViewabilityManager sharedInstance];
        
        #if __has_include(<HyBidEdge/HyBidAudienceController.h>)
            NSLog(@"HyBidAudienceController included");
            HyBidAudienceController* audienceController = [[HyBidAudienceController alloc] init];
            int refreshAudienceInterval = [audienceController getAudienceRefreshFrequencyInHours:(AudienceRefreshSchedule) twicePerDay];
            [audienceController refreshAudience];
            [audienceController scheduleNextAudienceRefreshTimerIn:refreshAudienceInterval];
            
            [[HyBidUserDataManager sharedInstance] createUserDataManagerWithCompletion:^(BOOL success) {
                completion(success);
            }];
            
            [self startRecordingSessions];
            
            [self startNumberEightWithApiKey:NumberEightAPIToken];
            [self startRecordingNumberEightAudiencesWithApiKey:NumberEightAPIToken];
        #endif
       
    }
}

+ (void) setLocationUpdates:(BOOL)enabled {
    PNLiteLocationManager.locationUpdatesEnabled = enabled;
}

+ (void) setLocationTracking:(BOOL)enabled {
    PNLiteLocationManager.locationTrackingEnabled = enabled;
}

+ (NSString *)sdkVersion
{
    return HYBID_SDK_VERSION;
}

+ (void)setInterstitialSkipOffset:(NSInteger)seconds {
    [HyBidSettings sharedInstance].skipOffset = seconds;
}

+ (HyBidReportingManager *)reportingManager {
    return HyBidReportingManager.sharedInstance;
}

+ (void)startRecordingSessions
{
    #if __has_include(<HyBidEdge/HyBidAudienceController.h>)
        [self openSession];
        //    [HyBidAdAnalyticsSession startSession];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSession) name:UIApplicationWillEnterForegroundNotification object:nil];
    #endif
}

+ (void)openSession
{
    #if __has_include(<HyBidEdge/HyBidAudienceController.h>)
        HyBidSessionManager *sessionManager = [[HyBidSessionManager alloc] init];
        [sessionManager openSession];
    #endif
}

+ (void)startRecordingNumberEightAudiencesWithApiKey:(NSString *)apiKey
{
    #if __has_include(<HyBidEdge/HyBidAudienceController.h>)
        NEXAPIToken* token =
        [NEXNumberEight startWithApiKey:apiKey
                          launchOptions:nil
                         consentOptions:[NEXConsentOptions withConsentToAll]
                             completion:nil];
        [NEXAudiences startRecordingWithApiToken:token];
    #endif
}


+ (void)startNumberEightWithApiKey:(NSString *)apiKey
{
    #if __has_include(<HyBidEdge/HyBidAudienceController.h>)
        [NEXNumberEight startWithApiKey:apiKey launchOptions:nil
                         consentOptions:[NEXConsentOptions withConsentToAll]
          facingAuthorizationChallenges:^(NEXAuthorizationSource authSource, id<NEXAuthorizationChallengeResolver> _Nonnull resolver) {
            switch (authSource) {
                case kNEXAuthorizationSourceLocation:
                    [resolver requestAuthorization];
                    break;
                default:
                    break;
            }
        } completion:^(BOOL isSuccess, NSError * _Nullable error) {
            if (isSuccess) {
                NSLog(@"NumberEight SDK Initialisation completed successfully.");
            } else {
                NSString *errorMessage = [NSString stringWithFormat:@"NumberEight SDK Initialisation failed with error: %@", [error localizedDescription]];
                NSLog(@"%@", errorMessage);
            }
        }];
    #endif
}


+ (NSSet *)getNumberEightAudiences
{
    #if __has_include(<HyBidEdge/HyBidAudienceController.h>)
        NSSet *audiences = [NEXAudiences currentMemberships];
        NSLog(@"Audiences %@", audiences); // ["early-risers", "socialites"]
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage: [NSString stringWithFormat:@"Audiences: %@", audiences] ];
        return audiences;
    #endif
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage: @"HyBid Edge not integrated"];
    return nil;
}


@end


