// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidAd.h"
#import "HyBidAdRequest.h"
#import "HyBidAdPresenter.h"

@class HyBidAdView;

typedef enum {
    BANNER_POSITION_UNKNOWN,
    BANNER_POSITION_TOP,
    BANNER_POSITION_BOTTOM
} HyBidBannerPosition;

@protocol HyBidAdViewDelegate<NSObject>

- (void)adViewDidLoad:(HyBidAdView *)adView;
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error;
- (void)adViewDidTrackImpression:(HyBidAdView *)adView;
- (void)adViewDidTrackClick:(HyBidAdView *)adView;

@optional
- (void)adViewWillRefresh:(HyBidAdView *)adView;

@end

@interface HyBidAdView : UIView <HyBidAdRequestDelegate, HyBidAdPresenterDelegate>

@property (nonatomic, strong) HyBidAdRequest *adRequest;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, weak) NSObject <HyBidAdViewDelegate> *delegate;
@property (nonatomic, assign) BOOL isMediation;
@property (nonatomic, strong) HyBidAdSize *adSize;
@property (nonatomic, assign) BOOL autoShowOnLoad;
@property (nonatomic) HyBidBannerPosition bannerPosition;
@property (nonatomic, assign) BOOL isAutoCacheOnLoad;
@property (nonatomic) NSInteger autoRefreshTimeInSeconds;

- (instancetype)initWithSize:(HyBidAdSize *)adSize;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)loadExchangeAdWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)loadWithZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)loadWithZoneID:(NSString *)zoneID withPosition:(HyBidBannerPosition)bannerPosition andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)loadExchangeAdWithZoneID:(NSString *)zoneID withPosition:(HyBidBannerPosition)bannerPosition andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)setOpenRTBAdTypeWithAdFormat:(HyBidOpenRTBAdType)adFormat;
- (void)setupAdView:(UIView *)adView;
- (void)renderAd;
- (void)renderAdWithContent:(NSString *)adContent withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)renderAdWithAdResponse:(NSString *)adReponse withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)renderAdWithAdResponseOpenRTB:(NSString *)adReponse withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)startTracking;
- (void)stopTracking;
- (void)prepare;
- (void)prepareCustomMarkupFrom:(NSString *)markup withPlacement:(HyBidMarkupPlacement)placement;
- (void)show;
- (void)refresh;
- (void)stopAutoRefresh;
- (HyBidAdPresenter *)createAdPresenter;

- (void)setMediationVendor:(NSString *)mediationVendor;

@end
