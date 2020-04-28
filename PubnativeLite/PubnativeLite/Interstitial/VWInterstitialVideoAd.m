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

#import "VWInterstitialVideoAd.h"
#import "HyBidInterstitialAd.h"

@interface VWInterstitialVideoAd ()<HyBidInterstitialAdDelegate>
@property (nonatomic, strong) HyBidInterstitialAd* interstitialAd;
@end

@implementation VWInterstitialVideoAd

- (void)dealloc {
    self.interstitialAd = nil;
}

- (instancetype)init {
  self = [super init];
  if (self) {
      
  }
  return self;
}

- (void)loadRequest:(VWVideoAdRequest *)request {
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithDelegate:self];
    [self.interstitialAd load];
}

- (void)loadRequestWithZoneID:(NSString *_Nonnull)zoneID andWithRequest:(nonnull VWVideoAdRequest *)request {
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:zoneID andWithDelegate:self];
    [self.interstitialAd load];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    [self.interstitialAd showFromViewController:viewController];
}

#pragma mark HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialVideoAdReceiveAd:)]) {
        [self.delegate interstitialVideoAdReceiveAd:self];
    }
}

- (void)interstitialDidFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialVideoAd:didFailToReceiveAdWithError:)]) {
        [self.delegate interstitialVideoAd:self didFailToReceiveAdWithError:error];
    }
}

- (void)interstitialDidTrackImpression {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialVideoAdWillPresentAd:)]) {
        [self.delegate interstitialVideoAdWillPresentAd:self];
    }
}

- (void)interstitialDidTrackClick {
    
}

- (void)interstitialDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialVideoAdDidDismissAd:)]) {
        [self.delegate interstitialVideoAdDidDismissAd:self];
    }
}

@end
