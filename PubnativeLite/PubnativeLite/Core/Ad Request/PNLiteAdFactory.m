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

#import "PNLiteAdFactory.h"
#import "HyBidRequestParameter.h"
#import "PNLiteCryptoUtils.h"
#import "PNLiteMeta.h"
#import "PNLiteAsset.h"
#import "HyBidUserDataManager.h"
#import "HyBidSkAdNetworkRequestModel.h"
#import "HyBidDisplayManager.h"
#import "HyBidAPI.h"
#import "HyBidProtocol.h"
#import <CoreLocation/CoreLocation.h>

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

@interface PNLiteAdFactory ()

@property (nonatomic, strong) PNLiteAdRequestModel *adRequestModel;

@end

@implementation PNLiteAdFactory

- (PNLiteAdRequestModel *)createAdRequestWithZoneID:(NSString *)zoneID
                                       withAppToken:(NSString *)apptoken
                                         withAdSize:(HyBidAdSize *)adSize
                         withSupportedAPIFrameworks:(NSArray<NSString *> *)supportedAPIFrameworks
                                withIntegrationType:(IntegrationType)integrationType
                                         isRewarded:(BOOL)isRewarded
                                mediationVendorName: (NSString*) mediationVendorName{
    self.adRequestModel = [[PNLiteAdRequestModel alloc] init];
    self.adRequestModel.requestParameters[HyBidRequestParameter.zoneId] = zoneID;
    if (apptoken) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.appToken] = apptoken;
    } else {
        self.adRequestModel.requestParameters[HyBidRequestParameter.appToken] = [HyBidSDKConfig sharedConfig].appToken;
    }
    if (mediationVendorName) {
        self.mediationVendor = mediationVendorName;
    }
    self.adRequestModel.requestParameters[HyBidRequestParameter.os] = [HyBidSettings sharedInstance].os;
    self.adRequestModel.requestParameters[HyBidRequestParameter.osVersion] = [HyBidSettings sharedInstance].osVersion;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceOsVersion] = [HyBidSettings sharedInstance].osVersion;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceModel] = [HyBidSettings sharedInstance].deviceModel;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceMake] = [HyBidSettings sharedInstance].deviceMake;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceType] = [HyBidSettings sharedInstance].deviceType;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceModelIdentifier] = [HyBidSettings sharedInstance].deviceModelIdentifier;
    self.adRequestModel.requestParameters[HyBidRequestParameter.screenWidthInPixels] = [HyBidSettings sharedInstance].screenWidthInPixels;
    self.adRequestModel.requestParameters[HyBidRequestParameter.screenHeightInPixels] = [HyBidSettings sharedInstance].screenHeightInPixelss;
    self.adRequestModel.requestParameters[HyBidRequestParameter.js] = [HyBidSettings sharedInstance].jsValue;
    self.adRequestModel.requestParameters[HyBidRequestParameter.pxRatio] = [HyBidSettings sharedInstance].pxRatio;
    self.adRequestModel.requestParameters[HyBidRequestParameter.language] = [HyBidSettings sharedInstance].language;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceWidth] = [HyBidSettings sharedInstance].deviceWidth;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceHeight] = [HyBidSettings sharedInstance].deviceHeight;
    self.adRequestModel.requestParameters[HyBidRequestParameter.orientation] = [HyBidSettings sharedInstance].orientation;
    self.adRequestModel.requestParameters[HyBidRequestParameter.coppa] = [HyBidConsentConfig sharedConfig].coppa ? @"1" : @"0";
    self.adRequestModel.requestParameters[HyBidRequestParameter.charging] = [HyBidSettings sharedInstance].isDeviceCharging;
    if ([HyBidSettings sharedInstance].batteryLevel) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.batteryLevel] = [HyBidSettings sharedInstance].batteryLevel;
    }
    self.adRequestModel.requestParameters[HyBidRequestParameter.batterySaver] = [HyBidSettings sharedInstance].batterySaver;
    if ([HyBidSettings sharedInstance].isAirplaneModeEnabled) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.airplaneMode] = [HyBidSettings sharedInstance].isAirplaneModeEnabled;
    }
    if([HyBidSettings sharedInstance].totalDiskSpace) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.totalDiskSpace] = [HyBidSettings sharedInstance].totalDiskSpace;
    }
    if([HyBidSettings sharedInstance].availableDiskSpace) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.availableDiskSpace] = [HyBidSettings sharedInstance].availableDiskSpace;
    }
    [self setIDFA:self.adRequestModel];
    
    NSString *locale = [HyBidSettings sharedInstance].locale;
    if (locale && [locale length] != 0){
        self.adRequestModel.requestParameters[HyBidRequestParameter.locale] = locale;
    }
    if (@available(iOS 16.0, *)) {
        
    } else {
        NSString *carrierName = [HyBidSettings sharedInstance].carrierName;
        NSString *carrierMCCMNC = [HyBidSettings sharedInstance].carrierMCCMNC;
        
        if (carrierName != nil) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.carrier] = carrierName;
        }
        if (carrierMCCMNC != nil) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.carrierMCCMNC] = carrierMCCMNC;
        }
    }

    BOOL isUsingOpenRTB = [[NSUserDefaults standardUserDefaults] boolForKey:kIsUsingOpenRTB];
    if (isUsingOpenRTB) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.ip] = [HyBidSettings sharedInstance].ip;
    }
    
    self.adRequestModel.requestParameters[HyBidRequestParameter.versionOfOMSDKIntegration] = HyBidConstants.HYBID_OMSDK_VERSION;
    self.adRequestModel.requestParameters[HyBidRequestParameter.identifierOfOMSDKIntegration] = HyBidConstants.HYBID_OMSDK_IDENTIFIER;
