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

#import "ISVerveCustomInterstitial.h"
#import "ISVerveUtils.h"
#import "ISVerveCustomAdapter.h"

@interface ISVerveCustomInterstitial() <HyBidInterstitialAdDelegate>

@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, weak) id <ISAdapterAdDelegate> delegate;

@end

@implementation ISVerveCustomInterstitial

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)loadAdWithAdData:(ISAdData *)adData delegate:(id<ISAdapterAdDelegate>)delegate {
    if ([ISVerveUtils isAppTokenValid:adData] && [ISVerveUtils isZoneIDValid:adData]) {
        if ([ISVerveUtils appToken:adData] != nil && [[ISVerveUtils appToken:adData] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.delegate = delegate;
            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:[ISVerveUtils zoneID:adData] andWithDelegate:self];
            self.interstitialAd.isMediation = YES;
            [self.interstitialAd setMediationVendor:ISVerveCustomAdapter.ISVerveAdapterKeyMediationVendor];
            [self.interstitialAd load];
        } else {
            NSString *errorMessage = @"The provided app token doesn't match the one used to initialise HyBid.";
            if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:errorMessage];
                [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                                  errorCode:ISAdapterErrorMissingParams
                                               errorMessage:errorMessage];
            }
        }
    } else {
        NSString *errorMessage = @"Could not find the required params in ISVerveCustomInterstitial ad data.";
        if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToLoadWithErrorType:errorCode:errorMessage:)]) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:errorMessage];
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
                        delegate:(id<ISAdapterAdDelegate>)delegate {
    if (self.interstitialAd) {
        if ([self.interstitialAd respondsToSelector:@selector(showFromViewController:)]) {
            [self.interstitialAd showFromViewController:viewController];
        } else {
            [self.interstitialAd show];
        }
    } else {
        NSString *errorMessage = @"Error when showing the ad.";
        if (self.delegate && [self.delegate respondsToSelector:@selector(adDidFailToShowWithErrorCode:errorMessage:)]) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:errorMessage];
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
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
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
    }
}

- (void)interstitialDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adDidClose)]) {
        [self.delegate adDidClose];
    }
}

@end
