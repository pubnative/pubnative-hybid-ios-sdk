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

#import "VWInterstitialAd.h"
#import "HyBidInterstitialAd.h"

@interface VWInterstitialAd ()<HyBidInterstitialAdDelegate>
@property (nonatomic, strong) HyBidInterstitialAd* interstitialAd;
@property (nonatomic, readwrite, assign) BOOL hasBeenUsed;
@end

@implementation VWInterstitialAd

- (void)dealloc {
    self.interstitialAd = nil;
}

- (instancetype)init {
  VWInterstitialAdSize size = VWInterstitialAdSizePad;
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    size = VWInterstitialAdSizePhone;
  }
  return [self initWithSize:size];
}

- (instancetype)initWithSize:(VWInterstitialAdSize)size {
    self = [super init];
    if (self) {
      self.hasBeenUsed = NO;
    }
    return self;
}

- (void)loadRequest:(VWAdRequest *)adRequest {
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithDelegate:self];
    [self.interstitialAd load];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    [self.interstitialAd showFromViewController:viewController];
}

- (BOOL)isReady {
    return self.interstitialAd.isReady;
}

- (BOOL)hasBeenUsed {
    return self.hasBeenUsed;
}

#pragma mark HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialAdReceiveAd:)]) {
        [self.delegate interstitialAdReceiveAd:self];
    }
}

- (void)interstitialDidFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialAd:didFailToReceiveAdWithError:)]) {
        [self.delegate interstitialAd:self didFailToReceiveAdWithError:error];
    }
}

- (void)interstitialDidTrackImpression {
    self.hasBeenUsed = YES;
}

- (void)interstitialDidTrackClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialAdWillLeaveApplication:)]) {
        [self.delegate interstitialAdWillLeaveApplication:self];
    }
}

- (void)interstitialDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialAdDidDismissAd:)]) {
        [self.delegate interstitialAdDidDismissAd:self];
    }
}

@end