//    adRequestModel.requestParameters[HyBidRequestParameter.supportedAPIFrameworks] = [supportedAPIFrameworks componentsJoinedByString:@","];
    self.adRequestModel.requestParameters[HyBidRequestParameter.identifierForVendor] = [HyBidSettings sharedInstance].identifierForVendor;
    
    if (@available(iOS 14, *)) {
        if ([HyBidSettings sharedInstance].appTrackingTransparency) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.appTrackingTransparency] = [[HyBidSettings sharedInstance].appTrackingTransparency stringValue];
        }
        self.adRequestModel.requestParameters[HyBidRequestParameter.geoFetch] = [HyBidSettings sharedInstance].geoFetchSupport;
    }
    
    if (@available(iOS 14.1, *)) {
        if ([HyBidSettings sharedInstance].connectionType) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.connectiontype] = [HyBidSettings sharedInstance].connectionType;
        }
    }
    
    if (@available(iOS 11.3, *)) {
        HyBidSkAdNetworkRequestModel *skAdNetworkRequestModel = [[HyBidSkAdNetworkRequestModel alloc] init];
    
        NSString *adIDs = [skAdNetworkRequestModel getSkAdNetworkAdNetworkIDsString];
        if ([adIDs length] > 0) {
            if ([skAdNetworkRequestModel getAppID] && [[skAdNetworkRequestModel getAppID] length] > 0) {
                self.adRequestModel.requestParameters[HyBidRequestParameter.skAdNetworkAppID] = [skAdNetworkRequestModel getAppID];
            } else {
                self.adRequestModel.requestParameters[HyBidRequestParameter.skAdNetworkAppID] = @"0";
            }
            self.adRequestModel.requestParameters[HyBidRequestParameter.skAdNetworkAdNetworkIDs] = adIDs;
            self.adRequestModel.requestParameters[HyBidRequestParameter.skAdNetworkVersion] = [skAdNetworkRequestModel getSkAdNetworkVersion];
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"No SKAdNetworkIdentifier items were found in `info.plist` file. Please add the required items and try again."];
        }
    }
    
    NSString* privacyString = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
    if (!([privacyString length] == 0)) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.usprivacy] = privacyString;
    }
    
    NSString* consentString = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
    if (!([consentString length] == 0)) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.userconsent] = consentString;
    }
    
    if (![HyBidConsentConfig sharedConfig].coppa && ![[HyBidUserDataManager sharedInstance] isCCPAOptOut] && ![[HyBidUserDataManager sharedInstance] isConsentDenied]) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.age] = [[HyBidSDKConfig sharedConfig].targeting.age stringValue];
        self.adRequestModel.requestParameters[HyBidRequestParameter.gender] = [HyBidSDKConfig sharedConfig].targeting.gender;
        self.adRequestModel.requestParameters[HyBidRequestParameter.keywords] = [[HyBidSDKConfig sharedConfig].targeting.interests componentsJoinedByString:@","];
        
        if ([HyBidLocationConfig sharedConfig].locationTrackingEnabled) {
            CLLocation* location = [HyBidSettings sharedInstance].location;
            
            if (location && location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) {
                NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
                NSString* lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
                NSString *accuracy = [NSString stringWithFormat:@"%d", (int)round(location.horizontalAccuracy)];

                self.adRequestModel.requestParameters[HyBidRequestParameter.lat] = lat;
                self.adRequestModel.requestParameters[HyBidRequestParameter.lon] = lon;
                if (accuracy != nil && accuracy >= 0) {
                    self.adRequestModel.requestParameters[HyBidRequestParameter.accuracy] = accuracy;
                    self.adRequestModel.requestParameters[HyBidRequestParameter.utcoffset] = [self formatUTCTime];
                }

            }
        }
    }
    
    self.adRequestModel.requestParameters[HyBidRequestParameter.rewardedVideo] = isRewarded ? @"1" : @"0";
        
    self.adRequestModel.requestParameters[HyBidRequestParameter.test] = [HyBidSDKConfig sharedConfig].test ? @"1" : @"0";
    if (![adSize.layoutSize isEqualToString:@"native"]) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.assetLayout] = adSize.layoutSize;
        
        if (adSize.width != 0) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.width] = [@(adSize.width) stringValue];
        }
        if (adSize.height != 0) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.height] = [@(adSize.height) stringValue];
        }
    } else {
        [self setDefaultAssetFields:self.adRequestModel];
    }
    
    NSString *sessionDuration = [[HyBidSessionManager sharedInstance] sessionDuration];
    if (sessionDuration && [sessionDuration length] != 0){
        self.adRequestModel.requestParameters[HyBidRequestParameter.sessionDuration] = sessionDuration;
    }
    
    NSDictionary *impressionDepth = [[HyBidSessionManager sharedInstance] impressionCounter];
    if (impressionDepth && [impressionDepth count] != 0) {
        NSString *value = impressionDepth[zoneID];
        self.adRequestModel.requestParameters[HyBidRequestParameter.impressionDepth] = [NSString stringWithFormat:@"%@", value];
    }
    
    NSString *ageOfApp = [[HyBidSessionManager sharedInstance] getAgeOfApp];
    if (ageOfApp != nil){
        self.adRequestModel.requestParameters[HyBidRequestParameter.ageOfApp] = ageOfApp;
    }

    #if __has_include(<ATOM/ATOM-Swift.h>)
    SEL vgParameterBase64StringSelector = NSSelectorFromString(@"vgParameterBase64String");
    
    if ([Atom respondsToSelector: vgParameterBase64StringSelector]) {
        NSString *vgParameter = [Atom performSelector:vgParameterBase64StringSelector];
        
        if (vgParameter != nil) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.vg] = vgParameter;
        }
    }
    #endif
    
    [self setDefaultMetaFields:self.adRequestModel];
    [self setDisplayManager:self.adRequestModel withIntegrationType:integrationType];
    [self setSupportedAPIs:self.adRequestModel];
    [self setSupportedProtocols:self.adRequestModel];
    
    // Impression data
    self.adRequestModel.requestParameters[HyBidRequestParameter.clickbrowser] = @"1";
    self.adRequestModel.requestParameters[HyBidRequestParameter.topframe] = @"1";
    self.adRequestModel.requestParameters[HyBidRequestParameter.mimes] = @"text/html,text/javascript";
    self.adRequestModel.requestParameters[HyBidRequestParameter.videomimes] = @"video/mp4,video/webm";
    self.adRequestModel.requestParameters[HyBidRequestParameter.boxingallowed] = @"0"; // No boxing
    self.adRequestModel.requestParameters[HyBidRequestParameter.linearity] = @"1"; // Linear
    self.adRequestModel.requestParameters[HyBidRequestParameter.playbackend] = @"1"; // Video finish or user action
    self.adRequestModel.requestParameters[HyBidRequestParameter.mraidendcard] = @"true";
    self.adRequestModel.requestParameters[HyBidRequestParameter.clickType] = @"3"; // Native browser
    self.adRequestModel.requestParameters[HyBidRequestParameter.delivery] = @"3"; // Download
    NSArray* inputLanguages = [HyBidSettings sharedInstance].inputLanguages;
    if (inputLanguages && [inputLanguages count] > 0) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.inputLanguage] = [inputLanguages componentsJoinedByString:@","];
    }
    
    NSString* darkMode = [HyBidSettings sharedInstance].isDarkModeEnabled;
    if (darkMode) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.darkmode] = darkMode;
    }
    
    if (adSize) {
        if (adSize == HyBidAdSize.SIZE_INTERSTITIAL) {
            self.adRequestModel.requestParameters[HyBidRequestParameter.interstitial] = @"1";
            self.adRequestModel.requestParameters[HyBidRequestParameter.pos] = HyBidImpressionConstants.PLACEMENT_POSITION_FULLSCREEN;
            self.adRequestModel.requestParameters[HyBidRequestParameter.placement] = HyBidImpressionConstants.VIDEO_PLACEMENT_TYPE_INTERSTITIAL;
            self.adRequestModel.requestParameters[HyBidRequestParameter.placementSubtype] = HyBidImpressionConstants.VIDEO_PLACEMENT_SUBTYPE_INTERSTITIAL;
            self.adRequestModel.requestParameters[HyBidRequestParameter.playbackmethod] = [NSString stringWithFormat:@"%@,%@", HyBidImpressionConstants.VIDEO_PLAYBACK_METHOD_PAGE_LOAD_SOUND_ON, HyBidImpressionConstants.VIDEO_PLAYBACK_METHOD_PAGE_LOAD_SOUND_OFF];
        } else {
            self.adRequestModel.requestParameters[HyBidRequestParameter.interstitial] = @"0";
            self.adRequestModel.requestParameters[HyBidRequestParameter.pos] = HyBidImpressionConstants.PLACEMENT_POSITION_UNKNOWN;
            self.adRequestModel.requestParameters[HyBidRequestParameter.placement] = HyBidImpressionConstants.VIDEO_PLACEMENT_SUBTYPE_STANDALONE;
            self.adRequestModel.requestParameters[HyBidRequestParameter.expandDirection] = [NSString stringWithFormat:@"%@,%@", HyBidImpressionConstants.EXPANDABLE_DIRECTION_FULLSCREEN, HyBidImpressionConstants.EXPANDABLE_DIRECTION_RESIZE_MINIMIZE];
            self.adRequestModel.requestParameters[HyBidRequestParameter.playbackmethod] = [NSString stringWithFormat:@"%@,%@", HyBidImpressionConstants.VIDEO_PLAYBACK_METHOD_ENTER_VIEWPORT_SOUND_ON, HyBidImpressionConstants.VIDEO_PLAYBACK_METHOD_ENTER_VIEWPORT_SOUND_OFF];
        }
    }
    
    return self.adRequestModel;
}

