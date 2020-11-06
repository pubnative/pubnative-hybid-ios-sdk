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

#import "AMCustomEventInterstitial.h"
#import "HyBidMoPubUtils.h"
#import "MPLogging.h"
#import "MPError.h"

@implementation AMCustomEventInterstitial

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if ([HyBidMoPubUtils areExtrasValid:info]) {
        if ([HyBidMoPubUtils appToken:info] != nil || [[HyBidMoPubUtils appToken:info] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:[HyBidMoPubUtils zoneID:info] andWithDelegate:self];
            if ([[HyBidAdCache sharedInstance].adCache objectForKey:[HyBidMoPubUtils zoneID:info]]) {
                HyBidAd *cachedAd = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidMoPubUtils zoneID:info]];
                [self.interstitialAd prepareAdWithAd:cachedAd];
            } else {
                self.interstitialAd.isMediation = YES;
                [self.interstitialAd load];
            }
            MPLogEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil]);
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
        
    } else {
        [self invokeFailWithMessage:@"Failed interstitial ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogInfo(@"%@", message);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                         code:0
                                                                                     userInfo:nil]];
}
@end
