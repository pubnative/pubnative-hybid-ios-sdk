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
    if ([HyBidGADUtils areExtrasValid:serverParameter]) {
        if ([HyBidGADUtils appToken:serverParameter] != nil && [[HyBidGADUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            if (HyBid.isInitialized) {
                [self loadInterstitialWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
            } else {
                [HyBid initWithAppToken:[HyBidGADUtils appToken:serverParameter] completion:^(BOOL success) {
                    [self loadInterstitialWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
                }];
            }
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
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
