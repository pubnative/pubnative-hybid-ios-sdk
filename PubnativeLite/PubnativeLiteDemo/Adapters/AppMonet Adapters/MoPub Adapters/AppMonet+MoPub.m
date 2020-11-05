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

#import "AppMonet+MoPub.h"
#import <HyBid/HyBid.h>
#import "MPAdView.h"

@interface AppMonet ()
@property (class, nonatomic) MPAdView *mpAdView;
@end

@implementation AppMonet (MoPub)

+ (void)addBids:(MPAdView *)adView andTimeout:(NSNumber *)timeout :(void (^)(void))onReadyBlock {
    AppMonet.mpAdView = adView;
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    request.adSize = HyBidAdSize.SIZE_300x250;
    [request requestAdWithDelegate:(id<HyBidAdRequestDelegate>)self withZoneID:adView.adUnitId];
    
}

+ (void)addNativeBids:(MPNativeAdRequest *)adRequest andAdUnitId:(NSString *)adUnitId andTimeout:(NSNumber *)timeout :(void (^)(void))onReadyBlock {
    onReadyBlock();
}

+ (void)enableVerboseLogging:(BOOL)verboseLogging {
    [HyBidLogger setLogLevel:HyBidLogLevelDebug];
}

- (void)invokeDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
//        [self.delegate adView:self didFailWithError:error];
//    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    
    NSString *bidKeywords = [HyBidHeaderBiddingUtils createAppMonetHeaderBiddingKeywordsStringWithAd:ad];
    if (bidKeywords.length != 0) {
        if (AppMonet.mpAdView.keywords.length == 0) {
            AppMonet.mpAdView.keywords = bidKeywords;
        } else {
            NSString *currentKeywords = AppMonet.mpAdView.keywords;
            AppMonet.mpAdView.keywords = [NSString stringWithFormat:@"%@,%@", currentKeywords, bidKeywords];
        }
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}


@end
