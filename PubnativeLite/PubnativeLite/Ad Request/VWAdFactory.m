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

#import "VWAdFactory.h"
#import "HyBidSettings.h"
#import "HyBidLocationEncoding.h"
#import "VWAdLibrary.h"
#import "HyBidUserDataManager.h"

@implementation VWAdFactory

-(VWAdRequestModel *)createVWAdRequestWithZoneID:(NSString *)zoneID
                                      withAdSize:(HyBidAdSize *)adSize
                          withContentCategoryIDs:(NSMutableArray *)contentCategoryIDs
                              withPartnerKeyword:(NSString *)partnerKeyword {
    VWAdRequestModel *adRequestModel = [[VWAdRequestModel alloc] init];
    NSString *portalKeyword = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad" : @"iphn";
    adRequestModel.requestParameters[@"p"] = portalKeyword;
    adRequestModel.requestParameters[@"iframe"] = @"false";
    adRequestModel.requestParameters[@"b"] = partnerKeyword;
    adRequestModel.requestParameters[@"model"] = [HyBidSettings sharedInstance].deviceName;
    adRequestModel.requestParameters[@"appid"] = [HyBidSettings sharedInstance].appBundleID;
    
    [self setContentCategoryIDsForAdRequestModel:adRequestModel withContentCategoryIDs:contentCategoryIDs];
    [self setIDFA:adRequestModel];
    
    NSString* privacyString =  [[VWAdLibrary shared] getIABUSPrivacyString];
    if (![[VWAdLibrary shared] usPrivacyOptOut] && !([privacyString length] == 0)) {
        adRequestModel.requestParameters[@"usprivacy"] = privacyString;
    }
    
    if (![HyBidSettings sharedInstance].coppa && [[HyBidUserDataManager sharedInstance] canCollectData] && ![[VWAdLibrary shared] usPrivacyOptOut]) {
        adRequestModel.requestParameters[@"age"] = [[HyBidSettings sharedInstance].targeting.age stringValue];
        adRequestModel.requestParameters[@"gender"] = [HyBidSettings sharedInstance].targeting.gender;
        
        CLLocation* location = [HyBidSettings sharedInstance].location;
        if (location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) {
            NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
            NSString* longi = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        
            adRequestModel.requestParameters[@"lat"] = lat;
            adRequestModel.requestParameters[@"long"] = longi;
            adRequestModel.requestParameters[@"latlong"] = [NSString stringWithFormat:@"%@,%@", lat, longi];
            adRequestModel.requestParameters[@"ll"] =  [HyBidLocationEncoding encodeLocation: location];
        }
    }
    
    if (![adSize.layoutSize isEqualToString:@"native"]) {
        if (adSize.width != 0 && adSize.height != 0) {
            adRequestModel.requestParameters[@"size"] = [NSString stringWithFormat:@"%ldx%ld", (long)adSize.width, (long)adSize.height];
        } else {
            adRequestModel.requestParameters[@"size"] = @"320x416";
            [self setInterstitialParameterForAdRequestModel:adRequestModel];
        }
    }
    
    return adRequestModel;
}

