// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidNativeAd.h"

@protocol HyBidNativeAdLoaderDelegate<NSObject>

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd;
- (void)nativeLoaderDidFailWithError:(NSError *)error;

@optional
- (void)nativeLoaderWillRefresh;

@end

@interface HyBidNativeAdLoader : NSObject

@property (nonatomic, assign) BOOL isMediation;
@property (nonatomic) NSInteger autoRefreshTimeInSeconds;

- (void)loadNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID;
- (void)loadNativeExchangeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID;
- (void)loadNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken;
- (void)refresh;
- (void)stopAutoRefresh;
- (void)prepareNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withContent:(NSString *)adContent;

@end
