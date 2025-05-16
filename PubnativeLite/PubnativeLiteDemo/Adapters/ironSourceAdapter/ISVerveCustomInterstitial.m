// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "ISVerveCustomInterstitial.h"
#import "ISVerveUtils.h"

@interface ISVerveCustomInterstitial() <HyBidInterstitialAdDelegate>

@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, weak) id <ISInterstitialAdDelegate> delegate;

@end

@implementation ISVerveCustomInterstitial

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)loadAdWithAdData:(ISAdData *)adData delegate:(id<ISInterstitialAdDelegate>)delegate {
    if ([ISVerveUtils isZoneIDValid:adData]) {
        self.delegate = delegate;
        self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:[ISVerveUtils zoneID:adData] andWithDelegate:self];
        self.interstitialAd.isMediation = YES;
        [self.interstitialAd setMediationVendor:[ISVerveUtils mediationVendor]];
        [self.interstitialAd load];
    } else {
        NSString *errorMessage = @"Could not find the required params in ISVerveCustomInterstitial ad data.";
        if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class])
                                fromMethod:NSStringFromSelector(_cmd)
                               withMessage:errorMessage];
            [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                              errorCode:ISAdapterErrorMissingParams
                                           errorMessage:errorMessage];
        }
    }
}

- (BOOL)isAdAvailableWithAdData:(ISAdData *)adData {
    if (self.interstitialAd) {
        return self.interstitialAd.isReady;
    } else {
        return NO;
    }
}

- (void)showAdWithViewController:(UIViewController *)viewController
                          adData:(ISAdData *)adData
                        delegate:(id<ISInterstitialAdDelegate>)delegate {
    if (self.interstitialAd) {
        if ([self.interstitialAd respondsToSelector:@selector(showFromViewController:)]) {
            [self.interstitialAd showFromViewController:viewController];
        } else {
            [self.interstitialAd show];
        }
    } else {
        NSString *errorMessage = @"Error when showing the ad.";
        if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToShowWithErrorCode:errorMessage:)]) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class])
                                fromMethod:NSStringFromSelector(_cmd)
                               withMessage:errorMessage];
            [self.delegate adDidFailToShowWithErrorCode:ISAdapterErrorInternal errorMessage:errorMessage];
        }
    }
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidLoad)]) {
        [self.delegate adDidLoad];
    }
}

- (void)interstitialDidFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class])
                            fromMethod:NSStringFromSelector(_cmd)
                           withMessage:error.localizedDescription];
        [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeNoFill
                                          errorCode:ISAdapterErrorInternal
                                       errorMessage:error.localizedDescription];
    }
}

- (void)interstitialDidTrackClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidClick)]) {
        [self.delegate adDidClick];
    }
}

- (void)interstitialDidTrackImpression {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(adDidOpen)]) {
            [self.delegate adDidOpen];
        }
        if ([self.delegate respondsToSelector:@selector(adDidShowSucceed)]) {
            [self.delegate adDidShowSucceed];
        }
        if ([self.delegate respondsToSelector:@selector(adDidBecomeVisible)]) {
            [self.delegate adDidBecomeVisible];
        }
    }
}

- (void)interstitialDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidClose)]) {
        [self.delegate adDidClose];
    }
}

@end
