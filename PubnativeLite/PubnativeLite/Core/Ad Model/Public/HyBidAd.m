// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAd.h"
#import "PNLiteMeta.h"
#import "PNLiteData.h"
#import "PNLiteAsset.h"
#import "HyBidContentInfoView.h"
#import "HyBidSkAdNetworkModel.h"
#import "HyBidOpenRTBAdModel.h"
#import "HyBid.h"
#import "HyBidSKAdNetworkParameter.h"
#import "HyBidATOMFlow.h"

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
@property (nonatomic, readwrite)NSString *adFormat;

#if __has_include(<ATOM/ATOM-Swift.h>)
@property (nonatomic, strong)NSArray<NSString *> *_cohorts;
#endif

@end

@implementation HyBidAd

- (void)dealloc {
    self.data = nil;
    self.contentInfoView = nil;
    self._zoneID = nil;
    self.customEndCard = nil;
    
    #if __has_include(<ATOM/ATOM-Swift.h>)
    self._cohorts = nil;
    #endif
}

#pragma mark HyBidAd

- (instancetype)initWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID {
    self = [super init];
    if (self) {
        self.data = data;
        self._zoneID = zoneID;
        [self saveAdFormat:data];
    }
    return self;
}

- (void)saveAdFormat:(id)data {
    if ([data respondsToSelector:@selector(assets)]) {
        NSArray *assets = [data valueForKey:@"assets"];
        if ([assets isKindOfClass:[NSArray class]] && assets.count > 0) {
            id firstAsset = assets.firstObject;
            if ([firstAsset respondsToSelector:@selector(type)]) {
                id typeValue = [firstAsset valueForKey:@"type"];
                if (typeValue) {
                    self.adFormat = typeValue;
                }
            }
        }
    }
}

#if __has_include(<ATOM/ATOM-Swift.h>)
- (instancetype)initWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID withCohorts:(NSArray<NSString *> *)cohorts
{
    self = [super init];
    if (self) {
        self.data = data;
        self._zoneID = zoneID;
        self._cohorts = cohorts;
        [self saveAdFormat:data];
    }
    return self;
}

- (instancetype)initOpenRTBWithData:(HyBidOpenRTBAdModel *)data withZoneID:(NSString *)zoneID withCohorts:(NSArray<NSString *> *)cohorts {
    self = [super init];
    if (self) {
        self.openRTBData = data;
        self._zoneID = zoneID;
        self._cohorts = cohorts;
        [self saveAdFormat:data];
    }
    return self;
}
#endif

- (instancetype)initOpenRTBWithData:(HyBidOpenRTBAdModel *)data withZoneID:(NSString *)zoneID {
    self = [super init];
    if (self) {
        self.openRTBData = data;
        self._zoneID = zoneID;
        [self saveAdFormat:data];
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
            self.adFormat = @"VAST";
        } else {
            apiAsset = PNLiteAsset.htmlBanner;
            data = [[HyBidOpenRTBDataModel alloc] initWithHTMLAsset:apiAsset withValue:adContent];
            self.adType = kHyBidAdTypeHTML;
            self.adFormat = @"htmlBanner";
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
            self.adFormat = @"VAST";
        } else {
            apiAsset = PNLiteAsset.htmlBanner;
            data = [[HyBidDataModel alloc] initWithHTMLAsset:apiAsset withValue:adContent];
            self.adType = kHyBidAdTypeHTML;
            self.adFormat = @"htmlBanner";
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

#if __has_include(<ATOM/ATOM-Swift.h>)
- (NSArray<NSString *> *)cohorts
{
    return self._cohorts;
}
#endif

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

- (NSString *)customEndCardInputValue {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.customEndCardInputValue] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.customEndCardInputValue];
        }
    }
    return result;
}

- (NSString *)customEndCardData {
    NSString *customEndCardInputValue = [self customEndCardInputValue];
    
    if (customEndCardInputValue) {
        return customEndCardInputValue;
    }
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.customEndcard];
    return (data) ? data.html : nil;
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

- (NSString *)bundleID {
    NSString *customBundleIdValue = [self customBundleIdValue];
    if (customBundleIdValue) {
        return customBundleIdValue;
    }
    
    NSString *bundleID = nil;
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.bundleId];
    if(data) {
        bundleID = data.text;
    }
    return bundleID;
}