- (void)setDisplayManager:(PNLiteAdRequestModel *)adRequestModel withIntegrationType:(IntegrationType)integrationType {
    adRequestModel.requestParameters[HyBidRequestParameter.displayManager] = [HyBidDisplayManager getDisplayManager];
    adRequestModel.requestParameters[HyBidRequestParameter.displayManagerVersion] =
    [HyBidDisplayManager getDisplayManagerVersionWithIntegrationType:integrationType andWithMediationVendor:self.mediationVendor];    
}

- (void)setIDFA:(PNLiteAdRequestModel *)adRequestModel {
    NSString *advertisingId = [HyBidSettings sharedInstance].advertisingId;
    if ([HyBidConsentConfig sharedConfig].coppa || !advertisingId || advertisingId.length == 0 || [[HyBidUserDataManager sharedInstance] isCCPAOptOut] || [[HyBidUserDataManager sharedInstance] isConsentDenied]) {
        adRequestModel.requestParameters[HyBidRequestParameter.dnt] = @"1";
    } else {
        adRequestModel.requestParameters[HyBidRequestParameter.idfa] = advertisingId;
        adRequestModel.requestParameters[HyBidRequestParameter.idfamd5] = [PNLiteCryptoUtils md5WithString:advertisingId];
        adRequestModel.requestParameters[HyBidRequestParameter.idfasha1] = [PNLiteCryptoUtils sha1WithString:advertisingId];
    }
}

