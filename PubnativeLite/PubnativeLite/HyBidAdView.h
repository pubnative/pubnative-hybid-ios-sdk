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

#import <UIKit/UIKit.h>
#import "HyBidAd.h"
#import "HyBidAdRequest.h"
#import "HyBidAdPresenter.h"
#import "HyBidSignalDataProcessor.h"

@class HyBidAdView;

@protocol HyBidAdViewDelegate<NSObject>

- (void)adViewDidLoad:(HyBidAdView *)adView;
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error;
- (void)adViewDidTrackImpression:(HyBidAdView *)adView;
- (void)adViewDidTrackClick:(HyBidAdView *)adView;

@end

@interface HyBidAdView : UIView <HyBidAdRequestDelegate, HyBidAdPresenterDelegate, HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) HyBidAdRequest *adRequest;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, weak) NSObject <HyBidAdViewDelegate> *delegate;
@property (nonatomic, assign) BOOL isMediation;
@property (nonatomic, strong) HyBidAdSize *adSize;
@property (nonatomic, assign) BOOL autoShowOnLoad;

- (instancetype)initWithSize:(HyBidAdSize *)adSize NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
//- (instancetype)init NS_UNAVAILABLE;
- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)setupAdView:(UIView *)adView;
- (void)renderAd;
- (void)renderAdWithContent:(NSString *)adContent withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate;
- (void)startTracking;
- (void)stopTracking;
- (void)show;
- (HyBidAdPresenter *)createAdPresenter;

@end
