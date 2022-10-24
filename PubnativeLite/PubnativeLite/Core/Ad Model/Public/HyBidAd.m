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

#import "HyBidAd.h"
#import "PNLiteMeta.h"
#import "PNLiteAsset.h"
#import "HyBidContentInfoView.h"
#import "HyBidSkAdNetworkModel.h"
#import "HyBidOpenRTBAdModel.h"
#import "HyBid.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

NSString *const kImpressionURL = @"got.pubnative.net";
NSString *const kImpressionQuerryParameter = @"t";

NSString *const ContentInfoViewText = @"Learn about this ad";
NSString *const ContentInfoViewLink = @"https://pubnative.net/content-info";
NSString *const ContentInfoViewIcon = @"https://cdn.pubnative.net/static/adserver/contentinfo.png";

@interface HyBidAd ()

@property (nonatomic, strong)HyBidAdModel *data;
@property (nonatomic, strong)HyBidOpenRTBAdModel *openRTBData;
@property (nonatomic, strong)HyBidContentInfoView *contentInfoView;
@property (nonatomic, strong)NSString *_zoneID;

@end

@implementation HyBidAd

- (void)dealloc {
    self.data = nil;
    self.contentInfoView = nil;
    self._zoneID = nil;
}

#pragma mark HyBidAd

- (instancetype)initWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID {
    self = [super init];
    if (self) {
        self.data = data;
        self._zoneID = zoneID;
    }
    return self;
}

- (instancetype)initOpenRTBWithData:(HyBidOpenRTBAdModel *)data withZoneID:(NSString *)zoneID {
    self = [super init];
    if (self) {
        self.openRTBData = data;
        self._zoneID = zoneID;
    }
    return self;
}

- (instancetype)initWithAssetGroupForOpenRTB:(NSInteger)assetGroup withAdContent:(NSString *)adContent withAdType:(NSInteger)adType withBidObject:(NSDictionary *)bidObject {
    self = [super init];
    if (self) {
        HyBidOpenRTBAdModel *model = [[HyBidOpenRTBAdModel alloc] initWithDictionary:bidObject];
        NSString *apiAsset;
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        HyBidOpenRTBDataModel *data;
        if (adType == kHyBidAdTypeVideo) {
            apiAsset = PNLiteAsset.vast;
            data = [[HyBidOpenRTBDataModel alloc] initWithVASTAsset:apiAsset withValue:adContent];
            self.adType = kHyBidAdTypeVideo;
        } else {
            apiAsset = PNLiteAsset.htmlBanner;
            data = [[HyBidOpenRTBDataModel alloc] initWithHTMLAsset:apiAsset withValue:adContent];
            self.adType = kHyBidAdTypeHTML;
        }
        [assets addObject:data];
        
        model.assets = assets;
        model.assetgroupid = [NSNumber numberWithInteger: assetGroup];
        self.openRTBData = model;
    }
    return self;
}

- (instancetype)initWithAssetGroup:(NSInteger)assetGroup withAdContent:(NSString *)adContent withAdType:(NSInteger)adType {
    self = [super init];
    if (self) {
        HyBidAdModel *model = [[HyBidAdModel alloc] init];
        NSString *apiAsset;
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        HyBidDataModel *data;
        if (adType == kHyBidAdTypeVideo) {
            apiAsset = PNLiteAsset.vast;
            data = [[HyBidDataModel alloc] initWithVASTAsset:apiAsset withValue:adContent];
            self.adType = kHyBidAdTypeVideo;
        } else {
            apiAsset = PNLiteAsset.htmlBanner;
            data = [[HyBidDataModel alloc] initWithHTMLAsset:apiAsset withValue:adContent];
            self.adType = kHyBidAdTypeHTML;
        }
        [assets addObject:data];
        
        model.assets = assets;
        model.assetgroupid = [NSNumber numberWithInteger: assetGroup];
        self.data = model;
    }
    return self;
}

- (NSString *)zoneID {
    return self._zoneID;
}

