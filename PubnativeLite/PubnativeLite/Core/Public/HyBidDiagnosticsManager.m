//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidDiagnosticsManager.h"
#import "HyBid.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSString * const GOOGLE_ADS_APP_ID_KEY = @"GADApplicationIdentifier";

// Ad Format Classes
NSString * const AD_FORMAT_BANNER_CLASS = @"HyBidAdView";
NSString * const AD_FORMAT_INTERSTITIAL_CLASS = @"HyBid.HyBidInterstitialAd";
NSString * const AD_FORMAT_REWARDED_CLASS = @"HyBid.HyBidRewardedAd";
NSString * const AD_FORMAT_NATIVE_CLASS = @"HyBidNativeAd";

// GAD (AdMob)Mediation Adapter Classes
NSString * const GAD_MEDIATION_BANNER_ADAPTER_CLASS = @"HyBidGADBannerCustomEvent";
NSString * const GAD_MEDIATION_MRECT_ADAPTER_CLASS = @"HyBidGADMRectCustomEvent";
NSString * const GAD_MEDIATION_LEADERBOARD_ADAPTER_CLASS = @"HyBidGADLeaderboardCustomEvent";
NSString * const GAD_MEDIATION_INTERSTITIAL_ADAPTER_CLASS = @"HyBidGADInterstitialCustomEvent";
NSString * const GAD_MEDIATION_REWARDED_ADAPTER_CLASS = @"HyBidGADRewardedCustomEvent";
NSString * const GAD_MEDIATION_NATIVE_ADAPTER_CLASS = @"HyBidGADNativeCustomEvent";

// GAM (DFP) Header Bidding Adapter Classes
NSString * const GAM_HEADER_BIDDING_BANNER_ADAPTER_CLASS = @"HyBidGAMBannerCustomEvent";
NSString * const GAM_HEADER_BIDDING_MRECT_ADAPTER_CLASS = @"HyBidGAMMRectCustomEvent";
NSString * const GAM_HEADER_BIDDING_LEADERBOARD_ADAPTER_CLASS = @"HyBidGAMLeaderboardCustomEvent";
NSString * const GAM_HEADER_BIDDING_INTERSTITIAL_ADAPTER_CLASS = @"HyBidGAMInterstitialCustomEvent";

@implementation HyBidDiagnosticsManager

+ (void)printDiagnosticsLog {
    [self printDiagnosticsLogWithEvent:HyBidDiagnosticsEventUnknown];
}

+ (void)printDiagnosticsLogWithEvent:(HyBidDiagnosticsEvent)event {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class])
                        fromMethod:NSStringFromSelector(_cmd)
                       withMessage:[self diagnosticsLogForEvent:event]];
}