- (VWAdRequestModel *)createVWVideoAdRequestWithZoneID:(NSString *)zoneID
                                            withAdSize:(HyBidAdSize *)adSize
                                withContentCategoryIDs:(NSMutableArray *)contentCategoryIDs
                                    withPartnerKeyword:(NSString *)partnerKeyword {
    VWAdRequestModel *adRequestModel = [[VWAdRequestModel alloc] init];
    NSString *portalKeyword = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad" : @"iphn";
    adRequestModel.requestParameters[@"p"] = portalKeyword;
    adRequestModel.requestParameters[@"b"] = partnerKeyword;
    adRequestModel.requestParameters[@"appid"] = [HyBidSettings sharedInstance].appBundleID;
    adRequestModel.requestParameters[@"cc"] = @"vast2.0";
    adRequestModel.requestParameters[@"adunit"] = @"vastlinear";
    adRequestModel.requestParameters[@"videoPlacement"] = @"floating";
    adRequestModel.requestParameters[@"deliveryType"] = @"progressive";
    adRequestModel.requestParameters[@"skip"] = @"false";
    adRequestModel.requestParameters[@"autoPlay"] = @"true";
    adRequestModel.requestParameters[@"audioOnStart"] = @"false";
    
    [self setContentCategoryIDsForAdRequestModel:adRequestModel withContentCategoryIDs:contentCategoryIDs];
    [self setIDFA:adRequestModel];
    
    NSString* privacyString =  [[VWAdLibrary shared] getIABUSPrivacyString];
    if (![[VWAdLibrary shared] usPrivacyOptOut] && !([privacyString length] == 0)) {
        adRequestModel.requestParameters[@"usprivacy"] = privacyString;
    }
    
    if (![HyBidSettings sharedInstance].coppa && [[HyBidUserDataManager sharedInstance] canCollectData] && ![[VWAdLibrary shared] usPrivacyOptOut]) {
        adRequestModel.requestParameters[@"age"] = [[HyBidSettings sharedInstance].targeting.age stringValue];
        adRequestModel.requestParameters[@"gender"] = [HyBidSettings sharedInstance].targeting.gender;
        
        CLLocation* location = [HyBidSettings sharedInstance].location;
        if (location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) {
            NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
            NSString* longi = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        
            adRequestModel.requestParameters[@"lat"] = lat;
            adRequestModel.requestParameters[@"long"] = longi;
            adRequestModel.requestParameters[@"latlong"] = [NSString stringWithFormat:@"%@,%@", lat, longi];
            adRequestModel.requestParameters[@"ll"] =  [HyBidLocationEncoding encodeLocation: location];
        }
    }
    
    if (![adSize.layoutSize isEqualToString:@"native"]) {
        if (adSize.width != 0 && adSize.height != 0) {
            adRequestModel.requestParameters[@"vpw"] = [NSString stringWithFormat:@"%ld", (long)adSize.width];
            adRequestModel.requestParameters[@"vph"] = [NSString stringWithFormat:@"%ld", (long)adSize.height];
        } else {
            adRequestModel.requestParameters[@"vpw"] = [NSString stringWithFormat:@"%ld", (long)[[UIScreen mainScreen] bounds].size.width];
            adRequestModel.requestParameters[@"vph"] = [NSString stringWithFormat:@"%ld", (long)[[UIScreen mainScreen] bounds].size.height];
        }
    }
    
    return adRequestModel;
}

- (void)setInterstitialParameterForAdRequestModel:(VWAdRequestModel *)adRequestModel {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adRequestModel.requestParameters[@"adunit"] = @"tinter";
    } else {
        adRequestModel.requestParameters[@"adunit"] = @"inter";
    }
}

- (void)setIDFA:(VWAdRequestModel *)adRequestModel {
    NSString *advertisingId = [HyBidSettings sharedInstance].advertisingId;
    if (!advertisingId || advertisingId.length == 0) {
        
    } else {
        adRequestModel.requestParameters[@"ui"] = advertisingId;
        adRequestModel.requestParameters[@"uis"] = @"a";
    }
}

- (void)setContentCategoryIDsForAdRequestModel:(VWAdRequestModel *)adRequestModel withContentCategoryIDs:(NSMutableArray *)contentCategoryIDs {
    NSMutableString *contentCategoryIDsString = [NSMutableString new];
    if (contentCategoryIDs.count) {
      [contentCategoryIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger catID = [obj integerValue] ?: 97;
        if (idx == 0) {
          [contentCategoryIDsString appendFormat:@"%ld", (long)catID];
        } else {
          [contentCategoryIDsString appendFormat:@"%%2C%ld", (long)catID];
        }
      }];
    } else { /* Default to "News and Information". */
      [contentCategoryIDsString appendString:@"97"];
    }
    adRequestModel.requestParameters[@"c"] = contentCategoryIDsString;
}

@end