- (NSString *)vast {
    NSString *result = nil;
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.vast];
    if (data) {
        result = data.vast;
    }
    return result;
}

- (NSString *)openRtbVast {
    NSString *result = nil;
    HyBidOpenRTBDataModel *data = [self openRTBAssetDataWithType:PNLiteAsset.vast];
    if (data) {
        result = data.vast;
    }
    return result;
}

- (NSString *)htmlUrl {
    NSString *result = nil;
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
    if (data) {
        result = data.url;
    }
    
    return result;
}

- (NSString *)htmlData {
    NSString *result = nil;
    if (self.openRTBData != nil) {
        HyBidOpenRTBDataModel *data = [self openRTBAssetDataWithType:PNLiteAsset.htmlBanner];
        if (data) {
            result = data.html;
        }
    } else {
        HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
        if (data) {
            result = data.html;
        }
    }
    return result;
}

- (NSString *)link {
    NSString *result = nil;
    if (self.openRTBData != nil) {
        result = self.openRTBData.link;
    } else {
        if (self.data) {
            result = self.data.link;
        }
    }
    return result;
}

- (NSString *)impressionID {
    NSArray *impressionBeacons = [self beaconsDataWithType:@"impression"];
    BOOL found = NO;
    NSString *impressionID = @"";
    NSInteger index = 0;
    while (index < impressionBeacons.count && !found) {
        HyBidDataModel *impressionBeacon = [impressionBeacons objectAtIndex:index];
        if (impressionBeacon.url != nil && impressionBeacon.url.length != 0) {
            NSURLComponents *components = [[NSURLComponents alloc] initWithString:impressionBeacon.url];
            if ([components.host isEqualToString:kImpressionURL]) {
                NSString *idParameter = [self valueForKey:kImpressionQuerryParameter fromQueryItems:components.queryItems];
                if (idParameter != nil && idParameter.length != 0) {
                    impressionID = idParameter;
                    found = YES;
                }
            }
        }
        index ++;
    }
    return impressionID;
}

- (NSString *)creativeID {
    NSString *creativeID = @"";
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.creativeId];
    if(data) {
        creativeID = data.text;
    }
    return creativeID;
}

- (NSNumber *)assetGroupID {
    NSNumber *result = nil;
    if (self.data) {
        result = self.data.assetgroupid;
    }
    return result;
}

- (NSNumber *)openRTBAssetGroupID {
    NSNumber *result = nil;
    if (self.openRTBData) {
        result = self.openRTBData.assetgroupid;
    }
    return result;
}

- (NSNumber *)eCPM {
    NSNumber *result = nil;
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.points];
    if (data) {
        result = data.eCPM;
    }
    return result;
}

- (NSNumber *)width {
    NSNumber *result = nil;
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
    if (data) {
        result = data.width;
    }
    return result;
}

- (NSNumber *)height {
    NSNumber *result = nil;
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
    if (data) {
        result = data.height;
    }
    return result;
}

- (NSArray<HyBidDataModel *> *)beacons {
    if (self.data) {
        return self.data.beacons;
    } else {
        return nil;
    }
}

- (HyBidContentInfoView *)contentInfo {
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.contentInfo];
    if (data) {
        if (!self.contentInfoView) {
            self.contentInfoView = [[HyBidContentInfoView alloc] init];
            self.contentInfoView.text = data.text;
            self.contentInfoView.link = [data stringFieldWithKey:@"link"];
            self.contentInfoView.icon = [data stringFieldWithKey:@"icon"];
            self.contentInfoView.zoneID = self.zoneID;
        }
    } else {
        if (!self.contentInfoView) {
            self.contentInfoView = [self getDefaultContentInfo];
        }
    }
    return self.contentInfoView;
}

- (HyBidContentInfoView *)getContentInfoView
{
    return [self getContentInfoViewFrom:nil];
}

- (HyBidContentInfoView *)getContentInfoViewFrom:(HyBidContentInfoView *)infoView
{
    HyBidContentInfoView *contentInfoView = [self getCustomContentInfoFrom:infoView];

    if (contentInfoView == nil) {
        contentInfoView = [self contentInfo];
    }
    
    return contentInfoView;
}

