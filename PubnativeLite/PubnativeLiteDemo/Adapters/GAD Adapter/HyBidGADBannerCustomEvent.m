// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGADBannerCustomEvent.h"
#import "HyBidGADUtils.h"

typedef id<GADMediationBannerAdEventDelegate> _Nullable(^HyBidGADBannerCustomEventCompletionBlock)(_Nullable id<GADMediationBannerAd> ad,
                                                                                                                  NSError *_Nullable error);
@interface HyBidGADBannerCustomEvent() <HyBidAdViewDelegate, GADMediationBannerAd>

@property (nonatomic, strong) HyBidAdView *bannerAdView;
@property(nonatomic, weak, nullable) id<GADMediationBannerAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADBannerCustomEventCompletionBlock completionBlock;

@end

@implementation HyBidGADBannerCustomEvent

- (void)dealloc {
    self.bannerAdView = nil;
    self.adSize = nil;
}

- (UIView *)view {
    return self.bannerAdView;
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGADUtils areExtrasValid:serverParameter] && [HyBidGADUtils appToken:serverParameter] != nil) {
        if (HyBid.isInitialized && [[HyBidGADUtils appToken:serverParameter] isEqualToString:[HyBidSDKConfig sharedConfig].appToken]) {
            [self loadBannerWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
        } else {
            [HyBid initWithAppToken:[HyBidGADUtils appToken:serverParameter] completion:^(BOOL success) {
                [self loadBannerWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
            }];
        }
    } else {
        [self invokeFailWithMessage:@"Failed banner ad fetch. Missing required server extras."];
        return;
    }
}

- (void)loadBannerWithZoneID:(NSString *)zoneID {
    self.bannerAdView = [[HyBidAdView alloc] initWithSize:self.adSize];
    self.bannerAdView.isMediation = YES;
    [self.bannerAdView loadWithZoneID:zoneID andWithDelegate:self];
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

- (HyBidAdSize *)adSize {
    return HyBidAdSize.SIZE_320x50;
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    self.delegate = self.completionBlock(self, nil);
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    [self.delegate reportImpression];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    [self.delegate reportClick];
}

@end
