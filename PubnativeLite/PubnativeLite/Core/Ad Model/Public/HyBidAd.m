// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAd.h"
#import "HyBidAd+Internal.h"
#import "PNLiteMeta.h"
#import "PNLiteData.h"
#import "PNLiteAsset.h"
#import "HyBidContentInfoView.h"
#import "HyBidSkAdNetworkModel.h"
#import "HyBidOpenRTBAdModel.h"
#import "HyBid.h"
#import "HyBidSKAdNetworkParameter.h"
#import "HyBidAdExperienceManager.h"
#import <math.h>
#import <stdint.h>

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

static NSInteger const HyBidClickThroughTimerMinimum = 5;
static NSInteger const HyBidClickThroughTimerMaximum = 35;

static BOOL HyBidIsNonEmptyString(id value) {
    return [value isKindOfClass:[NSString class]] && [value length] > 0;
}

static NSArray<NSDictionary *> *HyBidValidSKANFidelities(id fidelities) {
    NSMutableArray<NSDictionary *> *result = [NSMutableArray new];
    if (![fidelities isKindOfClass:[NSArray class]]) {
        return result;
    }
    for (id value in fidelities) {
        if (![value isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *fidelity = value;
        if (HyBidIsNonEmptyString(fidelity[HyBidSKAdNetworkParameter.nonce]) &&
            HyBidIsNonEmptyString(fidelity[HyBidSKAdNetworkParameter.signature]) &&
            HyBidIsNonEmptyString(fidelity[HyBidSKAdNetworkParameter.timestamp]) &&
            [fidelity[HyBidSKAdNetworkParameter.fidelity] isKindOfClass:[NSNumber class]]) {
            [result addObject:[fidelity copy]];
        }
    }
    return result;
}

@interface HyBidAd ()

@property (nonatomic, strong)HyBidAdModel *data;
@property (nonatomic, strong)HyBidOpenRTBAdModel *openRTBData;
@property (nonatomic, strong)HyBidContentInfoView *contentInfoView;
@property (nonatomic, strong)NSString *_zoneID;
@property (nonatomic, readwrite)NSString *adFormat;

@end

@implementation HyBidAd

- (void)dealloc {
    self.data = nil;
    self.contentInfoView = nil;
    self._zoneID = nil;
    self.customEndCard = nil;
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
        if ([HyBidAdExperienceManager isBrandExperienceValue:data.text] || [HyBidAdExperienceManager isPerformanceExperienceValue:data.text]) {
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

- (NSNumber *)skOverlayEnabled {
    NSNumber *result = nil;
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
        return self.pcSKoverlayEnabled;
    } else {
        NSDictionary *jsonDictionary = [self jsonData];
        if (jsonDictionary) {
            if ([jsonDictionary objectForKey:PNLiteData.skOverlayEnabled] != (id)[NSNull null]) {
                result = [jsonDictionary objectForKey:PNLiteData.skOverlayEnabled];
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
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
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

- (NSNumber *)suppressAutoClick {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.suppressAutoClick] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.suppressAutoClick];
        }
    }
    return result;
}

- (NSNumber *)sdkAutoStorekitDelay {
    NSNumber *sdkAutoStorekitDelayInputValue = [self sdkAutoStorekitDelayInputValue];
    if (sdkAutoStorekitDelayInputValue) { return sdkAutoStorekitDelayInputValue; }
    
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitDelay] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitDelay];
        }
    }
    return result;
}

- (NSNumber *)sdkAutoStorekitDelayInputValue {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary && [jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitDelayInputValue] != (id)[NSNull null]) {
        result = [jsonDictionary objectForKey:PNLiteData.sdkAutoStorekitDelayInputValue];
    }
    return result;
}

- (NSNumber *)clickThroughTimer {
    NSString *key = PNLiteData.clickThroughTimer;
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
        key = PNLiteData.pcClickThroughTimer;
    } else if ([HyBidAdExperienceManager isBrandAd:self]) {
        key = PNLiteData.bcClickThroughTimer;
    }
    NSNumber *value = [self coercedNumberForRemoteConfigKey:key];
    if (value == nil) {
        return nil;
    }
    NSInteger seconds = value.integerValue;
    return @(MIN(MAX(seconds, HyBidClickThroughTimerMinimum), HyBidClickThroughTimerMaximum));
}

- (NSNumber *)endcardEnabled {
    NSNumber *result = nil;
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
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
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
        return self.pcEndcardCloseDelay;
    } else if ([HyBidAdExperienceManager isBrandAd:self]) {
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

// Matches Android's org.json read of numeric remote configs, `(int) Double.parseDouble(value)`:
// numeric strings are coerced, surrounding whitespace is tolerated, decimals truncate
// toward zero (so "0.9" yields 0, same as Android), and out-of-range values saturate
// at the 32-bit int bounds like Java's narrowing conversion. Non-numeric values
// return nil so callers fall back to the SDK default rather than misreading them as 0.
// Deliberate divergence: non-finite strings ("NaN", "Infinity") also fall back to the
// default — Java would narrow "NaN" to 0, making the ad instantly skippable (VMI-1705).
- (NSNumber *)coercedNumberForRemoteConfigKey:(NSString *)key {
    id value = [[self jsonData] objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSString *trimmed = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSScanner *scanner = [NSScanner scannerWithString:trimmed];
        double parsed = 0;
        if (trimmed.length > 0 && [scanner scanDouble:&parsed] && scanner.isAtEnd && isfinite(parsed)) {
            if (parsed >= INT32_MAX) { return @(INT32_MAX); }
            if (parsed <= INT32_MIN) { return @(INT32_MIN); }
            return [NSNumber numberWithInt:(int)parsed];
        }
    }
    return nil;
}

- (NSNumber *)interstitialHtmlSkipOffset {
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
        return self.pcInterstitialHtmlSkipOffset;
    } else {
        return [self coercedNumberForRemoteConfigKey:PNLiteData.interstitialHtmlSkipOffset];
    }
}

