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

#import "HyBidGADBannerCustomEvent.h"
#import "HyBidGADUtils.h"

typedef id<GADMediationBannerAdEventDelegate> _Nullable(^HyBidGADBannerCustomEventCompletionBlock)(_Nullable id<GADMediationBannerAd> ad,
                                                                                                                  NSError *_Nullable error);
@interface HyBidGADBannerCustomEvent() <HyBidAdViewDelegate, GADMediationBannerAd>

@property (nonatomic, strong) HyBidAdView *bannerAdView;
@property(nonatomic, weak, nullable) id<GADMediationBannerAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADBannerCustomEventCompletionBlock completionBlock;

@end

@implementation HyBidGADBannerCustomEvent

- (void)dealloc {
    self.bannerAdView = nil;
    self.adSize = nil;
}

- (UIView *)view {
    return self.bannerAdView;
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGADUtils areExtrasValid:serverParameter]) {
        if ([HyBidGADUtils appToken:serverParameter] != nil && [[HyBidGADUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            if (HyBid.isInitialized) {
                [self loadBannerWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
            } else {
                [HyBid initWithAppToken:[HyBidGADUtils appToken:serverParameter] completion:^(BOOL success) {
                    [self loadBannerWithZoneID:[HyBidGADUtils zoneID:serverParameter]];
                }];
            }
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"Failed banner ad fetch. Missing required server extras."];
        return;
    }

}

- (void)loadBannerWithZoneID:(NSString *)zoneID {
    self.bannerAdView = [[HyBidAdView alloc] initWithSize:self.adSize];
    self.bannerAdView.isMediation = YES;
    [self.bannerAdView loadWithZoneID:zoneID andWithDelegate:self];
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

- (HyBidAdSize *)adSize {
    return HyBidAdSize.SIZE_320x50;
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    self.delegate = self.completionBlock(self, nil);
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    [self.delegate reportImpression];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    [self.delegate reportClick];
}

@end
