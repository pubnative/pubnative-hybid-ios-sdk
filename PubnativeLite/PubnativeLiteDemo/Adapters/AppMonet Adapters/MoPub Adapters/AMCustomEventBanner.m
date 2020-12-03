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
#import "HyBidMoPubUtils.h"
#import "MPLogging.h"
#import "MPConstants.h"
#import "MPError.h"
#import "AdRequestInfo.h"
#import "PlacementMappingManager.h"

@implementation AMCustomEventBanner

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (([HyBidMoPubUtils appToken:info] != nil && [HyBidMoPubUtils zoneID:info] != nil) || [HyBidMoPubUtils eCPM:info] != nil) {
        NSString *appToken = nil;
        NSString *zoneID = nil;
        
        if ([info objectForKey:@"cpm"] != nil) {
            NSString *eCPM = [info objectForKey:@"cpm"];
            HyBidAdSize *adSize = [self getHyBidAdSizeFromSize:size];
            AdRequestInfo *adRequestInfo = [[PlacementMappingManager sharedInstance] getEcmpMappingFrom:adSize andEcpm:eCPM];
            
            if (adRequestInfo != nil &&
                [[adRequestInfo getAppToken] length] != 0 &&
                [[adRequestInfo getZoneID] length] != 0) {
                appToken = [adRequestInfo getAppToken];
                zoneID = [adRequestInfo getZoneID];
            }
        }
        
        if ([appToken length] == 0 && [zoneID length] == 0) {
            if ([HyBidMoPubUtils appToken:info] != nil && [HyBidMoPubUtils zoneID:info] != nil) {
                appToken = [HyBidMoPubUtils appToken:info];
                zoneID = [HyBidMoPubUtils zoneID:info];
            } else {
                [self invokeFailWithMessage:@"Could not find the required params in CustomEventBanner adapterInfo."];
                return;
            }
        }
        
        if (appToken != nil || [appToken isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.bannerAdView = [[HyBidAdView alloc] initWithSize:[self getHyBidAdSizeFromSize:size]];
            
            if ([[HyBidAdCache sharedInstance].adCache objectForKey:zoneID]) {
                HyBidAd *cachedAd = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:zoneID];
                [self.bannerAdView renderAdWithAd:cachedAd withDelegate:self];
            } else {
                self.bannerAdView.isMediation = YES;
                [self.bannerAdView loadWithZoneID:zoneID andWithDelegate:self];
            }
            MPLogEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass([self class]) dspCreativeId:nil dspName:nil]);
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
    MPLogInfo(@"%@", message);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                                                     code:0
                                                                                 userInfo:nil]];
}

- (HyBidAdSize *)getHyBidAdSizeFromSize:(CGSize)size {
    if (size.width != 0 && size.height != 0) {
        if (size.height >= 1024) {
            if (size.width >= HyBidAdSize.SIZE_768x1024.width) {
                return HyBidAdSize.SIZE_768x1024;
            }
        } else if (size.height >= 768) {
            if (size.width >= HyBidAdSize.SIZE_1024x768.width) {
                return HyBidAdSize.SIZE_1024x768;
            }
        } else if (size.height >= 600) {
            if (size.width >= HyBidAdSize.SIZE_300x600.width) {
                return HyBidAdSize.SIZE_300x600;
            } else if (size.width >= HyBidAdSize.SIZE_160x600.width) {
                return HyBidAdSize.SIZE_160x600;
            }
        } else if (size.height >= 480) {
            if (size.width >= HyBidAdSize.SIZE_320x480.width) {
                return HyBidAdSize.SIZE_320x480;
            }
        } else if (size.height >= 320) {
            if (size.width >= HyBidAdSize.SIZE_480x320.width) {
                return HyBidAdSize.SIZE_480x320;
            }
        } else if (size.height >= 250) {
            if (size.width >= HyBidAdSize.SIZE_300x250.width) {
                return HyBidAdSize.SIZE_300x250;
            } else if (size.width >= HyBidAdSize.SIZE_250x250.width) {
                return HyBidAdSize.SIZE_250x250;
            }
        } else if (size.height >= 100) {
            if (size.width >= HyBidAdSize.SIZE_320x100.width) {
                return HyBidAdSize.SIZE_320x100;
            }
        } else if (size.height >= 90) {
            if (size.width >= HyBidAdSize.SIZE_728x90.width) {
                return HyBidAdSize.SIZE_728x90;
            }
        } else if (size.height >= 50) {
            if (size.width >= HyBidAdSize.SIZE_320x50.width) {
                return HyBidAdSize.SIZE_320x50;
            } else if (size.width >= HyBidAdSize.SIZE_300x50.width) {
                return HyBidAdSize.SIZE_300x50;
            }
        } else {
            return HyBidAdSize.SIZE_320x50;
        }
    }
    return [super getHyBidAdSizeFromSize:size];
}

@end
