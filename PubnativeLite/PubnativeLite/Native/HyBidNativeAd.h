// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HyBidAd.h"
#import "HyBidNativeAdRenderer.h"
#import "HyBidContentInfoView.h"
#import "HyBidSkAdNetworkModel.h"

@class HyBidNativeAd;
@class HyBidAdSessionData;

@protocol HyBidNativeAdDelegate <NSObject>

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view;
- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd;

@end

@protocol HyBidNativeAdFetchDelegate <NSObject>

- (void)nativeAdDidFinishFetching:(HyBidNativeAd *)nativeAd;
- (void)nativeAd:(HyBidNativeAd *)nativeAd didFailFetchingWithError:(NSError *)error;

@end

@interface HyBidNativeAd : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *callToActionTitle;
@property (nonatomic, readonly) NSString *iconUrl;
@property (nonatomic, readonly) NSString *bannerUrl;
@property (nonatomic, readonly) NSString *clickUrl;
@property (nonatomic, readonly) NSNumber *rating;
@property (nonatomic, readonly) UIView *banner;
@property (nonatomic, readonly) UIImage *bannerImage;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, readonly) HyBidContentInfoView *contentInfo;
@property (nonatomic, strong) HyBidAdSessionData *adSessionData;

- (instancetype)initWithAd:(HyBidAd *)ad;
- (void)renderAd:(HyBidNativeAdRenderer *)renderer;
- (void)fetchNativeAdAssetsWithDelegate:(NSObject<HyBidNativeAdFetchDelegate> *)delegate;
- (void)startTrackingView:(UIView *)view withDelegate:(NSObject<HyBidNativeAdDelegate> *)delegate;
- (void)stopTracking;

@end