- (NSString *)adExperience {
    NSString *adExperience = nil;
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.adExperience];
    if(data && [data.text isKindOfClass:[NSString class]]) {
        if ([data.text isEqualToString:HyBidAdExperienceBrandValue] || [data.text isEqualToString:HyBidAdExperiencePerformanceValue]) {
            adExperience = data.text;
        }
    }
    return adExperience;
}

- (NSString *)customBundleIdValue {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteMeta.customBundleIdValue] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteMeta.customBundleIdValue];
        }
    }
    return result;
}

- (NSString *)openRTBCreativeID {
    NSString *creativeID = nil;
    if(self.openRTBData) {
        creativeID = self.openRTBData.creativeid;
    }
    return creativeID;
}

- (NSString *)campaignID {
    NSString *campaignID = @"";
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.campaignId];
    if(data) {
        campaignID = data.text;
    }
    return campaignID;
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

- (NSDictionary *)jsonData {
    NSDictionary *result = nil;
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.remoteconfigs];
    if (data && [data hasFieldForKey:PNLiteData.jsonData]) {
        result = data.jsonData;
    }
    return result;
}

- (NSNumber *)skoverlayEnabled {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcSKoverlayEnabled;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.skoverlayEnabled] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.skoverlayEnabled];
            }
        }
    }
    return result;
}

- (NSNumber *)pcSKoverlayEnabled {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcSKoverlayEnabled] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcSKoverlayEnabled];
        }
    }
    return result;
}

- (NSString *)audioState {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.audioState] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.audioState];
        }
    }
    return result;
}

- (NSString *)contentInfoURL {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.contentInfoURL] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.contentInfoURL];
        }
    }
    return result;
}

- (NSString *)contentInfoIconURL {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.contentInfoIconURL] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.contentInfoIconURL];
        }
    }
    return result;
}

- (NSString *)contentInfoIconClickAction {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.contentInfoIconClickAction] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.contentInfoIconClickAction];
        }
    }
    return result;
}

- (NSString *)contentInfoDisplay {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.contentInfoDisplay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.contentInfoDisplay];
        }
    }
    return result;
}

- (NSString *)contentInfoText {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.contentInfoText] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.contentInfoText];
        }
    }
    return result;
}

//- (NSString *)contentInfoHorizontalPosition {
//    NSString *result = nil;
//    NSDictionary *jsonDictionary = [self jsonData];
//    if (jsonDictionary) {
//        if ([jsonDictionary objectForKey:PNLiteData.contentInfoHorizontalPosition] != (id)[NSNull null]) {
//            result = [jsonDictionary objectForKey:PNLiteData.contentInfoHorizontalPosition];
//        }
//    }
//    return result;
//}
//
//- (NSString *)contentInfoVeritcalPosition {
//    NSString *result = nil;
//    NSDictionary *jsonDictionary = [self jsonData];
//    if (jsonDictionary) {
//        if ([jsonDictionary objectForKey:PNLiteData.contentInfoVerticalPosition] != (id)[NSNull null]) {
//            result = [jsonDictionary objectForKey:PNLiteData.contentInfoVerticalPosition];
//        }
//    }
//    return result;
//}

- (NSNumber *)creativeAutoStorekitEnabled {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.creativeAutoStorekitEnabled] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.creativeAutoStorekitEnabled];
        }
    }
    return result;
}

- (NSNumber *)sdkAutoStorekitEnabled {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcSDKAutoStorekitEnabled;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitEnabled] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitEnabled];
            }
        }
    }
    return result;
}

- (NSNumber *)pcSDKAutoStorekitEnabled {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcSDKAutoStorekitEnabled] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcSDKAutoStorekitEnabled];
        }
    }
    return result;
}

- (NSNumber *)sdkAutoStorekitDelay {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitDelay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitDelay];
        }
    }
    return result;
}

- (NSNumber *)endcardEnabled {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcEndcardEnabled;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.endcardEnabled] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.endcardEnabled];
            }
        }
    }
    return result;
}

- (NSNumber *)pcEndcardEnabled {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcEndcardEnabled] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcEndcardEnabled];
        }
    }
    return result;
}

- (NSNumber *)customEndcardEnabled {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.customEndcardEnabled] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.customEndcardEnabled];
        }
    }
    return result;
}

