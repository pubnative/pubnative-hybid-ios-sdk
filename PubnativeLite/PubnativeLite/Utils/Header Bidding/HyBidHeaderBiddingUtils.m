//
//  Copyright © 2020 PubNative. All rights reserved.
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
