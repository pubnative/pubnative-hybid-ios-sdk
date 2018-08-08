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

#import "PNLiteAd.h"
#import "PNLiteMeta.h"
#import "PNLiteAsset.h"
#import "PNLiteContentInfoView.h"

NSString *const kImpressionURL = @"got.pubnative.net";
NSString *const kImpressionQuerryParameter = @"t";

@interface PNLiteAd ()

@property (nonatomic, strong)PNLiteAdModel *data;
@property (nonatomic, strong)PNLiteContentInfoView *contentInfoView;

@end

@implementation PNLiteAd

- (void)dealloc
{
    self.data = nil;
    self.contentInfoView = nil;
}

#pragma mark PNLiteAd

- (instancetype)initWithData:(PNLiteAdModel *)data
{
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (NSString *)vast
{
    NSString *result = nil;
    PNLiteDataModel *data = [self assetDataWithType:PNLiteAsset.vast];
    if (data) {
        result = data.vast;
    }
    return result;
}

- (NSString *)htmlUrl
{
    NSString *result = nil;
    PNLiteDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
    if (data) {
        result = data.url;
    }
    return result;
}

- (NSString *)htmlData
{
    NSString *result = nil;
    PNLiteDataModel *data = [self assetDataWithType:PNLiteAsset.htmlBanner];
    if (data) {
        result = data.html;
    }
    return result;
}

- (NSString *)impressionID
{
    NSArray *impressionBeacons = [self beaconsDataWithType:@"impression"];
    BOOL found = NO;
    NSString *impressionID = @"";
    NSInteger index = 0;
    while (index < impressionBeacons.count && !found) {
        PNLiteDataModel *impressionBeacon = [impressionBeacons objectAtIndex:index];
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

- (NSNumber *)assetGroupID
{
    NSNumber *result = nil;
    if (self.data) {
        result = self.data.assetgroupid;
    }
    return result;
}

- (NSNumber *)eCPM
{
    NSNumber *result = nil;
    PNLiteDataModel *data = [self metaDataWithType:PNLiteMeta.points];
    if (data) {
        result = data.eCPM;
    }
    return result;
}

- (PNLiteContentInfoView *)contentInfo
{
    PNLiteDataModel *data = [self metaDataWithType:PNLiteMeta.contentInfo];
    if (data) {
        if (self.contentInfoView == nil) {
            self.contentInfoView = [[PNLiteContentInfoView alloc] init];
            self.contentInfoView.text = data.text;
            self.contentInfoView.link = [data stringFieldWithKey:@"link"];
            self.contentInfoView.icon = [data stringFieldWithKey:@"icon"];
        }
    }
    return self.contentInfoView;
}

- (PNLiteDataModel *)assetDataWithType:(NSString *)type
{
    PNLiteDataModel *result = nil;
    if (self.data) {
        result = [self.data assetWithType:type];
    }
    return result;
}

- (PNLiteDataModel *)metaDataWithType:(NSString *)type
{
    PNLiteDataModel *result = nil;
    if (self.data) {
        result = [self.data metaWithType:type];
    }
    return result;
}

- (NSArray *)beaconsDataWithType:(NSString *)type
{
    NSArray *result = nil;
    if (self.data) {
        result = [self.data beaconsWithType:type];
    }
    return result;
}

- (NSString *)valueForKey:(NSString *)key fromQueryItems:(NSArray *)queryItems
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

@end