- (NSNumber *)endcardCloseDelay {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcEndcardCloseDelay;
    } else if ([self.adExperience isEqualToString:HyBidAdExperienceBrandValue] && self.isBrandCompatible) {
        return self.bcEndcardCloseDelay;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.endcardCloseDelay] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.endcardCloseDelay];
            }
        }
    }
    return result;
}

- (NSNumber *)pcEndcardCloseDelay {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcEndcardCloseDelay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcEndcardCloseDelay];
        }
    }
    return result;
}

- (NSNumber *)bcEndcardCloseDelay {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.bcEndcardCloseDelay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.bcEndcardCloseDelay];
        }
    }
    return result;
}

- (NSNumber *)nativeCloseButtonDelay {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.nativeCloseButtonDelay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.nativeCloseButtonDelay];
        }
    }
    return result;
}

- (NSNumber *)interstitialHtmlSkipOffset {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcInterstitialHtmlSkipOffset;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.interstitialHtmlSkipOffset] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.interstitialHtmlSkipOffset];
            }
        }
    }
    return result;
}

- (NSNumber *)pcInterstitialHtmlSkipOffset {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcInterstitialHtmlSkipOffset] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcInterstitialHtmlSkipOffset];
        }
    }
    return result;
}

- (NSNumber *)rewardedHtmlSkipOffset {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcRewardedHtmlSkipOffset;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.rewardedHtmlSkipOffset] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.rewardedHtmlSkipOffset];
            }
        }
    }
    return result;
}

- (NSNumber *)pcRewardedHtmlSkipOffset {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcRewardedHtmlSkipOffset] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcRewardedHtmlSkipOffset];
        }
    }
    return result;
}

- (NSNumber *)videoSkipOffset {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcVideoSkipOffset;
    }  else if ([self.adExperience isEqualToString:HyBidAdExperienceBrandValue] && self.isBrandCompatible) {
        return self.bcVideoSkipOffset;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.videoSkipOffset] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.videoSkipOffset];
            }
        }
    }
    return result;
}

- (NSNumber *)pcVideoSkipOffset {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcVideoSkipOffset] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcVideoSkipOffset];
        }
    }
    return result;
}

- (NSNumber *)bcVideoSkipOffset {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.bcVideoSkipOffset] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.bcVideoSkipOffset];
        }
    }
    return result;
}

- (NSNumber *)rewardedVideoSkipOffset {
    NSNumber *result = nil;
    if ([self.adExperience isEqualToString:HyBidAdExperiencePerformanceValue] && self.isPerformanceCompatible) {
        return self.pcRewardedVideoSkipOffset;
    } else if ([self.adExperience isEqualToString:HyBidAdExperienceBrandValue] && self.isBrandCompatible) {
        return self.bcRewardedVideoSkipOffset;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.rewardedVideoSkipOffset] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.rewardedVideoSkipOffset];
            }
        }
    }
    return result;
}

- (NSNumber *)pcRewardedVideoSkipOffset {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.pcRewardedVideoSkipOffset] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.pcRewardedVideoSkipOffset];
        }
    }
    return result;
}

- (NSNumber *)bcRewardedVideoSkipOffset {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.bcRewardedVideoSkipOffset] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.bcRewardedVideoSkipOffset];
        }
    }
    return result;
}

- (NSNumber *)closeInterstitialAfterFinish {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.closeInterstitialAfterFinish] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.closeInterstitialAfterFinish];
        }
    }
    return result;
}

- (NSNumber *)closeRewardedAfterFinish {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.closeRewardedAfterFinish] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.closeRewardedAfterFinish];
        }
    }
    return result;
}

- (NSNumber *)fullscreenClickability {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.fullscreenClickability] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.fullscreenClickability];
        }
    }
    return result;
}

-(NSNumber *)mraidExpand {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.mraidExpand] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.mraidExpand];
        }
    }
    return result;
}

- (NSNumber *)minVisibleTime {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.minVisibleTime] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.minVisibleTime];
        }
    }
    return result;
}

- (NSNumber *)minVisiblePercent {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.minVisiblePercent] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.minVisiblePercent];
        }
    }
    return result;
}

- (NSString *)impressionTrackingMethod {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.impressionTracking] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.impressionTracking];
        }
    }
    return result;
}

- (NSString *)customEndcardDisplay {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.customEndcardDisplay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.customEndcardDisplay];
        }
    }
    return result;
}

