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
#import "HyBidRemoteConfigManager.h"
#import "HyBidDisplayManager.h"
#import "HyBidAPI.h"
#import "HyBidProtocol.h"
#import "HyBidRemoteConfigFeature.h"
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
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceModel] = [HyBidSettings sharedInstance].deviceName;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceWidth] = [HyBidSettings sharedInstance].deviceWidth;
    self.adRequestModel.requestParameters[HyBidRequestParameter.deviceHeight] = [HyBidSettings sharedInstance].deviceHeight;
    self.adRequestModel.requestParameters[HyBidRequestParameter.orientation] = [HyBidSettings sharedInstance].orientation;
    self.adRequestModel.requestParameters[HyBidRequestParameter.coppa] = [HyBidConsentConfig sharedConfig].coppa ? @"1" : @"0";
    [self setIDFA:self.adRequestModel];
    self.adRequestModel.requestParameters[HyBidRequestParameter.locale] = [HyBidSettings sharedInstance].locale;
    
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
    if (!([privacyString length] == 0) && [HyBidRemoteConfigManager.sharedInstance.featureResolver isUserConsentSupported:[HyBidRemoteConfigFeature hyBidRemoteUserConsentToString:HyBidRemoteUserConsent_CCPA]]) {
        self.adRequestModel.requestParameters[HyBidRequestParameter.usprivacy] = privacyString;
    }
    
    NSString* consentString = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
    if (!([consentString length] == 0) && [HyBidRemoteConfigManager.sharedInstance.featureResolver isUserConsentSupported:[HyBidRemoteConfigFeature hyBidRemoteUserConsentToString:HyBidRemoteUserConsent_GDPR]]) {
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
                
                self.adRequestModel.requestParameters[HyBidRequestParameter.lat] = lat;
                self.adRequestModel.requestParameters[HyBidRequestParameter.lon] = lon;
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
    
    #if __has_include(<ATOM/ATOM-Swift.h>)
    NSArray *cohortsArray = [Atom getCohorts];
    NSString *cohortsString = [cohortsArray componentsJoinedByString:@","];
    cohortsString = [[NSString alloc] initWithFormat:@"[%@]", cohortsString];
    
    NSString *encryptedString = [[cohortsString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *lastChar = [encryptedString substringFromIndex:[encryptedString length] - 1];
    
    if ([lastChar isEqualToString:@"="]) {
        encryptedString = [encryptedString substringToIndex:[encryptedString length] - 1];
    }
    
    self.adRequestModel.requestParameters[HyBidRequestParameter.vg] = encryptedString;
    #endif
    
    [self setDefaultMetaFields:self.adRequestModel];
    [self setDisplayManager:self.adRequestModel withIntegrationType:integrationType];
    [self setSupportedAPIs:self.adRequestModel];
    [self setSupportedProtocols:self.adRequestModel];
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
    NSMutableArray *configProtocols = [NSMutableArray array];
    if (HyBidRemoteConfigManager.sharedInstance.remoteConfigModel.appConfig.enabledProtocols && [HyBidRemoteConfigManager.sharedInstance.remoteConfigModel.appConfig.enabledProtocols count] > 0) {
        for (NSString *protocol in HyBidRemoteConfigManager.sharedInstance.remoteConfigModel.appConfig.enabledProtocols) {
            if ([supportedProtocols containsObject:protocol]) {
                [configProtocols addObject:protocol];
            }
        }
        adRequestModel.requestParameters[HyBidRequestParameter.protocol] = [configProtocols componentsJoinedByString:@","];
    } else {
        adRequestModel.requestParameters[HyBidRequestParameter.protocol] = [supportedProtocols componentsJoinedByString:@","];
    }
}

- (void)setSupportedAPIs:(PNLiteAdRequestModel *)adRequestModel {
    NSArray *supportedAPIs = [NSArray arrayWithObjects:[HyBidAPI apiTypeToString:MRAID_1],
                              [HyBidAPI apiTypeToString:MRAID_2],
                              [HyBidAPI apiTypeToString:MRAID_3],
                              [HyBidAPI apiTypeToString:OMID_1],
                              nil];
    NSMutableArray *configAPIs = [NSMutableArray array];
    if (HyBidRemoteConfigManager.sharedInstance.remoteConfigModel.appConfig.enabledAPIs && [HyBidRemoteConfigManager.sharedInstance.remoteConfigModel.appConfig.enabledAPIs count] > 0) {
        for (NSString *api in HyBidRemoteConfigManager.sharedInstance.remoteConfigModel.appConfig.enabledAPIs) {
            if ([supportedAPIs containsObject:api]) {
                [configAPIs addObject:api];
            }
        }
        adRequestModel.requestParameters[HyBidRequestParameter.api] = [configAPIs componentsJoinedByString:@","];
    } else {
        adRequestModel.requestParameters[HyBidRequestParameter.api] = [supportedAPIs componentsJoinedByString:@","];
    }
}

@end
