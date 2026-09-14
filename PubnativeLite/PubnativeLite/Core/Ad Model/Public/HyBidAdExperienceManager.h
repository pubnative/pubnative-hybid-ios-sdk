//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@class HyBidAd;

@interface HyBidAdExperienceManager : NSObject

+ (BOOL)isBrandExperienceValue:(nullable NSString *)adExperience;
+ (BOOL)isPerformanceExperienceValue:(nullable NSString *)adExperience;

+ (BOOL)hasBrandExperience:(nullable HyBidAd *)ad;
+ (BOOL)hasPerformanceExperience:(nullable HyBidAd *)ad;

+ (BOOL)isBrandCompatible:(nullable HyBidAd *)ad;
+ (BOOL)isPerformanceCompatible:(nullable HyBidAd *)ad;

+ (BOOL)isBrandAd:(nullable HyBidAd *)ad;
+ (BOOL)isPerformanceAd:(nullable HyBidAd *)ad;

@end