- (NSNumber *)customCtaEnabled {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.customCtaEnabled] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.customCtaEnabled];
        }
    }
    return result;
}

- (NSNumber *)customCtaDelay {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.customCtaDelay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.customCtaDelay];
        }
    }
    return result;
}

- (NSString *)customCtaInputValue {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.customCtaInputValue] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.customCtaInputValue];
        }
    }
    return result;
}

- (NSString *)itunesIdValue {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.itunesIdValue] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.itunesIdValue];
        }
    }
    return result;
}

- (NSString *)customCtaIconURL {
    NSString *customCtaInputValue = [self customCtaInputValue];
    if (customCtaInputValue) {
        return customCtaInputValue;
    }
    
    NSString *result = nil;
    HyBidDataModel *data = [self assetDataWithType:PNLiteAsset.customCTA];
    if (data) {
        result = [data stringFieldWithKey:@"icon"];
    }
    return result;
}

- (BOOL)iconSizeReduced {
    NSNumber *iconSizeReducedInputValue = [self iconSizeReducedInputValue];
    if (iconSizeReducedInputValue) {
        return [iconSizeReducedInputValue boolValue];
    }
    
    BOOL result = false;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.reducedIconSizes] != (id)[NSNull null]) {
            result = [[jsonDictionary objectForKey:PNLiteData.reducedIconSizes] boolValue];
        }
    }
    return result;
}

- (BOOL)hideControls {
    BOOL result = false;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.hideControls] != (id)[NSNull null]) {
            result = [[jsonDictionary objectForKey:PNLiteData.hideControls] boolValue];
        }
    }
    return result;
}

- (NSNumber *)iconSizeReducedInputValue {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.reducedIconSizesInputValue] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.reducedIconSizesInputValue];
        }
    }
    return result;
}

- (NSString *)navigationModeInputValue {
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.navigationModeInputValue] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.navigationModeInputValue];
        }
    }
    return result;
}

- (NSString *)navigationMode {
    NSString *navigationModeInputValue = [self navigationModeInputValue];
    if (navigationModeInputValue) { return navigationModeInputValue; }
    
    NSString *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.navigationMode] != (id)[NSNull null] &&
            [[jsonDictionary objectForKey:PNLiteData.navigationMode] isKindOfClass:[NSString class]]) {
            result = [jsonDictionary objectForKey:PNLiteData.navigationMode];
        }
    }
    return result;
}

- (BOOL)landingPage {
    BOOL landingPageInputValue = [self landingPageInputValue];
    if (landingPageInputValue) { return landingPageInputValue;}
    
    BOOL result = NO;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.landingPage] != (id)[NSNull null]) {
            result = [[jsonDictionary objectForKey:PNLiteData.landingPage] boolValue];
        }
    }
    return result;
}

- (BOOL)landingPageInputValue {
    BOOL result = NO;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.landingPageInputValue] != (id)[NSNull null]) {
            result = [[jsonDictionary objectForKey:PNLiteData.landingPageInputValue] boolValue];
        }
    }
    return result;
}

- (HyBidCTAData *)ctaData {

    if (![self.adExperience isEqualToString:HyBidAdExperienceBrandValue] || [self.assetGroupID intValue] != VAST_INTERSTITIAL || [self.assetGroupID intValue] != VAST_REWARDED) {
        return [[HyBidCTAData alloc] initWithSize:HyBidCTASizeDefault location:HyBidCTALocationDefault];
    }
    
    NSDictionary *jsonDictionary = [self jsonData];
    HyBidCTASize size = [HyBidCTAData sizeFromValue: [self gettingObjectFrom:jsonDictionary key:PNLiteData.ctaButtonSizeInputValue]];
    HyBidCTALocation location = [HyBidCTAData locationFromValue: [self gettingObjectFrom:jsonDictionary
                                                                                     key:PNLiteData.ctaButtonLocationInputValue]];
    
    if (![self parameterHasValue:PNLiteData.ctaButtonSizeInputValue dictionary:jsonDictionary]){
        size = [HyBidCTAData sizeFromValue: [self gettingObjectFrom:jsonDictionary key:PNLiteData.ctaButtonSize]];
    }
    
    if (![self parameterHasValue:PNLiteData.ctaButtonLocationInputValue dictionary:jsonDictionary]){
        location = [HyBidCTAData locationFromValue: [jsonDictionary objectForKey:PNLiteData.ctaButtonLocation]];
    }
        
    return [[HyBidCTAData alloc] initWithSize: size location:location];
}

