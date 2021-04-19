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

#import "HyBidGADNativeCustomEvent.h"
#import "HyBidGADUtils.h"
#import "HyBidGADNativeAd.h"

@interface HyBidGADNativeCustomEvent() <HyBidNativeAdLoaderDelegate, HyBidNativeAdFetchDelegate>

@property (nonatomic, strong) HyBidNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) GADNativeAdViewAdOptions *nativeAdViewAdOptions;

@end

@implementation HyBidGADNativeCustomEvent

@synthesize delegate;

- (void)dealloc {
    self.nativeAdLoader = nil;
    self.nativeAdViewAdOptions = nil;
}

- (void)requestNativeAdWithParameter:(NSString *)serverParameter
                             request:(GADCustomEventRequest *)request
                             adTypes:(NSArray *)adTypes
                             options:(NSArray *)options
                  rootViewController:(UIViewController *)rootViewController {
    if ([HyBidGADUtils areExtrasValid:serverParameter]) {
        if ([HyBidGADUtils appToken:serverParameter] != nil && [[HyBidGADUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            for (GADAdLoaderOptions *loaderOptions in options) {
                if ([loaderOptions isKindOfClass:[GADNativeAdViewAdOptions class]]) {
                self.nativeAdViewAdOptions = (GADNativeAdViewAdOptions *)loaderOptions;
              }
            }
            self.nativeAdLoader = [[HyBidNativeAdLoader alloc] init];
            self.nativeAdLoader.isMediation = YES;
            [self.nativeAdLoader loadNativeAdWithDelegate:self withZoneID:[HyBidGADUtils zoneID:serverParameter]];
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"Failed native ad fetch. Missing required server extras."];
        return;
    }
}

- (BOOL)handlesUserClicks {
  return YES;
}

- (BOOL)handlesUserImpressions {
  return YES;
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    [self.delegate customEventNativeAd:self didFailToLoadWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidNativeAdLoaderDelegate

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd {
    [nativeAd fetchNativeAdAssetsWithDelegate:self];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

#pragma mark - HyBidNativeAdFetchDelegate

- (void)nativeAdDidFinishFetching:(HyBidNativeAd *)nativeAd {
    HyBidGADNativeAd *mediatedNativeAd = [[HyBidGADNativeAd alloc] initWithHyBidNativeAd:nativeAd nativeAdViewAdOptions:self.nativeAdViewAdOptions];
    [self.delegate customEventNativeAd:self didReceiveMediatedUnifiedNativeAd:mediatedNativeAd];
}

- (void)nativeAd:(HyBidNativeAd *)nativeAd didFailFetchingWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

@end