- (void)setDefaultAssetFields:(PNLiteAdRequestModel *)adRequestModel {
    if (!adRequestModel.requestParameters[HyBidRequestParameter.assetsField]
        && !adRequestModel.requestParameters[HyBidRequestParameter.assetLayout]) {
        
        NSArray *assets = @[PNLiteAsset.title,
                            PNLiteAsset.body,
                            PNLiteAsset.icon,
                            PNLiteAsset.banner,
                            PNLiteAsset.callToAction,
                            PNLiteAsset.rating];
        
        adRequestModel.requestParameters[HyBidRequestParameter.assetsField] = [assets componentsJoinedByString:@","];
    }
}

- (void)setDefaultMetaFields:(PNLiteAdRequestModel *)adRequestModel {
    NSString *metaFieldsString = adRequestModel.requestParameters[HyBidRequestParameter.metaField];
    NSMutableArray *newMetaFields = [NSMutableArray array];
    if (metaFieldsString && metaFieldsString.length > 0) {
        newMetaFields = [[metaFieldsString componentsSeparatedByString:@","] mutableCopy];
    }
    if (![newMetaFields containsObject:PNLiteMeta.revenueModel]) {
        [newMetaFields addObject:PNLiteMeta.revenueModel];
    }
    if (![newMetaFields containsObject:PNLiteMeta.contentInfo]) {
        [newMetaFields addObject:PNLiteMeta.contentInfo];
    }
    if (![newMetaFields containsObject:PNLiteMeta.points]) {
        [newMetaFields addObject:PNLiteMeta.points];
    }
    if (![newMetaFields containsObject:PNLiteMeta.creativeId]) {
        [newMetaFields addObject:PNLiteMeta.creativeId];
    }
    adRequestModel.requestParameters[HyBidRequestParameter.metaField] = [newMetaFields componentsJoinedByString:@","];
}