- (nullable id)gettingObjectFrom:(NSDictionary*)dictionary key:(NSString*)key {
    if (dictionary && [dictionary objectForKey:key] != nil && [dictionary objectForKey:key] != (id)[NSNull null]) {
        return [dictionary objectForKey:key];
    }
    return nil;
}

- (BOOL)parameterHasValue:(NSString *)parameter dictionary:(NSDictionary *)dictionary  {
    if (dictionary && parameter && [dictionary objectForKey:parameter] != nil && [dictionary objectForKey:parameter] != (id)[NSNull null]) {
        return YES;
    }
    
    return NO;
}

- (NSArray<HyBidDataModel *> *)beacons {
    if (self.data) {
        return self.data.beacons;
    } else {
        return nil;
    }
}

- (HyBidContentInfoView *)contentInfo {
    self.contentInfoView = [[HyBidContentInfoView alloc] init];
    self.contentInfoView.text = [self determineContentInfoText];
    self.contentInfoView.link = [self determineContentInfoURL];
    self.contentInfoView.icon = [self determineContentInfoIconURL];
    self.contentInfoView.clickAction = [self determineContentInfoIconClickAction];
    self.contentInfoView.display = [self determineContentInfoDisplay];
    self.contentInfoView.horizontalPosition = [self determineContentInfoHorizontalPosition];
    self.contentInfoView.verticalPosition = [self determineContentInfoVerticalPosition];
    self.contentInfoView.isCustom = NO;
    return self.contentInfoView;
}

- (HyBidContentInfoView *)getContentInfoView {
    return [self getContentInfoViewFrom:nil];
}

- (HyBidContentInfoView *)getContentInfoViewFrom:(HyBidContentInfoView *)infoView {
    HyBidContentInfoView *contentInfoView = [self getCustomContentInfoFrom:infoView];

    if (contentInfoView == nil) {
        contentInfoView = [self contentInfo];
    }
    
    return contentInfoView;
}

- (HyBidContentInfoView *)getCustomContentInfoFrom:(HyBidContentInfoView *)contentInfoView {
    if (contentInfoView == nil || [contentInfoView.icon length] == 0) {
        return nil;
    } else {
        HyBidContentInfoView *result = [[HyBidContentInfoView alloc] init];
        result.icon = contentInfoView.icon;
        result.link = contentInfoView.link;
        result.isCustom = contentInfoView.isCustom;
        result.text = [contentInfoView.text length] == 0 ? contentInfoView.text : ContentInfoViewText;
        result.zoneID = self.zoneID;
        result.display = [self determineContentInfoDisplay];
        result.clickAction = [self determineContentInfoIconClickAction];
        return result;
    }
}

- (NSString *)determineContentInfoURL {
    if (self.contentInfoURL && [self.contentInfoURL isKindOfClass:[NSString class]]) {
        return self.contentInfoURL;
    } else if ([self metaDataWithType:PNLiteMeta.contentInfo] && [[self metaDataWithType:PNLiteMeta.contentInfo] stringFieldWithKey:@"link"]) {
        return [[self metaDataWithType:PNLiteMeta.contentInfo] stringFieldWithKey:@"link"];
    } else {
        return ContentInfoViewLink;
    }
}

- (NSString *)determineContentInfoIconURL {
    if (self.contentInfoIconURL && [self.contentInfoIconURL isKindOfClass:[NSString class]]) {
        return self.contentInfoIconURL;
    } else if ([self metaDataWithType:PNLiteMeta.contentInfo] && [[self metaDataWithType:PNLiteMeta.contentInfo] stringFieldWithKey:@"icon"]) {
        return [[self metaDataWithType:PNLiteMeta.contentInfo] stringFieldWithKey:@"icon"];
    } else {
        return ContentInfoViewIcon;
    }
}

- (HyBidContentInfoClickAction)determineContentInfoIconClickAction {
    if (self.contentInfoIconClickAction && [self.contentInfoIconClickAction isKindOfClass:[NSString class]]) {
        if ([self.contentInfoIconClickAction isEqualToString:@"open"]) {
            return HyBidContentInfoClickActionOpen;
        } else {
            return HyBidContentInfoClickActionExpand;
        }
    } else {
        return HyBidContentInfoClickActionExpand;
    }
}

