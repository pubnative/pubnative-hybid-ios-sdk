//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    if ([ISVerveUtils isAppTokenValid:adData] && [ISVerveUtils isZoneIDValid:adData]) {
        if ([ISVerveUtils appToken:adData] != nil && [[ISVerveUtils appToken:adData] isEqualToString:[HyBidSDKConfig sharedConfig].appToken]) {
            self.delegate = delegate;
            self.bannerAdView = [[HyBidAdView alloc] initWithSize:[self getHyBidAdSizeFrom:size]];
            self.bannerAdView.isMediation = YES;
            [self.bannerAdView setMediationVendor:[ISVerveUtils mediationVendor]];
            [self.bannerAdView loadWithZoneID:[ISVerveUtils zoneID:adData] andWithDelegate:self];
        } else {
            NSString *errorMessage = @"The provided app token doesn't match the one used to initialise HyBid.";
            if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class])
                                    fromMethod:NSStringFromSelector(_cmd)
                                   withMessage:errorMessage];
                [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                                  errorCode:ISAdapterErrorMissingParams
                                               errorMessage:errorMessage];
            }
        }
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
