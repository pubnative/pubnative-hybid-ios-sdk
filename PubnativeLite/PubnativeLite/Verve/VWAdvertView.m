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
    HyBidAdView* adView = [[HyBidAdView alloc]initWithSize:size];
    self.adView = adView;
    return self;
}

- (nonnull instancetype)initWithSize:(HyBidAdSize*_Nonnull)size origin:(CGPoint)origin {
    HyBidAdView* adView = [[HyBidAdView alloc]initWithSize:size];
    
    CGRect frame = adView.frame;
    frame.origin = origin;
    adView.frame = frame;
    self.adView = adView;
    return self;
}

- (void)loadRequest:(nonnull VWAdRequest *)request {
    [_adView loadWithDelegate:self];
}

// TODO
- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeZero;
}

// TODO
- (void)setScrollableDataWithScrollView:(nonnull UIScrollView *)scrollView; {
    
}

// TODO
- (void)setScrollableFrame:(CGRect)frame size:(CGSize)size offset:(CGPoint)offset
{
    
}

// TODO
- (void)setScrollableFrame:(CGRect)frame size:(CGSize)size offset:(CGPoint)offset adViewFrame:(CGRect)adViewFrame {
    
}

- (void)setListingMode:(BOOL)enabled {
    
}

// HybidAdDelegate
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    self.adView = adView;
    [_delegate advertView:self didFailToReceiveAdWithError:error];
}

- (void)adViewDidLoad:(HyBidAdView *)adView {
    self.adView = adView;
    [_delegate advertViewDidReceiveAd:self];
}

// TODO
- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    
}

// TODO
- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    
}

@end

