// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGAMBannerCustomEvent.h"
#import "HyBidGAMUtils.h"

typedef id<GADMediationBannerAdEventDelegate> _Nullable(^HyBidGADBannerCustomEventCompletionBlock)(_Nullable id<GADMediationBannerAd> ad,
                                                                                                                  NSError *_Nullable error);
@interface HyBidGAMBannerCustomEvent () <HyBidAdPresenterDelegate, GADMediationBannerAd>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidBannerPresenterFactory *bannerPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) UIView *adView;
@property(nonatomic, weak, nullable) id<GADMediationBannerAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADBannerCustomEventCompletionBlock completionBlock;

@end

@implementation HyBidGAMBannerCustomEvent

- (void)dealloc {
    self.adPresenter = nil;
    self.bannerPresenterFactory = nil;
    self.ad = nil;
    self.adView = nil;
}

- (UIView *)view {
    return self.adView;
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGAMUtils areExtrasValid:serverParameter]) {
        self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidGAMUtils zoneID:serverParameter]];
        if (!self.ad) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"Could not find an ad in the cache for zone id with key: %@", [HyBidGAMUtils zoneID:serverParameter]]];
            return;
        }
        self.bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
        self.adPresenter = [self.bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
        if (!self.adPresenter) {
            [self invokeFailWithMessage:@"Could not create valid banner presenter."];
            return;
        } else {
            [self.adPresenter load];
        }
        
    } else {
        [self invokeFailWithMessage:@"Failed banner ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    self.adView = adView;
    self.delegate = self.completionBlock(self, nil);
    [self.delegate reportImpression];
    [self.adPresenter startTracking];
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    [self.delegate reportClick];
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter {
    
}

- (void)adPresenterDidAppear:(HyBidAdPresenter *)adPresenter {
    
}

- (void)adPresenterDidDisappear:(HyBidAdPresenter *)adPresenter {
    
}

@end
