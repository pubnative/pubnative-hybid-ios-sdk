// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "ISVerveCustomRewardedVideo.h"
#import "ISVerveUtils.h"

@interface ISVerveCustomRewardedVideo() <HyBidRewardedAdDelegate>

@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (nonatomic, weak) id <ISRewardedVideoAdDelegate> delegate;

@end

@implementation ISVerveCustomRewardedVideo

- (void)dealloc {
    self.rewardedAd = nil;
}

- (void)loadAdWithAdData:(ISAdData *)adData delegate:(id<ISRewardedVideoAdDelegate>)delegate {
    if ([ISVerveUtils isZoneIDValid:adData]) {
        self.delegate = delegate;
        self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[ISVerveUtils zoneID:adData] andWithDelegate:self];
        self.rewardedAd.isMediation = YES;
        [self.rewardedAd setMediationVendor:[ISVerveUtils mediationVendor]];
        [self.rewardedAd load];
    } else {
        NSString *errorMessage = @"Could not find the required params in ISVerveCustomRewardedVideo ad data.";
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
    if (self.rewardedAd) {
        return self.rewardedAd.isReady;
    } else {
        return NO;
    }
}

- (void)showAdWithViewController:(UIViewController *)viewController
                          adData:(ISAdData *)adData
                        delegate:(id<ISRewardedVideoAdDelegate>)delegate {
    if (self.rewardedAd) {
        if ([self.rewardedAd respondsToSelector:@selector(showFromViewController:)]) {
            [self.rewardedAd showFromViewController:viewController];
        } else {
            [self.rewardedAd show];
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

#pragma mark - HyBidRewardedAdDelegate

- (void)rewardedDidLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidLoad)]) {
        [self.delegate adDidLoad];
    }
}

- (void)rewardedDidFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class])
                            fromMethod:NSStringFromSelector(_cmd)
                           withMessage:error.localizedDescription];
        [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeNoFill
                                          errorCode:ISAdapterErrorInternal
                                       errorMessage:error.localizedDescription];
    }
}

- (void)rewardedDidTrackClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidClick)]) {
        [self.delegate adDidClick];
    }
}

- (void)rewardedDidTrackImpression {
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
        if ([self.delegate respondsToSelector:@selector(adDidStart)]) {
            [self.delegate adDidStart];
        }
    }
}

- (void)rewardedDidDismiss {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(adDidClose)]) {
            [self.delegate adDidClose];
        }
        if ([self.delegate respondsToSelector:@selector(adDidEnd)]) {
            [self.delegate adDidEnd];
        }
    }
}

- (void)onReward {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adRewarded)]) {
        [self.delegate adRewarded];
    }
}

@end
