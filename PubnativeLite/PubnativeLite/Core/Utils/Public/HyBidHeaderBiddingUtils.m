// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidHeaderBiddingUtils.h"

NSString *const PNLiteKeyPN_BID = @"pn_bid";
double const kECPMPointsDivider = 1000.0;

@implementation HyBidHeaderBiddingUtils

+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad {
    return [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsStringWithAd:ad withZoneID:nil];
}

+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad withZoneID:(NSString *)zoneID {
    return [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsStringWithAd:ad withKeywordMode:THREE_DECIMAL_PLACES];
}

+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad withKeywordMode:(HyBidKeywordMode)keywordMode {
    NSMutableString *prebidString = [[NSMutableString alloc] init];
    [prebidString appendString:PNLiteKeyPN_BID];
    [prebidString appendString:@":"];
    [prebidString appendString:[HyBidHeaderBiddingUtils eCPMFromAd:ad withDecimalPlaces:keywordMode]];
    
    return [NSString stringWithString:prebidString];
}

+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad {
    return [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad withZoneID:nil];
}

+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad withZoneID:(NSString *)zoneID {
    return [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad withKeywordMode:THREE_DECIMAL_PLACES];
}

+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad withKeywordMode:(HyBidKeywordMode)keywordMode {
    NSMutableDictionary *prebidDictionary = [NSMutableDictionary dictionary];
    [prebidDictionary setValue:[HyBidHeaderBiddingUtils eCPMFromAd:ad withDecimalPlaces:keywordMode] forKey:PNLiteKeyPN_BID];
    return prebidDictionary;
}


+ (NSString *)eCPMFromAd:(HyBidAd *)ad withDecimalPlaces:(HyBidKeywordMode)decimalPlaces {
    if (decimalPlaces == TWO_DECIMAL_PLACES) {
        return [NSString stringWithFormat:@"%.2f", [ad.eCPM doubleValue]/kECPMPointsDivider];
    } else {
        return [NSString stringWithFormat:@"%.3f", [ad.eCPM doubleValue]/kECPMPointsDivider];
    }
}

@end
