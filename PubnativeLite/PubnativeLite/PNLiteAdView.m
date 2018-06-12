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

#import "PNLiteAdView.h"
#import "PNLiteBannerAdView.h"
#import "PNLiteBannerAdRequest.h"

@implementation PNLiteAdView

- (void)dealloc
{
    self.ad = nil;
    self.delegate = nil;
}

- (void)cleanUp
{
    [self stopTracking];
    [self removeAllSubViewsFrom:self];
    self.ad = nil;
}

- (void)removeAllSubViewsFrom:(UIView *)view
{
    NSArray *viewsToRemove = [view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<PNLiteAdViewDelegate> *)delegate
{
    [self cleanUp];
    self.delegate = delegate;
    if (zoneID == nil || zoneID.length == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFailWithError:)]) {
            [self.delegate adViewDidFailWithError:[NSError errorWithDomain:@"Invalid Zone ID provided" code:0 userInfo:nil]];
        }
    } else {
        [self.adRequest requestAdWithDelegate:self withZoneID:zoneID];
    }
}

- (void)setupAdView:(UIView *)adView
{
    [self addSubview:adView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad)]) {
        [self.delegate adViewDidLoad];
    }
    [self startTracking];
}

- (void)renderAd
{
    // Do nothing, this method should be overriden
}

- (void)startTracking
{
    // Do nothing, this method should be overriden
}

- (void)stopTracking
{
    // Do nothing, this method should be overriden
}

#pragma mark PNLiteAdRequestDelegate

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    if (ad == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFailWithError:)]) {
            [self.delegate adViewDidFailWithError:[NSError errorWithDomain:@"Server returned nil ad" code:0 userInfo:nil]];
        }
    } else {
        self.ad = ad;
        [self renderAd];
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFailWithError:)]) {
        [self.delegate adViewDidFailWithError:error];
    }
}

@end
