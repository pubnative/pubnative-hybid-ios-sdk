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

#import "HyBidInterstitialAd.h"
#import "HyBidInterstitialAdRequest.h"
#import "HyBidInterstitialPresenter.h"
#import "HyBidInterstitialPresenterFactory.h"

@interface HyBidInterstitialAd() <HyBidInterstitialPresenterDelegate, HyBidAdRequestDelegate>

@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSObject<HyBidInterstitialAdDelegate> *delegate;
@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;

@end

@implementation HyBidInterstitialAd

- (void)dealloc
{
    self.zoneID = nil;
    self.delegate = nil;
    self.interstitialPresenter = nil;
    self.interstitialAdRequest = nil;
}

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
        self.zoneID = zoneID;
        self.delegate = delegate;
    }
    return self;
}

- (void)load
{
    if (self.zoneID == nil || self.zoneID.length == 0) {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"Invalid Zone ID provided" code:0 userInfo:nil]];
    } else {
        self.isReady = NO;
        [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:self.zoneID];
    }
}

- (void)show
{
    if (self.isReady) {
        [self.interstitialPresenter show];
    } else {
        NSLog(@"PNInterstitialAd - Can't display ad. Interstitial not ready.");
    }
}

- (void)hide
{
    [self.interstitialPresenter hide];
}

- (void)renderAd:(HyBidAd *)ad
{
    HyBidInterstitialPresenterFactory *interstitalPresenterFactory = [[HyBidInterstitialPresenterFactory alloc] init];
    self.interstitialPresenter = [interstitalPresenterFactory createInterstitalPresenterWithAd:ad withDelegate:self];
    if (self.interstitialPresenter == nil) {
        NSLog(@"PubNativeLite - Error: Could not create valid interstitial presenter");
        return;
    } else {
        [self.interstitialPresenter load];
    }
}

- (void)invokeDidLoad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidLoad)]) {
        [self.delegate interstitialDidLoad];
    }
}

- (void)invokeDidFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidFailWithError:)]) {
        [self.delegate interstitialDidFailWithError:error];
    }
}

- (void)invokeDidTrackImpression
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidTrackImpression)]) {
        [self.delegate interstitialDidTrackImpression];
    }
}

- (void)invokeDidTrackClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidTrackClick)]) {
        [self.delegate interstitialDidTrackClick];
    }
}

- (void)invokeDidDismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidDismiss)]) {
        [self.delegate interstitialDidDismiss];
    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    if (ad == nil) {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"Server returned nil ad" code:0 userInfo:nil]];
    } else {
        [self renderAd:ad];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error
{
    [self invokeDidFailWithError:error];
}

#pragma mark HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter
{
    self.isReady = YES;
    [self invokeDidLoad];
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error
{
    [self invokeDidFailWithError:error];
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter
{
    [self invokeDidTrackImpression];
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter
{
    [self invokeDidTrackClick];
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter
{
    [self invokeDidDismiss];
}

@end