+ (NSString *)diagnosticsLogForEvent:(HyBidDiagnosticsEvent)event {
    NSMutableString *diagnosticsLogString = [[NSMutableString alloc] init];
    [diagnosticsLogString appendFormat:@"\n\n ------ HyBid Diagnostics Log ------ \n"];
    if ([HyBid isInitialized]) {
        [diagnosticsLogString appendFormat:@"\nEvent: %@", [self getDiagnosticsEventTypeString:event]];
        [diagnosticsLogString appendFormat:@"\nVersion: %@", HyBidConstants.HYBID_SDK_VERSION];
        [diagnosticsLogString appendFormat:@"\nBundle ID: %@", [HyBidSettings sharedInstance].appBundleID];
        [diagnosticsLogString appendFormat:@"\nApp Token: %@", [HyBidSDKConfig sharedConfig].appToken];
        [diagnosticsLogString appendFormat:@"\nTest Mode: %@", [HyBidSDKConfig sharedConfig].test ? @"true" : @"false"];
        [diagnosticsLogString appendFormat:@"\nCOPPA: %@", [HyBidConsentConfig sharedConfig].coppa ? @"true" : @"false"];
        [diagnosticsLogString appendFormat:@"\nApp Level Video Audio State: %@", [self getVideoAudioStateString:[HyBidRenderingConfig sharedConfig].audioStatus]];
        [diagnosticsLogString appendFormat:@"\nLocation Tracking: %@", [HyBidLocationConfig sharedConfig].locationTrackingEnabled ? @"true" : @"false"];
        [diagnosticsLogString appendFormat:@"\nLocation Updates: %@", [HyBidLocationConfig sharedConfig].locationUpdatesEnabled ? @"true" : @"false"];
        [diagnosticsLogString appendFormat:@"\nDate & Time: %@", [self currentDateAndTime]];
        [diagnosticsLogString appendFormat:@"\nDevice OS: %@", [HyBidSettings sharedInstance].os];
        [diagnosticsLogString appendFormat:@"\nDevice OS Version: %@", [HyBidSettings sharedInstance].osVersion];
        [diagnosticsLogString appendFormat:@"\nDevice Model: %@", [UIDevice currentDevice].name];
        [diagnosticsLogString appendString:@"\nDevice Manufacturer: Apple"];
        [diagnosticsLogString appendFormat:@"\nGoogle Ads Application ID: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:GOOGLE_ADS_APP_ID_KEY] ? [[NSBundle mainBundle] objectForInfoDictionaryKey:GOOGLE_ADS_APP_ID_KEY] : @"Not available"];
        [diagnosticsLogString appendFormat:@"\nAvailable Formats:\n%@", [self availableFormats]];
        [diagnosticsLogString appendFormat:@"\nAvailable Google Mobile Ads Adapters:\n%@", [self availableGoogleMobileAdsAdapters]];
    } else {
        [diagnosticsLogString appendString:@"\nHyBid SDK has not been initialised\n"];
    }
    [diagnosticsLogString appendFormat:@"\n ------ HyBid Diagnostics Log ------ \n"];
    return diagnosticsLogString;
}

+ (NSString *)getDiagnosticsEventTypeString:(HyBidDiagnosticsEvent)event {
    switch (event) {
        case HyBidDiagnosticsEventInitialisation:
            return @"Initialisation";
            break;
        case HyBidDiagnosticsEventAdRequest:
            return @"Ad Request";
            break;
        case HyBidDiagnosticsEventUnknown:
            return @"Unknown";
            break;
    }
}

+ (NSString *)getVideoAudioStateString:(HyBidAudioStatus)status {
    switch (status) {
        case HyBidAudioStatusMuted:
            return @"Muted";
            break;
        case HyBidAudioStatusON:
            return @"ON";
            break;
        case HyBidAudioStatusDefault:
            return @"Default";
            break;
    }
}

+ (NSString *)currentDateAndTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)availableFormats {
    NSMutableString *availableFormatsString = [[NSMutableString alloc] init];
    
    if ([self isClassAvailable:AD_FORMAT_BANNER_CLASS]) {
        [availableFormatsString appendString:@"\t- Banner\n"];
    }
    if ([self isClassAvailable:AD_FORMAT_INTERSTITIAL_CLASS]) {
        [availableFormatsString appendString:@"\t- Interstitial\n"];
    }
    if ([self isClassAvailable:AD_FORMAT_REWARDED_CLASS]) {
        [availableFormatsString appendString:@"\t- Rewarded\n"];
    }
    if ([self isClassAvailable:AD_FORMAT_NATIVE_CLASS]) {
        [availableFormatsString appendString:@"\t- Native\n"];
    }
    if ([availableFormatsString length] == 0) {
        [availableFormatsString appendString:@"\t- No formats available\n"];
    }
    
    return availableFormatsString;
}

+ (NSString *)availableGoogleMobileAdsAdapters {
    NSMutableString *availableGoogleMobileAdsAdaptersString = [[NSMutableString alloc] init];
    
    if ([self isClassAvailable:GAD_MEDIATION_BANNER_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAD_MEDIATION_BANNER_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAD_MEDIATION_MRECT_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAD_MEDIATION_MRECT_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAD_MEDIATION_LEADERBOARD_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAD_MEDIATION_LEADERBOARD_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAD_MEDIATION_INTERSTITIAL_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAD_MEDIATION_INTERSTITIAL_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAD_MEDIATION_REWARDED_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAD_MEDIATION_REWARDED_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAD_MEDIATION_NATIVE_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAD_MEDIATION_NATIVE_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAM_HEADER_BIDDING_BANNER_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAM_HEADER_BIDDING_BANNER_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAM_HEADER_BIDDING_MRECT_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAM_HEADER_BIDDING_MRECT_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAM_HEADER_BIDDING_LEADERBOARD_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAM_HEADER_BIDDING_LEADERBOARD_ADAPTER_CLASS];
    }
    if ([self isClassAvailable:GAM_HEADER_BIDDING_INTERSTITIAL_ADAPTER_CLASS]) {
        [availableGoogleMobileAdsAdaptersString appendFormat:@"\t- %@\n", GAM_HEADER_BIDDING_INTERSTITIAL_ADAPTER_CLASS];
    }
    if ([availableGoogleMobileAdsAdaptersString length] == 0) {
        [availableGoogleMobileAdsAdaptersString appendString:@"\t- No Google Mobile Ads adapters available\n"];
    }
    
    return availableGoogleMobileAdsAdaptersString;
}

+ (BOOL)isClassAvailable:(NSString *)className {
    return NSClassFromString(className) ? YES : NO;
}

@end
