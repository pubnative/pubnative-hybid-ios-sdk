//
//  VWAdvertView.m
//  HyBid
//
//  Created by Fares Ben Hamouda on 07.04.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
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

