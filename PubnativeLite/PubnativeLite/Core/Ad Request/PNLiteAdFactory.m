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
#import "HyBidSettings.h"
#import "PNLiteCryptoUtils.h"
#import "PNLiteMeta.h"
#import "PNLiteAsset.h"
#import "HyBidConstants.h"
#import "HyBidUserDataManager.h"
#import "HyBidSkAdNetworkRequestModel.h"
#import "HyBidRemoteConfigManager.h"
#import "HyBidLogger.h"

@implementation PNLiteAdFactory

- (PNLiteAdRequestModel *)createAdRequestWithZoneID:(NSString *)zoneID
                                         withAdSize:(HyBidAdSize *)adSize
                         withSupportedAPIFrameworks:(NSArray<NSString *> *)supportedAPIFrameworks
                                withIntegrationType:(IntegrationType)integrationType
                                         isRewarded:(BOOL)isRewarded {
    PNLiteAdRequestModel *adRequestModel = [[PNLiteAdRequestModel alloc] init];
    adRequestModel.requestParameters[HyBidRequestParameter.zoneId] = zoneID;
    adRequestModel.requestParameters[HyBidRequestParameter.appToken] = [HyBidSettings sharedInstance].appToken;
    adRequestModel.requestParameters[HyBidRequestParameter.os] = [HyBidSettings sharedInstance].os;
    adRequestModel.requestParameters[HyBidRequestParameter.osVersion] = [HyBidSettings sharedInstance].osVersion;
    adRequestModel.requestParameters[HyBidRequestParameter.deviceModel] = [HyBidSettings sharedInstance].deviceName;
    adRequestModel.requestParameters[HyBidRequestParameter.deviceWidth] = [HyBidSettings sharedInstance].deviceWidth;
    adRequestModel.requestParameters[HyBidRequestParameter.deviceHeight] = [HyBidSettings sharedInstance].deviceHeight;
    adRequestModel.requestParameters[HyBidRequestParameter.orientation] = [HyBidSettings sharedInstance].orientation;
    adRequestModel.requestParameters[HyBidRequestParameter.deviceSound] = [HyBidSettings sharedInstance].deviceSound;
    adRequestModel.requestParameters[HyBidRequestParameter.coppa] = [HyBidSettings sharedInstance].coppa ? @"1" : @"0";
    [self setIDFA:adRequestModel];
    adRequestModel.requestParameters[HyBidRequestParameter.locale] = [HyBidSettings sharedInstance].locale;
    
    BOOL isUsingOpenRTB = [[NSUserDefaults standardUserDefaults] boolForKey:kIsUsingOpenRTB];
    if (isUsingOpenRTB) {
        adRequestModel.requestParameters[HyBidRequestParameter.ip] = [HyBidSettings sharedInstance].ip;
    }
    
    adRequestModel.requestParameters[HyBidRequestParameter.versionOfOMSDKIntegration] = HYBID_OMSDK_VERSION;
    adRequestModel.requestParameters[HyBidRequestParameter.identifierOfOMSDKIntegration] = HYBID_OMSDK_IDENTIFIER;
//    adRequestModel.requestParameters[HyBidRequestParameter.supportedAPIFrameworks] = [supportedAPIFrameworks componentsJoinedByString:@","];
    adRequestModel.requestParameters[HyBidRequestParameter.identifierForVendor] = [HyBidSettings sharedInstance].identifierForVendor;
    
    if (@available(iOS 11.3, *)) {
        HyBidSkAdNetworkRequestModel *skAdNetworkRequestModel = [[HyBidSkAdNetworkRequestModel alloc] init];
        
        if ([skAdNetworkRequestModel getAppID] != NULL) {
            if ([[skAdNetworkRequestModel getAppID] length] > 0) {
                NSString *adIDs = [skAdNetworkRequestModel getSkAdNetworkAdNetworkIDsString];
                if ([adIDs length] > 0) {
                    [self setAppStoreAppID:adRequestModel withAppID:[skAdNetworkRequestModel getAppID]];
                    adRequestModel.requestParameters[HyBidRequestParameter.skAdNetworkAdNetworkIDs] = adIDs;
                    adRequestModel.requestParameters[HyBidRequestParameter.skAdNetworkVersion] = [skAdNetworkRequestModel getSkAdNetworkVersion];
                } else {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"No SKAdNetworkIdentifier items were found in `info.plist` file. Please add the required items and try again."];
                }
            } else {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid AppID parameter cannot be empty. Please assign the actual AppStore app ID to this parameter and try again."];
            }
        }
    }
    
    NSString* privacyString = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
    if (!([privacyString length] == 0)) {
        adRequestModel.requestParameters[HyBidRequestParameter.usprivacy] = privacyString;
    }
    
    NSString* consentString = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
    if (!([consentString length] == 0)) {
        adRequestModel.requestParameters[HyBidRequestParameter.userconsent] = consentString;
    }
    
    if (![HyBidSettings sharedInstance].coppa && ![[HyBidUserDataManager sharedInstance] isCCPAOptOut] && ![[HyBidUserDataManager sharedInstance] isConsentDenied]) {
        adRequestModel.requestParameters[HyBidRequestParameter.age] = [[HyBidSettings sharedInstance].targeting.age stringValue];
        adRequestModel.requestParameters[HyBidRequestParameter.gender] = [HyBidSettings sharedInstance].targeting.gender;
        adRequestModel.requestParameters[HyBidRequestParameter.keywords] = [[HyBidSettings sharedInstance].targeting.interests componentsJoinedByString:@","];
        
        if ([HyBidSettings sharedInstance].locationTrackingEnabled) {
            CLLocation* location = [HyBidSettings sharedInstance].location;
            
            if (location && location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) {
                NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
                NSString* lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
                
                adRequestModel.requestParameters[HyBidRequestParameter.lat] = lat;
                adRequestModel.requestParameters[HyBidRequestParameter.lon] = lon;
            }
        }
    }
    
    adRequestModel.requestParameters[HyBidRequestParameter.rewardedVideo] = isRewarded ? @"1" : @"0";
    
    adRequestModel.requestParameters[HyBidRequestParameter.test] = [HyBidSettings sharedInstance].test ? @"1" : @"0";
    if (![adSize.layoutSize isEqualToString:@"native"]) {
        adRequestModel.requestParameters[HyBidRequestParameter.assetLayout] = adSize.layoutSize;
        
        if (adSize.width != 0) {
            adRequestModel.requestParameters[HyBidRequestParameter.width] = [@(adSize.width) stringValue];
        }
        if (adSize.height != 0) {
            adRequestModel.requestParameters[HyBidRequestParameter.height] = [@(adSize.height) stringValue];
        }
    } else {
        [self setDefaultAssetFields:adRequestModel];
    }
    [self setDefaultMetaFields:adRequestModel];
    [self setDisplayManager:adRequestModel withIntegrationType:integrationType];
    return adRequestModel;
}

- (void)setDisplayManager:(PNLiteAdRequestModel *)adRequestModel withIntegrationType:(IntegrationType)integrationType {
    adRequestModel.requestParameters[HyBidRequestParameter.displayManager] = HYBID_SDK_NAME;
    adRequestModel.requestParameters[HyBidRequestParameter.displayManagerVersion] = [NSString stringWithFormat:@"%@_%@_%@", @"sdkios", [HyBidIntegrationType getIntegrationTypeCodeFromIntegrationType:integrationType] ,HYBID_SDK_VERSION];
}

- (void)setIDFA:(PNLiteAdRequestModel *)adRequestModel {
    NSString *advertisingId = [HyBidSettings sharedInstance].advertisingId;
    if ([HyBidSettings sharedInstance].coppa || !advertisingId || advertisingId.length == 0 || [[HyBidUserDataManager sharedInstance] isCCPAOptOut] || [[HyBidUserDataManager sharedInstance] isConsentDenied]) {
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

-(void)setAppStoreAppID:(PNLiteAdRequestModel *)adRequestModel withAppID:(NSString *)appID {
    adRequestModel.requestParameters[HyBidRequestParameter.skAdNetworkAppID] = appID;
}

@end
