// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

typedef enum {
    TWO_DECIMAL_PLACES,
    THREE_DECIMAL_PLACES,
} HyBidKeywordMode;

@interface HyBidHeaderBiddingUtils : NSObject

+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad;
+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad withZoneID:(NSString *)zoneID;
+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad withKeywordMode:(HyBidKeywordMode)keywordMode;

+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad;
+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad withZoneID:(NSString *)zoneID;
+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad withKeywordMode:(HyBidKeywordMode)keywordMode;

@end
