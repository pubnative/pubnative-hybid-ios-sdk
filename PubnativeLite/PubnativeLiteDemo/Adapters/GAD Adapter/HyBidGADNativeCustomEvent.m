// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGADNativeCustomEvent.h"
#import "HyBidGADUtils.h"

typedef id<GADMediationNativeAdEventDelegate> _Nullable(^HyBidGADNativeCustomEventCompletionBlock)(_Nullable id<GADMediationNativeAd> ad,
                                                                                                                  NSError *_Nullable error);
@interface HyBidGADNativeCustomEvent() <HyBidNativeAdLoaderDelegate, HyBidNativeAdFetchDelegate, HyBidNativeAdDelegate, GADMediationNativeAd>

@property (nonatomic, strong) HyBidNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) GADNativeAdViewAdOptions *nativeAdViewAdOptions;
@property(nonatomic, weak, nullable) id<GADMediationNativeAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADNativeCustomEventCompletionBlock completionBlock;
@property(nonatomic, strong) HyBidNativeAd *nativeAd;

@end

@implementation HyBidGADNativeCustomEvent

@synthesize advertiser, extraAssets, store, price;

- (void)dealloc {
    self.nativeAdLoader = nil;
    self.nativeAdViewAdOptions = nil;
}

- (void)loadNativeAdForAdConfiguration:(GADMediationNativeAdConfiguration *)adConfiguration
                     completionHandler:(GADMediationNativeLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGADUtils areExtrasValid:serverParameter] && [HyBidGADUtils appToken:serverParameter] != nil) {
        if (HyBid.isInitialized && [[HyBidGADUtils appToken:serverParameter] isEqualToString:[HyBidSDKConfig sharedConfig].appToken]) {
            [self loadNativeAdWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
        } else {
            [HyBid initWithAppToken:[HyBidGADUtils appToken:serverParameter] completion:^(BOOL success) {
                [self loadNativeAdWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
            }];
        }
    } else {
        [self invokeFailWithMessage:@"Failed native ad fetch. Missing required server extras."];
        return;
    }
}

- (void)loadNativeAdWithZoneID:(NSString *)zoneID {
    self.nativeAdLoader = [[HyBidNativeAdLoader alloc] init];
    self.nativeAdLoader.isMediation = YES;
    [self.nativeAdLoader loadNativeAdWithDelegate:self withZoneID:zoneID];
}

- (BOOL)handlesUserClicks {
  return YES;
}

- (BOOL)handlesUserImpressions {
  return YES;
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidNativeAdLoaderDelegate

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd {
    [nativeAd fetchNativeAdAssetsWithDelegate:self];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

#pragma mark - HyBidNativeAdFetchDelegate

- (void)nativeAdDidFinishFetching:(HyBidNativeAd *)nativeAd {
    self.delegate = self.completionBlock(self, nil);
    self.nativeAd = nativeAd;
}

- (void)nativeAd:(HyBidNativeAd *)nativeAd didFailFetchingWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

#pragma mark - GADMediationNativeAd

- (NSString *)headline {
    return self.nativeAd.title;
}

- (NSString *)body {
    return self.nativeAd.body;
}

- (NSString *)callToAction {
    return self.nativeAd.callToActionTitle;
}

- (NSDecimalNumber *)starRating {
    return [NSDecimalNumber decimalNumberWithDecimal:[self.nativeAd.rating decimalValue]];
}

- (GADNativeAdImage *)icon {
    return [[GADNativeAdImage alloc] initWithImage:self.nativeAd.icon];
}

- (NSArray *)images {
  return @[ [[GADNativeAdImage alloc] initWithImage:self.nativeAd.bannerImage] ];
}

- (UIView *)adChoicesView {
    return self.nativeAd.contentInfo;
}

- (void)didRenderInView:(UIView *)view clickableAssetViews:(NSDictionary<GADNativeAssetIdentifier,UIView *> *)clickableAssetViews nonclickableAssetViews:(NSDictionary<GADNativeAssetIdentifier,UIView *> *)nonclickableAssetViews viewController:(UIViewController *)viewController {
    [self.nativeAd startTrackingView:view withDelegate:self];
}

- (void)didUntrackView:(UIView *)view {
    [self.nativeAd stopTracking];
}

- (UIView *)mediaView {
    return self.nativeAd.banner;
}

#pragma mark - HyBidNativeAdDelegate

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view {
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:self];
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd {
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self];
}

@end