- (HyBidContentInfoDisplay)determineContentInfoDisplay {
    if (self.contentInfoDisplay && [self.contentInfoDisplay isKindOfClass:[NSString class]]) {
        if ( [self.contentInfoDisplay isEqualToString:@"inapp"]) {
            return HyBidContentInfoDisplayInApp;
        } else {
            return HyBidContentInfoDisplaySystem;
        }
    } else {
        return HyBidContentInfoDisplaySystem;
    }
}

- (NSString *)determineContentInfoText {
    if (self.contentInfoText && [self.contentInfoText isKindOfClass:[NSString class]]) {
        return self.contentInfoText;
    } else if ([self metaDataWithType:PNLiteMeta.contentInfo] && [self metaDataWithType:PNLiteMeta.contentInfo].text) {
        return [self metaDataWithType:PNLiteMeta.contentInfo].text;
    } else {
        return ContentInfoViewText;
    }
}

- (HyBidContentInfoHorizontalPosition)determineContentInfoHorizontalPosition {
    return HyBidContentInfoHorizontalPositionLeft;
}

- (HyBidContentInfoVerticalPosition)determineContentInfoVerticalPosition {
    return HyBidContentInfoVerticalPositionBottom;
}

- (HyBidSkAdNetworkModel *)getOpenRTBSkAdNetworkModel {
    HyBidOpenRTBDataModel *data = [self skAdNetworkModelInputValue]
                                ? [[HyBidOpenRTBDataModel alloc] initWithDictionary: [self skAdNetworkModelInputValue]]
                                : [self extensionDataWithType:PNLiteMeta.skadnetwork];
    if (![data.data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    HyBidSkAdNetworkModel *model = [[HyBidSkAdNetworkModel alloc] init];
    
    if (data) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceIdentifier] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceIdentifier] forKey:HyBidSKAdNetworkParameter.sourceIdentifier];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.campaign] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.campaign] forKey:HyBidSKAdNetworkParameter.campaign];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.productPageId] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.productPageId] forKey:HyBidSKAdNetworkParameter.productPageId];
        }
        
        if ([self itunesIdValue]) {
            [dict setValue:[self itunesIdValue] forKey:HyBidSKAdNetworkParameter.itunesitem];
        } else {
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.itunesitem] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.itunesitem] forKey:HyBidSKAdNetworkParameter.itunesitem];
            }
        }
        
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.network] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.network] forKey:HyBidSKAdNetworkParameter.network];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceapp] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceapp] forKey:HyBidSKAdNetworkParameter.sourceapp];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.version] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.version] forKey:HyBidSKAdNetworkParameter.version];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.present] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.present] forKey:HyBidSKAdNetworkParameter.present];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.position] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.position] forKey:HyBidSKAdNetworkParameter.position];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.dismissible] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.dismissible] forKey:HyBidSKAdNetworkParameter.dismissible];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.delay] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.delay] forKey:HyBidSKAdNetworkParameter.delay];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.endcardDelay] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.endcardDelay] forKey:HyBidSKAdNetworkParameter.endcardDelay];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.autoClose] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.autoClose] forKey:HyBidSKAdNetworkParameter.autoClose];
        }
        
        double skanVersion = [[data dictionary][HyBidSKAdNetworkParameter.skadn][HyBidSKAdNetworkParameter.version] doubleValue];
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [data.dictionary[HyBidSKAdNetworkParameter.skadn][HyBidSKAdNetworkParameter.fidelities] count] > 0) {
            SKANObject skan;
            NSArray *fidelities = data.dictionary[HyBidSKAdNetworkParameter.skadn][HyBidSKAdNetworkParameter.fidelities];
            NSMutableArray<NSData *> *skanDataArray = [NSMutableArray new];
            
            for (NSDictionary *fidelity in fidelities) {
                if (fidelity[HyBidSKAdNetworkParameter.nonce] != nil &&
                    fidelity[HyBidSKAdNetworkParameter.signature] != nil &&
                    fidelity[HyBidSKAdNetworkParameter.timestamp] != nil &&
                    fidelity[HyBidSKAdNetworkParameter.fidelity] != nil) {
                    skan.nonce = (char *)[fidelity[HyBidSKAdNetworkParameter.nonce] UTF8String];
                    skan.signature = (char *)[fidelity[HyBidSKAdNetworkParameter.signature] UTF8String];
                    skan.timestamp = (char *)[fidelity[HyBidSKAdNetworkParameter.timestamp] UTF8String];
                    skan.fidelity = [fidelity[HyBidSKAdNetworkParameter.fidelity] intValue];
                    
                    NSData *d = [NSData dataWithBytes:&skan length:sizeof(SKANObject)];
                    [skanDataArray addObject:d];
                }
            }
            
            [dict setObject:skanDataArray forKey:HyBidSKAdNetworkParameter.fidelities];
        } else {
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.signature] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.signature] forKey:HyBidSKAdNetworkParameter.signature];
            }
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.timestamp] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.timestamp] forKey:HyBidSKAdNetworkParameter.timestamp];
            }
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.nonce] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.nonce] forKey:HyBidSKAdNetworkParameter.nonce];
            }
            if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.fidelityType] != nil) {
                [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.fidelityType] forKey:HyBidSKAdNetworkParameter.fidelityType];
            }
        }
        
        model.productParameters = [dict copy];
    }
    
    return model;
}