- (void)setSupportedProtocols:(PNLiteAdRequestModel *)adRequestModel {
    NSArray *supportedProtocols = [NSArray arrayWithObjects:[HyBidProtocol protocolTypeToString:VAST_1_0],
                                   [HyBidProtocol protocolTypeToString:VAST_2_0],
                                   [HyBidProtocol protocolTypeToString:VAST_3_0],
                                   [HyBidProtocol protocolTypeToString:VAST_1_0_WRAPPER],
                                   [HyBidProtocol protocolTypeToString:VAST_2_0_WRAPPER],
                                   [HyBidProtocol protocolTypeToString:VAST_3_0_WRAPPER],
                                   [HyBidProtocol protocolTypeToString:VAST_4_0],
                                   [HyBidProtocol protocolTypeToString:VAST_4_0_WRAPPER],
                                   [HyBidProtocol protocolTypeToString:VAST_4_1],
                                   [HyBidProtocol protocolTypeToString:VAST_4_1_WRAPPER],
                                   [HyBidProtocol protocolTypeToString:VAST_4_2],
                                   [HyBidProtocol protocolTypeToString:VAST_4_2_WRAPPER],
                                   nil];
    adRequestModel.requestParameters[HyBidRequestParameter.protocol] = [supportedProtocols componentsJoinedByString:@","];
}

- (void)setSupportedAPIs:(PNLiteAdRequestModel *)adRequestModel {
    NSArray *supportedAPIs = [NSArray arrayWithObjects:[HyBidAPI apiTypeToString:MRAID_1],
                              [HyBidAPI apiTypeToString:MRAID_2],
                              [HyBidAPI apiTypeToString:MRAID_3],
                              [HyBidAPI apiTypeToString:OMID_1],
                              nil];
    adRequestModel.requestParameters[HyBidRequestParameter.api] = [supportedAPIs componentsJoinedByString:@","];
}

- (NSString *)formatUTCTime {
    NSTimeZone* localTimeZone = [NSTimeZone localTimeZone];
    NSDate* currentDate = [NSDate date];
    NSInteger totalOffsetSeconds = [localTimeZone secondsFromGMTForDate:currentDate];
    
    return [NSString stringWithFormat:@"%ld", (long)totalOffsetSeconds / 60];
}

@end
