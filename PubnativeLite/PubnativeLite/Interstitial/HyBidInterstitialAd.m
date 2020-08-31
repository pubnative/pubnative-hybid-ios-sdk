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
#import "HyBidLogger.h"
#import "HyBidIntegrationType.h"
#import "VWInterstitialVideoAd.h"

@interface HyBidInterstitialAd() <HyBidInterstitialPresenterDelegate, HyBidAdRequestDelegate>

@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, weak) NSObject<HyBidInterstitialAdDelegate> *delegate;
@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;

@end

@implementation HyBidInterstitialAd

- (void)dealloc {
    self.ad = nil;
    self.zoneID = nil;
    self.delegate = nil;
    self.interstitialPresenter = nil;
    self.interstitialAdRequest = nil;
    self.contentCategoryIDs = nil;
    self.partnerKeyword = nil;
}

- (void)cleanUp {
    self.ad = nil;
}

- (instancetype)initWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
        self.interstitialAdRequest.adSize = HyBidAdSize.SIZE_INTERSTITIAL;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
        self.zoneID = zoneID;
        self.delegate = delegate;
    }
    return self;
}

- (void)load {
    [self cleanUp];
    self.isReady = NO;
    
    self.interstitialAdRequest.contentCategoryIDs = self.contentCategoryIDs;
    self.interstitialAdRequest.partnerKeyword = self.partnerKeyword;
    if ([self.delegate isKindOfClass:[VWInterstitialVideoAd class]]) {
        [self.interstitialAdRequest setVideoIntegrationType: self.isMediation ? MEDIATION : STANDALONE withZoneID: self.zoneID];
        [self.interstitialAdRequest requestVideoAdWithDelegate:self withZoneID:self.zoneID];
    } else {
        [self.interstitialAdRequest setIntegrationType: self.isMediation ? MEDIATION : STANDALONE withZoneID: self.zoneID];
        [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:self.zoneID];
    }
}

- (void)show {
    if (self.isReady) {
        [self.interstitialPresenter show];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Interstitial not ready."];
    }
}

- (void)showFromViewController:(UIViewController *)viewController {
    if (self.isReady) {
        [self.interstitialPresenter showFromViewController:viewController];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Interstitial not ready."];
    }
}

- (void)hide {
    [self.interstitialPresenter hide];
}

- (void)renderAd:(HyBidAd *)ad {
    HyBidInterstitialPresenterFactory *interstitalPresenterFactory = [[HyBidInterstitialPresenterFactory alloc] init];
    self.interstitialPresenter = [interstitalPresenterFactory createInterstitalPresenterWithAd:ad withDelegate:self];
    if (!self.interstitialPresenter) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid interstitial presenter."];
        [self invokeDidFailWithError:[NSError errorWithDomain:@"The server has returned an unsupported ad asset." code:0 userInfo:nil]];
        return;
    } else {
        [self.interstitialPresenter load];
    }
}

- (void)invokeDidLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidLoad)]) {
        [self.delegate interstitialDidLoad];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidFailWithError:)]) {
        [self.delegate interstitialDidFailWithError:error];
    }
}

- (void)invokeDidTrackImpression {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidTrackImpression)]) {
        [self.delegate interstitialDidTrackImpression];
    }
}

- (void)invokeDidTrackClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidTrackClick)]) {
        [self.delegate interstitialDidTrackClick];
    }
}

- (void)invokeDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidDismiss)]) {
        [self.delegate interstitialDidDismiss];
    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    if (!ad) {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"Server returned nil ad." code:0 userInfo:nil]];
    } else {
        self.ad = ad;
        [self renderAd:ad];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

#pragma mark HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    self.isReady = YES;
    [self invokeDidLoad];
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self invokeDidTrackImpression];
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self invokeDidTrackClick];
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self invokeDidDismiss];
}

@end
