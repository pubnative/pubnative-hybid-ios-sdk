//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "HyBidMoPubHeaderBiddingInterstitialCustomEvent.h"
#import "HyBidMoPubUtils.h"
#import "MPLogging.h"
#import "MPError.h"

@interface HyBidMoPubHeaderBiddingInterstitialCustomEvent () <HyBidInterstitialPresenterDelegate>

@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidInterstitialPresenterFactory *interstitalPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidMoPubHeaderBiddingInterstitialCustomEvent

- (void)dealloc {
    self.interstitialPresenter = nil;
    self.interstitalPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if ([HyBidMoPubUtils isZoneIDValid:info]) {
        self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidMoPubUtils zoneID:info]];
        if (!self.ad) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"Could not find an ad in the cache for zone id with key: %@", [HyBidMoPubUtils zoneID:info]]];
            return;
        }
        self.interstitalPresenterFactory = [[HyBidInterstitialPresenterFactory alloc] init];
        self.interstitialPresenter = [self.interstitalPresenterFactory createInterstitalPresenterWithAd:self.ad withDelegate:self];
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

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [self.delegate interstitialCustomEventWillAppear:self];
    if ([self.interstitialPresenter respondsToSelector:@selector(showFromViewController:)]) {
        [self.interstitialPresenter showFromViewController:rootViewController];
    } else {
        [self.interstitialPresenter show];
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogError(@"%@", message);
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                             code:0
                                                                                         userInfo:nil]];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate trackImpression];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate trackClick];
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

@end
