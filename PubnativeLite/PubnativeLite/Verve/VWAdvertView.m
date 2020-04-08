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

- (nonnull instancetype)initWithSize:(HyBidAdSize*_Nonnull)size {
    
    _adLoaded = false;

    self.adSize = size;
    
    return self;
}

- (nonnull instancetype)initWithSize:(HyBidAdSize*_Nonnull)size origin:(CGPoint)origin {
    
    _adLoaded = false;
    
    self.adSize = size;

    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
    
    return self;
}

- (void)loadRequest:(nonnull VWAdRequest *)request {
   [self loadWithDelegate:self];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self sizeThatFits:size];
}

// HybidAdDelegate
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    _adLoaded = false;
    [self.delegateVerve advertView:self didFailToReceiveAdWithError:error];
}

- (void)adViewDidLoad:(HyBidAdView *)adView {
    _adLoaded = true;
    [self.delegateVerve advertViewDidReceiveAd:self];
}

// TODO
- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    
}

// TODO
- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    
}

@end

