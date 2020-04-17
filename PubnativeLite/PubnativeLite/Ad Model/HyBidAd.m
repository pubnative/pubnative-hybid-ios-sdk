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
#import "PNLiteAssetGroupType.h"

NSString *const kImpressionURL = @"got.pubnative.net";
NSString *const kImpressionQuerryParameter = @"t";

@interface HyBidAd ()

@property (nonatomic, strong)HyBidAdModel *data;
@property (nonatomic, strong)HyBidContentInfoView *contentInfoView;
@property (nonatomic, strong)HyBidAdSize *adSize;

@end

@implementation HyBidAd

- (void)dealloc {
    self.data = nil;
    self.contentInfoView = nil;
    self.assetGroupID = nil;
    self.adSize = nil;
}

#pragma mark HyBidAd

- (instancetype)initWithData:(HyBidAdModel *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (instancetype)initWithVWXml:(NSDictionary *)xml andWithAdSize:(HyBidAdSize *)adSize {
    self = [super init];
    if (self) {
        HyBidAdModel *model = [[HyBidAdModel alloc] init];
        self.adSize = adSize;
        NSString *apiAsset = PNLiteAsset.htmlBanner;
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        
        NSDictionary *rawResponse = [xml valueForKey:@"rawResponse"];
        
        if (rawResponse && [rawResponse valueForKey:@"useRawResponse"] && [[rawResponse valueForKey:@"useRawResponse"] boolValue]) {
            NSString *html = [rawResponse valueForKey:@"response"];
            HyBidDataModel *data = [[HyBidDataModel alloc] initWithHtmlAsset:apiAsset withValue:html];
            [assets addObject:data];
        } else {
            // TODO https://wiki.vervemobile.com/confluence/display/CDOC/AdCel+API#AdCelAPI-AdRequests
            NSDictionary *media = [xml valueForKey:@"media"];
            NSDictionary *clickthrough = [xml valueForKey:@"clickthrough"];
            NSDictionary *copy = [xml valueForKey:@"copy"];
            
            NSString *bannerImage = [[media valueForKey:@"image_url"] stringValue];
            NSString *clickThroughUrl = [[clickthrough valueForKey:@"url"] stringValue];
            NSString *text = [[copy valueForKey:@"leadin"] stringValue];
            
            NSString *html = [NSString stringWithFormat:@"<html><body><a href=\"%@\">%@<img src=\"%@\"/></a></body></html>", clickThroughUrl, text, bannerImage];
            HyBidDataModel *data = [[HyBidDataModel alloc] initWithHtmlAsset:apiAsset withValue:html];
            [assets addObject:data];
        }
        
        model.assets = assets;
        if ([adSize isEqualTo:HyBidAdSize.SIZE_INTERSTITIAL]) {
            model.assetgroupid = [NSNumber numberWithInt:MRAID_320x480];
        } else {
            model.assetgroupid = [NSNumber numberWithInt:MRAID_320x50];
        }
        self.data = model;
    }
    return self;
}

- (NSString *)vast {
    NSString *result = nil;
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.vast];
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
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
    if (data) {
        result = data.html;
    }
    return result;
}

- (NSString *)link {
    NSString *result = nil;
    if (self.data) {
        result = self.data.link;
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
        if (data.width) {
            result = data.width;
        } else {
            result = [NSNumber numberWithInteger:self.adSize.width];
        }
    }
    return result;
}

- (NSNumber *)height {
    NSNumber *result = nil;
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
    if (data) {
        if (data.height) {
            result = data.height;
        } else {
            result = [NSNumber numberWithInteger:self.adSize.height];
        }
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
        }
    }
    return self.contentInfoView;
}

- (HyBidDataModel *)assetDataWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    if (self.data) {
        result = [self.data assetWithType:type];
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

@end