- (HyBidContentInfoView *)getCustomContentInfoFrom:(HyBidContentInfoView *)contentInfoView
{
    if (contentInfoView == nil || [contentInfoView.icon length] == 0) {
        return nil;
    } else {
        HyBidContentInfoView *result = [[HyBidContentInfoView alloc] init];
        result.icon = contentInfoView.icon;
        result.link = contentInfoView.link;
        result.text = [contentInfoView.text length] == 0 ? contentInfoView.text : ContentInfoViewText;
        result.zoneID = self.zoneID;
        return result;
    }
}

- (HyBidContentInfoView *)getDefaultContentInfo
{
    HyBidContentInfoView *contentInfoView = [[HyBidContentInfoView alloc] init];
    contentInfoView.text = ContentInfoViewText;
    contentInfoView.link = ContentInfoViewLink;
    contentInfoView.icon = ContentInfoViewIcon;
    contentInfoView.zoneID = self.zoneID;
    return contentInfoView;
}

- (HyBidSkAdNetworkModel *)getOpenRTBSkAdNetworkModel {
    HyBidOpenRTBDataModel *data = [self extensionDataWithType:PNLiteMeta.skadnetwork];
    HyBidSkAdNetworkModel *model = [[HyBidSkAdNetworkModel alloc] init];
    
    if (data) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        if ([data stringFieldWithKey:@"campaign"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"campaign"] forKey:@"campaign"];
        }
        if ([data stringFieldWithKey:@"itunesitem"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"itunesitem"] forKey:@"itunesitem"];
        }
        if ([data stringFieldWithKey:@"network"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"network"] forKey:@"network"];
        }
        if ([data stringFieldWithKey:@"sourceapp"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"sourceapp"] forKey:@"sourceapp"];
        }
        if ([data stringFieldWithKey:@"version"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"version"] forKey:@"version"];
        }
        
        double skanVersion = [[data dictionary][@"skadn"][@"version"] doubleValue];
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [data.dictionary[@"skadn"][@"fidelities"] count] > 0) {
            SKANObject skan;
            NSArray *fidelities = data.dictionary[@"skadn"][@"fidelities"];
            NSMutableArray<NSData *> *skanDataArray = [NSMutableArray new];
            
            for (NSDictionary *fidelity in fidelities) {
                if (fidelity[@"nonce"] != nil &&
                    fidelity[@"signature"] != nil &&
                    fidelity[@"timestamp"] != nil &&
                    fidelity[@"fidelity"] != nil) {
                    skan.nonce = (char *)[fidelity[@"nonce"] UTF8String];
                    skan.signature = (char *)[fidelity[@"signature"] UTF8String];
                    skan.timestamp = (char *)[fidelity[@"timestamp"] UTF8String];
                    skan.fidelity = [fidelity[@"fidelity"] intValue];
                    
                    NSData *d = [NSData dataWithBytes:&skan length:sizeof(SKANObject)];
                    [skanDataArray addObject:d];
                }
            }
            
            [dict setObject:skanDataArray forKey:@"fidelities"];
        } else {
            if ([data stringFieldWithKey:@"signature"] != nil) {
                [dict setValue:[data stringFieldWithKey:@"signature"] forKey:@"signature"];
            }
            if ([data stringFieldWithKey:@"timestamp"] != nil) {
                [dict setValue:[data stringFieldWithKey:@"timestamp"] forKey:@"timestamp"];
            }
            if ([data stringFieldWithKey:@"nonce"] != nil) {
                [dict setValue:[data stringFieldWithKey:@"nonce"] forKey:@"nonce"];
            }
            if ([data numberFieldWithKey:@"fidelity-type"] != nil) {
                [dict setValue:[data numberFieldWithKey:@"fidelity-type"] forKey:@"fidelity-type"];
            }
        }
        
        model.productParameters = [dict copy];
    }

    return model;
}

