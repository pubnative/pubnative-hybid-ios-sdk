// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGADInterstitialCustomEvent.h"
#import "HyBidGADUtils.h"

typedef id<GADMediationInterstitialAdEventDelegate> _Nullable(^HyBidGADInterstitialCustomEventCompletionBlock)(_Nullable id<GADMediationInterstitialAd> ad,
                                                                                                                  NSError *_Nullable error);

@interface HyBidGADInterstitialCustomEvent() <HyBidInterstitialAdDelegate, GADMediationInterstitialAd>

@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property(nonatomic, weak, nullable) id<GADMediationInterstitialAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADInterstitialCustomEventCompletionBlock completionBlock;

@end

@implementation HyBidGADInterstitialCustomEvent

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGADUtils areExtrasValid:serverParameter] && [HyBidGADUtils appToken:serverParameter] != nil) {
        if (HyBid.isInitialized && [[HyBidGADUtils appToken:serverParameter] isEqualToString:[HyBidSDKConfig sharedConfig].appToken]) {
            [self loadInterstitialWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
        } else {
            [HyBid initWithAppToken:[HyBidGADUtils appToken:serverParameter] completion:^(BOOL success) {
                [self loadInterstitialWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
            }];
        }
    } else {
        [self invokeFailWithMessage:@"Failed interstitial ad fetch. Missing required server extras."];
        return;
    }
}

- (void)loadInterstitialWithZoneID:(NSString *)zoneID {
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:zoneID andWithDelegate:self];
    self.interstitialAd.isMediation = YES;
    [self.interstitialAd load];
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    if (self.interstitialAd.isReady) {
        [self.delegate willPresentFullScreenView];
        if ([self.interstitialAd respondsToSelector:@selector(showFromViewController:)]) {
            [self.interstitialAd showFromViewController:viewController];
        } else {
            [self.interstitialAd show];
        }
    } else {
        [self.delegate didFailToPresentWithError:[NSError errorWithDomain:@"Ad is not ready... Please wait." code:0 userInfo:nil]];
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    self.delegate = self.completionBlock(self, nil);
}

- (void)interstitialDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)interstitialDidTrackClick {
    [self.delegate reportClick];
}

- (void)interstitialDidTrackImpression {
    [self.delegate reportImpression];
}

- (void)interstitialDidDismiss {
    [self.delegate willDismissFullScreenView];
    [self.delegate didDismissFullScreenView];
}

@end
