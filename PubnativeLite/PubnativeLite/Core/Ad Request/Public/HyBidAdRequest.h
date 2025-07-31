// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"
#import "HyBidIntegrationType.h"
#import "HyBidAdSize.h"

@class HyBidAdRequest;
@class PNLiteAdRequestModel;

typedef enum {
    HyBidOpenRTBAdNative,
    HyBidOpenRTBAdBanner,
    HyBidOpenRTBAdVideo
 } HyBidOpenRTBAdType;

@protocol HyBidAdRequestDelegate <NSObject>

- (void)requestDidStart:(HyBidAdRequest *)request;
- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad;
- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error;

@end

@interface HyBidAdRequest : NSObject

@property (nonatomic, strong) HyBidAdSize *adSize;
@property (nonatomic, assign) BOOL isRewarded;
@property (nonatomic, readonly) NSArray<NSString *> *supportedAPIFrameworks;
@property (nonatomic) HyBidOpenRTBAdType openRTBAdType;
@property (nonatomic, assign) BOOL isUsingOpenRTB;
@property (nonatomic, assign) BOOL isAutoCacheOnLoad;
@property (nonatomic, readonly) IntegrationType integrationType;
@property (nonatomic) NSObject <HyBidAdRequestDelegate> *delegate;
@property (nonatomic, assign) HyBidMarkupPlacement placement;
@property (nonatomic, strong) NSString *adFormat;

- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID;
- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken;
- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID;
- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken;
- (void)requestVideoTagFrom:(NSString *)url andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate;
- (NSURL*)requestURLFromAdRequestModel:(PNLiteAdRequestModel *)adRequestModel;
- (void)processCustomMarkupFrom:(NSString *)markup withPlacement:(HyBidMarkupPlacement)placement andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate;
- (void)cacheAd:(HyBidAd *)ad;
- (void)setMediationVendor:(NSString *)mediationVendor;
- (void)processResponseWithJSON:(NSString *)adReponse;
- (void)processVASTTagResponseFrom:(NSString *)vastAdContent;
- (void)processResponseWithData:(NSData *)data;
- (NSString *)getAdFormat;

@end
