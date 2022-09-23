//
//  Copyright © 2020 PubNative. All rights reserved.
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
        self.interstitialPresenter = [self.interstitalPresenterFactory createInterstitalPresenterWithAd:self.ad
                                                                                    withVideoSkipOffset:[HyBidSettings sharedInstance].videoSkipOffset.offset.integerValue
                                                                                     withHTMLSkipOffset:[HyBidSettings sharedInstance].htmlSkipOffset.offset.integerValue
                                                                                      withCloseOnFinish:[HyBidSettings sharedInstance].interstitialCloseOnFinish
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

@end
