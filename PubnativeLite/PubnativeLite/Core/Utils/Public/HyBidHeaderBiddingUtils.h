// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

typedef NS_ENUM(NSInteger, HyBidKeywordMode) {
    TWO_DECIMAL_PLACES,
    THREE_DECIMAL_PLACES
};

@interface HyBidHeaderBiddingUtils : NSObject

+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad;
+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad withZoneID:(NSString *)zoneID;
+ (NSString *)createHeaderBiddingKeywordsStringWithAd:(HyBidAd *)ad withKeywordMode:(HyBidKeywordMode)keywordMode;

+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad;
+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad withZoneID:(NSString *)zoneID;
+ (NSMutableDictionary *)createHeaderBiddingKeywordsDictionaryWithAd:(HyBidAd *)ad withKeywordMode:(HyBidKeywordMode)keywordMode;
+ (NSString *)eCPMFromAd:(HyBidAd *)ad withDecimalPlaces:(HyBidKeywordMode)decimalPlaces;

@end
