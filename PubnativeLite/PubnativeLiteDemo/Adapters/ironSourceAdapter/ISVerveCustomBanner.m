// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "ISVerveCustomBanner.h"
#import "ISVerveUtils.h"

@interface ISVerveCustomBanner() <HyBidAdViewDelegate>

@property (nonatomic, strong) HyBidAdView *bannerAdView;
@property (nonatomic, weak) id <ISBannerAdDelegate> delegate;

@end

@implementation ISVerveCustomBanner

- (void)dealloc {
    self.bannerAdView = nil;
}

- (void)destroyAdWithAdData:(ISAdData *)adData {
    if (self.bannerAdView) {
        self.bannerAdView = nil;
    }
}

- (void)loadAdWithAdData:(ISAdData *)adData
          viewController:(UIViewController *)viewController
                    size:(ISBannerSize *)size
                delegate:(id<ISBannerAdDelegate>)delegate {
    if ([ISVerveUtils isZoneIDValid:adData]) {
        self.delegate = delegate;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.bannerAdView = [[HyBidAdView alloc] initWithSize:[weakSelf getHyBidAdSizeFrom:size]];
            weakSelf.bannerAdView.isMediation = YES;
            [weakSelf.bannerAdView setMediationVendor:[ISVerveUtils mediationVendor]];
            [weakSelf.bannerAdView loadWithZoneID:[ISVerveUtils zoneID:adData] andWithDelegate:weakSelf];
        });
    } else {
        NSString *errorMessage = @"Could not find the required params in ISVerveCustomBanner ad data.";
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

- (HyBidAdSize *)getHyBidAdSizeFrom:(ISBannerSize *)ironSourceAdSize {
    if (ironSourceAdSize == ISBannerSize_LARGE) {
        return HyBidAdSize.SIZE_320x100;
    } else if (ironSourceAdSize == ISBannerSize_RECTANGLE) {
        return HyBidAdSize.SIZE_300x250;
    } else if (ironSourceAdSize == ISBannerSize_SMART) {
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad){
            return HyBidAdSize.SIZE_728x90;
        } else {
            return HyBidAdSize.SIZE_320x50;
        }
    } else {
        return HyBidAdSize.SIZE_320x50;
    }
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidLoadWithView:)])
        [self.delegate adDidLoadWithView:adView];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class])
                            fromMethod:NSStringFromSelector(_cmd)
                           withMessage:error.localizedDescription];
        [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeNoFill
                                          errorCode:ISAdapterErrorInternal
                                       errorMessage:error.localizedDescription];
    }
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidOpen)]) {
        [self.delegate adDidOpen];
    }
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidClick)]) {
        [self.delegate adDidClick];
    }
}

@end
