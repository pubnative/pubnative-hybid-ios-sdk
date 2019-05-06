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

#import "HyBidMoPubMediationInterstitialCustomEvent.h"
#import "HyBidMoPubUtils.h"
#import "MPLogging.h"
#import "MPError.h"

@interface HyBidMoPubMediationInterstitialCustomEvent() <HyBidInterstitialAdDelegate>

@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;

@end

@implementation HyBidMoPubMediationInterstitialCustomEvent

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    if ([HyBidMoPubUtils areExtrasValid:info]) {
        if ([HyBidMoPubUtils appToken:info] != nil || [[HyBidMoPubUtils appToken:info] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:[HyBidMoPubUtils zoneID:info] andWithDelegate:self];
            [self.interstitialAd load];
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
        
    } else {
        [self invokeFailWithMessage:@"Failed interstitial ad fetch. Missing required server extras."];
        return;
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.interstitialAd show];
}

- (void)invokeFailWithMessage:(NSString *)message {
    MPLogError(@"%@", message);
    [HyBidLogger error:NSStringFromClass([self class]) withMessage:message];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                             code:0
                                                                                         userInfo:nil]];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)interstitialDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)interstitialDidTrackClick {
    [self.delegate trackClick];
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)interstitialDidTrackImpression {
    [self.delegate trackImpression];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialDidDismiss {
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
