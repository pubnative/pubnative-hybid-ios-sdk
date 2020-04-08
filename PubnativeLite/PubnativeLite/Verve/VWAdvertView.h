//
//  VWAdvertView.h
//  HyBid
//
//  Created by Fares Ben Hamouda on 07.04.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import "VWAdRequest.h"
#import "HyBidAdSize.h"
#import "HyBidAdView.h"

@class VWAdvertView;

@protocol VWAdvertViewDelegate

- (void)advertViewDidReceiveAd:(nonnull VWAdvertView *)adView;

- (void)advertView:(nonnull VWAdvertView *)adView didFailToReceiveAdWithError:(nullable NSError *)error;

@end

@interface VWAdvertView : HyBidAdView<HyBidAdViewDelegate>

@property (nonatomic, weak, nullable) id <VWAdvertViewDelegate, NSObject> delegateVerve;

@property (nonatomic, assign, readonly) BOOL adLoaded;

- (nonnull instancetype)initWithSize:(HyBidAdSize*_Nonnull)size;

- (nonnull instancetype)initWithSize:(HyBidAdSize*_Nonnull)size origin:(CGPoint)origin;

- (void)loadRequest:(nonnull VWAdRequest *)request;

- (CGSize)sizeThatFits:(CGSize)size;

@end