- (HyBidSkAdNetworkModel *)getOpenRTBAdAttributionModel {
    HyBidOpenRTBDataModel *data = [self extensionDataWithType:PNLiteMeta.adattributionkit];
    HyBidSkAdNetworkModel *model = [[HyBidSkAdNetworkModel alloc] init];
    
    if (data) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        if ([data stringFieldWithKey:HyBidAdAttributionParameter.jwt] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidAdAttributionParameter.jwt] forKey:HyBidAdAttributionParameter.jwt];
        }
        
        if ([data numberFieldWithKey:HyBidAdAttributionParameter.custom_market_place] != nil) {
            [dict setValue: [data numberFieldWithKey:HyBidAdAttributionParameter.custom_market_place]
                    forKey: HyBidAdAttributionParameter.custom_market_place];
        }
        
        if ([data stringFieldWithKey:HyBidAdAttributionParameter.reengagement_url] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidAdAttributionParameter.reengagement_url] forKey:HyBidAdAttributionParameter.reengagement_url];
        }
        
        model.productParameters = [dict copy];
    }
    
    return model;
}

- (HyBidSkAdNetworkModel *)getSkAdNetworkModel {
    HyBidSkAdNetworkModel *model = [[HyBidSkAdNetworkModel alloc] init];
    HyBidDataModel *data = [self skAdNetworkModelInputValue]
                         ? [[HyBidDataModel alloc] initWithDictionary: [self skAdNetworkModelInputValue]]
                         : [self metaDataWithType:PNLiteMeta.skadnetwork];
    
    if (data) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceIdentifier] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceIdentifier] forKey:HyBidSKAdNetworkParameter.sourceIdentifier];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.campaign] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.campaign] forKey:HyBidSKAdNetworkParameter.campaign];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.productPageId] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.productPageId] forKey:HyBidSKAdNetworkParameter.productPageId];
        }
        
        if ([self itunesIdValue]) {
            [dict setValue:[self itunesIdValue] forKey:HyBidSKAdNetworkParameter.itunesitem];
        } else {
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.itunesitem] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.itunesitem] forKey:HyBidSKAdNetworkParameter.itunesitem];
            }
        }

        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.network] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.network] forKey:HyBidSKAdNetworkParameter.network];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceapp] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.sourceapp] forKey:HyBidSKAdNetworkParameter.sourceapp];
        }
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.version] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.version] forKey:HyBidSKAdNetworkParameter.version];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.present] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.present] forKey:HyBidSKAdNetworkParameter.present];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.position] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.position] forKey:HyBidSKAdNetworkParameter.position];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.dismissible] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.dismissible] forKey:HyBidSKAdNetworkParameter.dismissible];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.delay] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.delay] forKey:HyBidSKAdNetworkParameter.delay];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.endcardDelay] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.endcardDelay] forKey:HyBidSKAdNetworkParameter.endcardDelay];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.autoClose] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.autoClose] forKey:HyBidSKAdNetworkParameter.autoClose];
        }
        if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.click] != nil) {
            [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.click] forKey:HyBidSKAdNetworkParameter.click];
        }
        
        double skanVersion = [[data dictionary][@"data"][HyBidSKAdNetworkParameter.version] doubleValue];
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [data.dictionary[@"data"][HyBidSKAdNetworkParameter.fidelities] count] > 0) {
            SKANObject skan;
            NSArray *fidelities = data.dictionary[@"data"][HyBidSKAdNetworkParameter.fidelities];
            NSMutableArray<NSData *> *skanDataArray = [NSMutableArray new];
            
            for (NSDictionary *fidelity in fidelities) {
                if (fidelity[HyBidSKAdNetworkParameter.nonce] != nil &&
                    fidelity[HyBidSKAdNetworkParameter.signature] != nil &&
                    fidelity[HyBidSKAdNetworkParameter.timestamp] != nil &&
                    fidelity[HyBidSKAdNetworkParameter.fidelity] != nil) {
                    skan.nonce = (char *)[fidelity[HyBidSKAdNetworkParameter.nonce] UTF8String];
                    skan.signature = (char *)[fidelity[HyBidSKAdNetworkParameter.signature] UTF8String];
                    skan.timestamp = (char *)[fidelity[HyBidSKAdNetworkParameter.timestamp] UTF8String];
                    skan.fidelity = [fidelity[HyBidSKAdNetworkParameter.fidelity] intValue];
                    
                    NSData *d = [NSData dataWithBytes:&skan length:sizeof(SKANObject)];
                    [skanDataArray addObject:d];
                }
            }
            
            [dict setObject:skanDataArray forKey:HyBidSKAdNetworkParameter.fidelities];
        } else {
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.nonce] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.nonce] forKey:HyBidSKAdNetworkParameter.nonce];
            }
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.signature] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.signature] forKey:HyBidSKAdNetworkParameter.signature];
            }
            if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.timestamp] != nil) {
                [dict setValue:[data stringFieldWithKey:HyBidSKAdNetworkParameter.timestamp] forKey:HyBidSKAdNetworkParameter.timestamp];
            }
            if ([data numberFieldWithKey:HyBidSKAdNetworkParameter.fidelityType] != nil) {
                [dict setValue:[data numberFieldWithKey:HyBidSKAdNetworkParameter.fidelityType] forKey:HyBidSKAdNetworkParameter.fidelityType];
            }
        }
        
        model.productParameters = [dict copy];
    }
    
    return model;
}

