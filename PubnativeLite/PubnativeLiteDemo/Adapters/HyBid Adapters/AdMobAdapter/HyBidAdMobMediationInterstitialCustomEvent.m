//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import "HyBidAdMobMediationInterstitialCustomEvent.h"
#import "HyBidAdMobUtils.h"

@interface HyBidAdMobMediationInterstitialCustomEvent() <HyBidInterstitialAdDelegate>

@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;

@end

@implementation HyBidAdMobMediationInterstitialCustomEvent

@synthesize delegate;

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)requestInterstitialAdWithParameter:(NSString * _Nullable)serverParameter
                                     label:(NSString * _Nullable)serverLabel
                                   request:(nonnull GADCustomEventRequest *)request {
    if ([HyBidAdMobUtils areExtrasValid:serverParameter]) {
        if ([HyBidAdMobUtils appToken:serverParameter] != nil || [[HyBidAdMobUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:[HyBidAdMobUtils zoneID:serverParameter] andWithDelegate:self];
            self.interstitialAd.isMediation = YES;
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

- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController {
    [self.delegate customEventInterstitialWillPresent:self];
    if ([self.interstitialAd respondsToSelector:@selector(showFromViewController:)]) {
        [self.interstitialAd showFromViewController:rootViewController];
    } else {
        [self.interstitialAd show];
    }
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    [self.delegate customEventInterstitial:self didFailAd:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)interstitialDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)interstitialDidTrackClick {
    [self.delegate customEventInterstitialWasClicked:self];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

- (void)interstitialDidTrackImpression {

}

- (void)interstitialDidDismiss {
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

@end
