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

#import "AMCustomEventBanner.h"
#import "HyBidAdMobUtils.h"

@implementation AMCustomEventBanner

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    if ([HyBidAdMobUtils areExtrasValid:serverParameter]) {
        if ([HyBidAdMobUtils appToken:serverParameter] != nil || [[HyBidAdMobUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.bannerAdView = [[HyBidAdView alloc] initWithSize:[self getHyBidAdSizeFromSize:adSize]];
            if ([[HyBidAdCache sharedInstance].adCache objectForKey:[HyBidAdMobUtils zoneID:serverParameter]]) {
                HyBidAd *cachedAd = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidAdMobUtils zoneID:serverParameter]];
                [self.bannerAdView renderAdWithAd:cachedAd withDelegate:self];
            } else {
                self.bannerAdView.isMediation = YES;
                [self.bannerAdView loadWithZoneID:[HyBidAdMobUtils zoneID:serverParameter] andWithDelegate:self];
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

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    [self.delegate customEventBanner:self didFailAd:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

-(HyBidAdSize *)getHyBidAdSizeFromSize:(GADAdSize)size {
    if (GADAdSizeEqualToSize(size, kGADAdSizeBanner)) {
        return HyBidAdSize.SIZE_320x50;
    } else if (GADAdSizeEqualToSize(size, kGADAdSizeLargeBanner)) {
        return HyBidAdSize.SIZE_320x100;
    } else if (GADAdSizeEqualToSize(size, kGADAdSizeLeaderboard)) {
        return HyBidAdSize.SIZE_728x90;
    } else if (GADAdSizeEqualToSize(size, kGADAdSizeMediumRectangle)) {
        return HyBidAdSize.SIZE_300x250;
    }
    return [super getHyBidAdSizeFromSize:size];
}

@end
