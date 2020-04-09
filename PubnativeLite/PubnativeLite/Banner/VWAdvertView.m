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

#import <Foundation/Foundation.h>
#import "VWAdvertView.h"

@implementation VWAdvertView

HyBidAdView * _Nonnull adView;

- (void)awakeFromNib {
    [super awakeFromNib];
    adView = [[HyBidAdView alloc]initWithSize:HyBidAdSize.SIZE_320x50];
    [self addSubview: adView];
}

- (nonnull instancetype)initWithSize:(VWAdSize)size {
    
    _adLoaded = false;
    
    adView = [[HyBidAdView alloc]initWithSize: [self mapSizes:size]];
    
    [self addSubview: adView];
    
    return self;
}

- (nonnull instancetype)initWithSize:(VWAdSize)size origin:(CGPoint)origin {
    
    _adLoaded = false;
    
    adView = [[HyBidAdView alloc]initWithSize: [self mapSizes:size]];
    
    CGRect frame = adView.frame;
    frame.origin = origin;
    self.frame = frame;
    
    [self addSubview: adView];
    
    return self;
}

- (void)loadRequest:(nonnull VWAdRequest *)request {
    [adView loadWithDelegate:self];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self sizeThatFits:size];
}

- (void) show {
    [adView show];
}

// utils
- (HyBidAdSize*) mapSizes:(VWAdSize) size {
    
    if (size.flags == kVWAdSizeBanner.flags) {
        return HyBidAdSize.SIZE_320x50;
    }
    
    if (size.flags == kVWAdSizeMediumRectangle.flags) {
        return HyBidAdSize.SIZE_300x250;
    }
    
    if (size.flags == kVWAdSizeLeaderboard.flags) {
        return HyBidAdSize.SIZE_728x90;
    }
    
    return HyBidAdSize.SIZE_320x50;
    
}

// HybidAdDelegate
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    _adLoaded = false;
    [self.delegate advertView:self didFailToReceiveAdWithError:error];
}

- (void)adViewDidLoad:(HyBidAdView *)adView {
    _adLoaded = true;
    [self.delegate advertViewDidReceiveAd:self];
}

// TODO
- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    
}

// TODO
- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    
}

@end