- (NSDictionary *)skAdNetworkModelInputValue {
    NSDictionary *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteMeta.skadnetworkInputValue] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteMeta.skadnetworkInputValue];
        }
    }
    return result;
}

- (HyBidSkAdNetworkModel *)getAdAttributionModel {
    HyBidSkAdNetworkModel *model = [[HyBidSkAdNetworkModel alloc] init];
    HyBidDataModel *data = [self metaDataWithType:PNLiteMeta.adattributionkit];
    
    if (data) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        
        if ([data stringFieldWithKey:HyBidAdAttributionParameter.jwt] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidAdAttributionParameter.jwt] forKey:HyBidAdAttributionParameter.jwt];
        }
        
        if ([data numberFieldWithKey:HyBidAdAttributionParameter.custom_market_place] != nil) {
            [dict setValue: [data numberFieldWithKey:HyBidAdAttributionParameter.custom_market_place]
                    forKey: HyBidAdAttributionParameter.custom_market_place];
        }
        
        if ([data stringFieldWithKey:HyBidAdAttributionParameter.reengagement_url] != nil) {
            [dict setValue:[data stringFieldWithKey:HyBidAdAttributionParameter.reengagement_url] forKey:HyBidAdAttributionParameter.reengagement_url];
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

- (NSComparisonResult)compare:(HyBidAd*)other {
    return [self.eCPM compare:other.eCPM];
}

- (BOOL)isPerformanceCompatible {
    return ([self.assetGroupID intValue] == VAST_INTERSTITIAL || [self.assetGroupID intValue] == MRAID_320x480 || [self.assetGroupID intValue] == MRAID_480x320 || [self.assetGroupID intValue] == MRAID_768x1024 || [self.assetGroupID intValue] == MRAID_1024x768 || [self.assetGroupID intValue] == MRAID_300x600);
}

- (BOOL)isBrandCompatible {
    return [self.assetGroupID intValue] == VAST_INTERSTITIAL;
}

@end
