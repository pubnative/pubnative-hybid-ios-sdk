//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdExperienceManager.h"
#import "HyBidAd.h"
#import "HyBid.h"

@implementation HyBidAdExperienceManager

+ (BOOL)isBrandExperienceValue:(NSString *)adExperience {
    return [adExperience isEqualToString:HyBidAdExperienceBrandValue];
}

+ (BOOL)isPerformanceExperienceValue:(NSString *)adExperience {
    return [adExperience isEqualToString:HyBidAdExperiencePerformanceValue];
}

+ (BOOL)hasBrandExperience:(HyBidAd *)ad {
    return [self isBrandExperienceValue:ad.adExperience];
}

+ (BOOL)hasPerformanceExperience:(HyBidAd *)ad {
    return [self isPerformanceExperienceValue:ad.adExperience];
}

// The brand and performance compatibility sets are currently identical
// (pre-existing state, recorded in VMI-1686). They are kept as separate
// methods so eligibility can diverge per experience without touching call sites.
+ (BOOL)isBrandCompatible:(HyBidAd *)ad {
    return [self isCompatibleAssetGroupID:ad.assetGroupID];
}

+ (BOOL)isPerformanceCompatible:(HyBidAd *)ad {
    return [self isCompatibleAssetGroupID:ad.assetGroupID];
}

+ (BOOL)isCompatibleAssetGroupID:(NSNumber *)assetGroupID {
    int assetGroupIDValue = [assetGroupID intValue];
    return assetGroupIDValue == VAST_INTERSTITIAL ||
           assetGroupIDValue == MRAID_320x480 ||
           assetGroupIDValue == MRAID_480x320 ||
           assetGroupIDValue == MRAID_768x1024 ||
           assetGroupIDValue == MRAID_1024x768 ||
           assetGroupIDValue == MRAID_300x600;
}

+ (BOOL)isBrandAd:(HyBidAd *)ad {
    return [self hasBrandExperience:ad] && [self isBrandCompatible:ad];
}

+ (BOOL)isPerformanceAd:(HyBidAd *)ad {
    return [self hasPerformanceExperience:ad] && [self isPerformanceCompatible:ad];
}

@end