- (NSNumber *)pcInterstitialHtmlSkipOffset {
    return [self coercedNumberForRemoteConfigKey:PNLiteData.pcInterstitialHtmlSkipOffset];
}

- (NSNumber *)rewardedHtmlSkipOffset {
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
        return self.pcRewardedHtmlSkipOffset;
    } else {
        return [self coercedNumberForRemoteConfigKey:PNLiteData.rewardedHtmlSkipOffset];
    }
}

- (NSNumber *)pcRewardedHtmlSkipOffset {
    return [self coercedNumberForRemoteConfigKey:PNLiteData.pcRewardedHtmlSkipOffset];
}

- (NSNumber *)videoSkipOffset {
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
        return self.pcVideoSkipOffset;
    }  else if ([HyBidAdExperienceManager isBrandAd:self]) {
        return self.bcVideoSkipOffset;
    } else {
        return [self coercedNumberForRemoteConfigKey:PNLiteData.videoSkipOffset];
    }
}

- (NSNumber *)pcVideoSkipOffset {
    return [self coercedNumberForRemoteConfigKey:PNLiteData.pcVideoSkipOffset];
}

- (NSNumber *)bcVideoSkipOffset {
    return [self coercedNumberForRemoteConfigKey:PNLiteData.bcVideoSkipOffset];
}

- (NSNumber *)rewardedVideoSkipOffset {
    if ([HyBidAdExperienceManager isPerformanceAd:self]) {
        return self.pcRewardedVideoSkipOffset;
    } else if ([HyBidAdExperienceManager isBrandAd:self]) {
        return self.bcRewardedVideoSkipOffset;
    } else {
        return [self coercedNumberForRemoteConfigKey:PNLiteData.rewardedVideoSkipOffset];
    }
}

- (NSNumber *)pcRewardedVideoSkipOffset {
    return [self coercedNumberForRemoteConfigKey:PNLiteData.pcRewardedVideoSkipOffset];
}

- (NSNumber *)bcRewardedVideoSkipOffset {
    return [self coercedNumberForRemoteConfigKey:PNLiteData.bcRewardedVideoSkipOffset];
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
    NSNumber *customCtaEnabledInputValue = [self customCtaEnabledInputValue];
    if (customCtaEnabledInputValue) { return customCtaEnabledInputValue; }
    
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary) {
        if ([jsonDictionary objectForKey:PNLiteData.customCtaEnabled] != (id)[NSNull null]) {
            result = [jsonDictionary objectForKey:PNLiteData.customCtaEnabled];
        }
    }
    return result;
}

- (NSNumber *)customCtaEnabledInputValue {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary && [jsonDictionary objectForKey:PNLiteData.customCtaEnabledInputValue] != (id)[NSNull null]) {
        result = [jsonDictionary objectForKey:PNLiteData.customCtaEnabledInputValue];
    }
    return result;
}

- (NSNumber *)customCtaDelay {
    NSNumber *customCtaDelayInputValue = [self customCtaDelayInputValue];
    if (customCtaDelayInputValue) { return customCtaDelayInputValue; }
    
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary && [jsonDictionary objectForKey:PNLiteData.customCtaDelay] != (id)[NSNull null]) {
        result = [jsonDictionary objectForKey:PNLiteData.customCtaDelay];
    }
    return result;
}

- (NSNumber *)customCtaDelayInputValue {
    NSNumber *result = nil;
    NSDictionary *jsonDictionary = [self jsonData];
    if (jsonDictionary && [jsonDictionary objectForKey:PNLiteData.customCtaDelayInputValue] != (id)[NSNull null]) {
        result = [jsonDictionary objectForKey:PNLiteData.customCtaDelayInputValue];
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

    if (![HyBidAdExperienceManager hasBrandExperience:self] || ([self.assetGroupID intValue] != VAST_INTERSTITIAL && [self.assetGroupID intValue] != VAST_REWARDED)) {
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
        if ([data stringFieldWithKey:HyBidSKAdNetworkParameter.productPageId] != nil && [data stringFieldWithKey:HyBidSKAdNetworkParameter.productPageId].length > 0) {
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
        NSArray *fidelities = HyBidValidSKANFidelities(data.dictionary[HyBidSKAdNetworkParameter.skadn][HyBidSKAdNetworkParameter.fidelities]);
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && fidelities.count > 0) {
            [dict setObject:fidelities forKey:HyBidSKAdNetworkParameter.fidelities];
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
        NSArray *fidelities = HyBidValidSKANFidelities(data.dictionary[@"data"][HyBidSKAdNetworkParameter.fidelities]);
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && fidelities.count > 0) {
            [dict setObject:fidelities forKey:HyBidSKAdNetworkParameter.fidelities];
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

- (BOOL)isBrandCompatible {
    return [HyBidAdExperienceManager isBrandCompatible:self];
}

@end