- (HyBidSkAdNetworkModel *)getSkAdNetworkModel {
    HyBidSkAdNetworkModel *model = [[HyBidSkAdNetworkModel alloc] init];
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.skadnetwork];
    
    if (data) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        if ([data stringFieldWithKey:@"campaign"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"campaign"] forKey:@"campaign"];
        }
        if ([data stringFieldWithKey:@"itunesitem"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"itunesitem"] forKey:@"itunesitem"];
        }
        if ([data stringFieldWithKey:@"network"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"network"] forKey:@"network"];
        }
        if ([data stringFieldWithKey:@"sourceapp"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"sourceapp"] forKey:@"sourceapp"];
        }
        if ([data stringFieldWithKey:@"version"] != nil) {
            [dict setValue:[data stringFieldWithKey:@"version"] forKey:@"version"];
        }
        
        double skanVersion = [[data dictionary][@"data"][@"version"] doubleValue];
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [data.dictionary[@"data"][@"fidelities"] count] > 0) {
            SKANObject skan;
            NSArray *fidelities = data.dictionary[@"data"][@"fidelities"];
            NSMutableArray<NSData *> *skanDataArray = [NSMutableArray new];
            
            for (NSDictionary *fidelity in fidelities) {
                if (fidelity[@"nonce"] != nil &&
                    fidelity[@"signature"] != nil &&
                    fidelity[@"timestamp"] != nil &&
                    fidelity[@"fidelity"] != nil) {
                    skan.nonce = (char *)[fidelity[@"nonce"] UTF8String];
                    skan.signature = (char *)[fidelity[@"signature"] UTF8String];
                    skan.timestamp = (char *)[fidelity[@"timestamp"] UTF8String];
                    skan.fidelity = [fidelity[@"fidelity"] intValue];
                    
                    NSData *d = [NSData dataWithBytes:&skan length:sizeof(SKANObject)];
                    [skanDataArray addObject:d];
                }
            }
            
            [dict setObject:skanDataArray forKey:@"fidelities"];
        } else {
            if ([data stringFieldWithKey:@"nonce"] != nil) {
                [dict setValue:[data stringFieldWithKey:@"nonce"] forKey:@"nonce"];
            }
            if ([data stringFieldWithKey:@"signature"] != nil) {
                [dict setValue:[data stringFieldWithKey:@"signature"] forKey:@"signature"];
            }
            if ([data stringFieldWithKey:@"timestamp"] != nil) {
                [dict setValue:[data stringFieldWithKey:@"timestamp"] forKey:@"timestamp"];
            }
            if ([data numberFieldWithKey:@"fidelity-type"] != nil) {
                [dict setValue:[data numberFieldWithKey:@"fidelity-type"] forKey:@"fidelity-type"];
            }
        }
        
        model.productParameters = [dict copy];
    }
    
    return model;
}

- (HyBidDataModel *)assetDataWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    if (self.data) {
        result = [self.data assetWithType:type];
    }
    return result;
}

- (HyBidOpenRTBDataModel *)openRTBAssetDataWithType:(NSString *)type {
    HyBidOpenRTBDataModel *result = nil;
    
    if (self.openRTBData) {
        result = [self.openRTBData assetWithType:type];
    }
    return result;
}

- (HyBidDataModel *)metaDataWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    if (self.data) {
        result = [self.data metaWithType:type];
    }
    return result;
}

- (HyBidOpenRTBDataModel *)extensionDataWithType:(NSString *)type {
    HyBidOpenRTBDataModel *result = nil;
    if (self.openRTBData) {
        result = [self.openRTBData extensionWithType:type];
    }
    return result;
}

- (NSArray *)beaconsDataWithType:(NSString *)type {
    NSArray *result = nil;
    if (self.data) {
        result = [self.data beaconsWithType:type];
    }
    return result;
}

- (NSString *)valueForKey:(NSString *)key fromQueryItems:(NSArray *)queryItems {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

- (NSComparisonResult)compare:(HyBidAd*)other
{
    return [self.eCPM compare:other.eCPM];
}
@end
