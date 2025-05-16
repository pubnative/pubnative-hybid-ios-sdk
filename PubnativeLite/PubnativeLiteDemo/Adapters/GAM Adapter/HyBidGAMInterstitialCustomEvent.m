// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGAMInterstitialCustomEvent.h"
#import "HyBidGAMUtils.h"

typedef id<GADMediationInterstitialAdEventDelegate> _Nullable(^HyBidGADInterstitialCustomEventCompletionBlock)(_Nullable id<GADMediationInterstitialAd> ad,
                                                                                                                  NSError *_Nullable error);
@interface HyBidGAMInterstitialCustomEvent () <HyBidInterstitialPresenterDelegate, GADMediationInterstitialAd>

@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidInterstitialPresenterFactory *interstitalPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;
@property(nonatomic, weak, nullable) id<GADMediationInterstitialAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADInterstitialCustomEventCompletionBlock completionBlock;

@end

@implementation HyBidGAMInterstitialCustomEvent

- (void)dealloc {
    self.interstitialPresenter = nil;
    self.interstitalPresenterFactory = nil;
    self.ad = nil;
}

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGAMUtils areExtrasValid:serverParameter]) {
        self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidGAMUtils zoneID:serverParameter]];
        if (!self.ad) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"Could not find an ad in the cache for zone id with key: %@", [HyBidGAMUtils zoneID:serverParameter]]];
            return;
        }
        self.interstitalPresenterFactory = [[HyBidInterstitialPresenterFactory alloc] init];
        
        HyBidSkipOffset *videoSkipOffset = nil;
        HyBidSkipOffset *htmlSkipOffset = nil;
        
        if (self.ad.interstitialHtmlSkipOffset){
            htmlSkipOffset = [[HyBidSkipOffset alloc] initWithOffset:self.ad.interstitialHtmlSkipOffset isCustom:YES];
        } else {
            htmlSkipOffset = HyBidConstants.interstitialHtmlSkipOffset;
        }
        
        if (self.ad.videoSkipOffset){
            videoSkipOffset = [[HyBidSkipOffset alloc] initWithOffset:self.ad.videoSkipOffset isCustom:YES];
        } else {
            videoSkipOffset = HyBidConstants.videoSkipOffset;
        }
        
        BOOL closeOnFinish;
        if (self.ad.closeInterstitialAfterFinish) {
            closeOnFinish = self.ad.closeInterstitialAfterFinish;
        } else {
            closeOnFinish = HyBidConstants.interstitialCloseOnFinish;
        }
        
        self.interstitialPresenter = [self.interstitalPresenterFactory createInterstitalPresenterWithAd:self.ad
                                                                                    withVideoSkipOffset:videoSkipOffset
                                                                                     withHTMLSkipOffset:htmlSkipOffset.offset.integerValue
                                                                                      withCloseOnFinish:closeOnFinish
                                                                                           withDelegate:self];
        if (!self.interstitialPresenter) {
            [self invokeFailWithMessage:@"Could not create valid interstitial presenter."];
            return;
        } else {
            [self.interstitialPresenter load];
        }
    } else {
        [self invokeFailWithMessage:@"Failed interstitial ad fetch. Missing required server extras."];
        return;
    }
}

- (void)presentFromViewController:(UIViewController *)viewController {
    [self.delegate willPresentFullScreenView];
    if ([self.interstitialPresenter respondsToSelector:@selector(showFromViewController:)]) {
        if ([self.interstitialPresenter respondsToSelector:@selector(showFromViewController:)]) {
            [self.interstitialPresenter showFromViewController:viewController];
        } else {
            [self.interstitialPresenter show];
        }
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    self.delegate = self.completionBlock(self, nil);
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate reportImpression];
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate reportClick];
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate willDismissFullScreenView];
    [self.delegate didDismissFullScreenView];
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)interstitialPresenterDidAppear:(HyBidInterstitialPresenter *)interstitialPresenter {
    
}

- (void)interstitialPresenterDidDisappear:(HyBidInterstitialPresenter *)interstitialPresenter {
    
}

@end
