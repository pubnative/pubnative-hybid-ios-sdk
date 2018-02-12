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
#import "PNLiteRequestParameter.h"
#import "PNLiteSettings.h"
#import "PNLiteCryptoUtils.h"
#import "PNLiteMeta.h"

@implementation PNLiteAdFactory

- (PNLiteAdRequestModel *)createAdRequestWithZoneID:(NSString *)zoneID andWithAdSize:(NSString *)adSize
{
    PNLiteAdRequestModel *adRequestModel = [[PNLiteAdRequestModel alloc] init];
    adRequestModel.requestParameters[PNLiteRequestParameter.zoneId] = zoneID;
    adRequestModel.requestParameters[PNLiteRequestParameter.appToken] = [PNLiteSettings sharedInstance].appToken;
    adRequestModel.requestParameters[PNLiteRequestParameter.os] = [PNLiteSettings sharedInstance].os;
    adRequestModel.requestParameters[PNLiteRequestParameter.osVersion] = [PNLiteSettings sharedInstance].osVersion;
    adRequestModel.requestParameters[PNLiteRequestParameter.deviceModel] = [PNLiteSettings sharedInstance].deviceName;
    adRequestModel.requestParameters[PNLiteRequestParameter.coppa] =[PNLiteSettings sharedInstance].coppa ? @"1" : @"0";
    [self setIDFA:adRequestModel];
    adRequestModel.requestParameters[PNLiteRequestParameter.locale] = [PNLiteSettings sharedInstance].locale;
    adRequestModel.requestParameters[PNLiteRequestParameter.age] = [[PNLiteSettings sharedInstance].targeting.age stringValue];
    adRequestModel.requestParameters[PNLiteRequestParameter.age] = [PNLiteSettings sharedInstance].targeting.gender;
    adRequestModel.requestParameters[PNLiteRequestParameter.keywords] = [[PNLiteSettings sharedInstance].targeting.interests componentsJoinedByString:@","];
    adRequestModel.requestParameters[PNLiteRequestParameter.bundleId] = [PNLiteSettings sharedInstance].appBundleID;
    adRequestModel.requestParameters[PNLiteRequestParameter.test] =[PNLiteSettings sharedInstance].test ? @"1" : @"0";
    adRequestModel.requestParameters[PNLiteRequestParameter.assetLayout] = adSize;
    [self setDefaultMetaFields:adRequestModel];
    return adRequestModel;
}

- (void)setIDFA:(PNLiteAdRequestModel *)adRequestModel
{
    NSString *advertisingId = [PNLiteSettings sharedInstance].advertisingId;
    if (advertisingId == nil || advertisingId.length == 0) {
        adRequestModel.requestParameters[PNLiteRequestParameter.dnt] = @"1";
    } else {
        adRequestModel.requestParameters[PNLiteRequestParameter.idfa] = advertisingId;
        adRequestModel.requestParameters[PNLiteRequestParameter.idfamd5] = [PNLiteCryptoUtils md5WithString:advertisingId];
        adRequestModel.requestParameters[PNLiteRequestParameter.idfasha1] = [PNLiteCryptoUtils sha1WithString:advertisingId];
    }
}

- (void)setDefaultMetaFields:(PNLiteAdRequestModel *)adRequestModel
{
    NSString *metaFieldsString = adRequestModel.requestParameters[PNLiteRequestParameter.metaField];
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
    adRequestModel.requestParameters[PNLiteRequestParameter.metaField] = [newMetaFields componentsJoinedByString:@","];
}

@end
