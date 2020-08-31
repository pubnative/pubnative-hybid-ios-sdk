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

#import "HyBidMoPubMediationLeaderboardCustomEvent.h"

@implementation HyBidMoPubMediationLeaderboardCustomEvent

- (void)dealloc {
    self.leaderboardAdView = nil;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if ([HyBidMoPubUtils areExtrasValid:info]) {
        if (size.height == kMPPresetMaxAdSize90Height.height && size.width >= 728.0f) {
            if ([HyBidMoPubUtils appToken:info] != nil || [[HyBidMoPubUtils appToken:info] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
                self.leaderboardAdView = [[HyBidLeaderboardAdView alloc] init];
                self.leaderboardAdView.isMediation = YES;
                [self.leaderboardAdView loadWithZoneID:[HyBidMoPubUtils zoneID:info] andWithDelegate:self];
                MPLogEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil]);
            } else {
                [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
                return;
            }
        } else {
            [self invokeFailWithMessage:@"Wrong ad size."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"Failed leaderboard ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogInfo(@"%@", message);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                     code:0
                                                                                 userInfo:nil]];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:self.leaderboardAdView];
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass([self class])]);
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass([self class]) error:error]);
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    [self.delegate inlineAdAdapterDidTrackImpression:self];
    MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass([self class])]);
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    [self.delegate inlineAdAdapterDidTrackClick:self];
    MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass([self class])]);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
- (HyBidAdSize *)adSize {
    return HyBidAdSize.SIZE_728x90;
}

@end
