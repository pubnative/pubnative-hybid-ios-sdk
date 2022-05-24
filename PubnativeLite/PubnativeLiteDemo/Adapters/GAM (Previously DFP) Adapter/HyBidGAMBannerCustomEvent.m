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

#import "HyBidGAMBannerCustomEvent.h"
#import "HyBidGAMUtils.h"

typedef id<GADMediationBannerAdEventDelegate> _Nullable(^HyBidGADBannerCustomEventCompletionBlock)(_Nullable id<GADMediationBannerAd> ad,
                                                                                                                  NSError *_Nullable error);
@interface HyBidGAMBannerCustomEvent () <HyBidAdPresenterDelegate, GADMediationBannerAd>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidBannerPresenterFactory *bannerPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) UIView *adView;
@property(nonatomic, weak, nullable) id<GADMediationBannerAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADBannerCustomEventCompletionBlock completionBlock;

@end

@implementation HyBidGAMBannerCustomEvent

- (void)dealloc {
    self.adPresenter = nil;
    self.bannerPresenterFactory = nil;
    self.ad = nil;
    self.adView = nil;
}

- (UIView *)view {
    return self.adView;
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGAMUtils areExtrasValid:serverParameter]) {
        self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidGAMUtils zoneID:serverParameter]];
        if (!self.ad) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"Could not find an ad in the cache for zone id with key: %@", [HyBidGAMUtils zoneID:serverParameter]]];
            return;
        }
        self.bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
        self.adPresenter = [self.bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
        if (!self.adPresenter) {
            [self invokeFailWithMessage:@"Could not create valid banner presenter."];
            return;
        } else {
            [self.adPresenter load];
        }
        
    } else {
        [self invokeFailWithMessage:@"Failed banner ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    self.adView = adView;
    self.delegate = self.completionBlock(self, nil);
    [self.delegate reportImpression];
    [self.adPresenter startTracking];
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    [self.delegate reportClick];
}

@end
