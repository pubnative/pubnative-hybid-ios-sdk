// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
#import <StoreKit/SKAdImpression.h>
#endif

#import <StoreKit/SKAdNetwork.h>
#import "HyBidAd.h"

@interface HyBidAdImpression : NSObject

+ (HyBidAdImpression *)sharedInstance;
- (void)startSKANImpressionForAd:(HyBidAd *)ad;
- (void)endSKANImpressionForAd:(HyBidAd *)ad;
- (void)startAAKImpressionForAd:(HyBidAd *)ad adFormat:(NSString *)adFormat;
- (void)endAAKImpressionForAd:(HyBidAd *)ad adFormat:(NSString *)adFormat;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
- (SKAdImpression *)generateSkAdImpressionFrom:(HyBidSkAdNetworkModel *)model API_AVAILABLE(ios(14.5));
#endif

@end
