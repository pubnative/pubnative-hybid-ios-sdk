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

#import "HyBidAdView.h"
#import "HyBidLogger.h"
#import "HyBidIntegrationType.h"
#import "HyBidBannerPresenterFactory.h"

@interface HyBidAdView()

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;

@end

@implementation HyBidAdView

- (void)dealloc {
    self.ad = nil;
    self.delegate = nil;
    self.adPresenter = nil;
    self.adRequest = nil;
    self.adSize = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.adRequest = [[HyBidAdRequest alloc] init];
}

- (instancetype)initWithSize:(HyBidAdSize *)adSize {
    self = [super initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)];
    if (self) {
        self.adRequest = [[HyBidAdRequest alloc] init];
        self.adSize = adSize;
    }
    return self;
}

- (void)cleanUp {
    [self removeAllSubViewsFrom:self];
    self.ad = nil;
}

- (void)removeAllSubViewsFrom:(UIView *)view {
    NSArray *viewsToRemove = [view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.delegate = delegate;
    if (!zoneID || zoneID.length == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"Invalid Zone ID provided." code:0 userInfo:nil]];
        }
    } else {
        self.adRequest.adSize = self.adSize;
        [self.adRequest setIntegrationType: self.isMediation ? MEDIATION : STANDALONE withZoneID:zoneID];
        [self.adRequest requestAdWithDelegate:self withZoneID:zoneID];
    }
}

- (void)loadWithDelegate: (NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.delegate = delegate;
    self.adRequest.adSize = self.adSize;
    [self.adRequest setIntegrationType: self.isMediation ? MEDIATION : STANDALONE];
    [self.adRequest requestAdWithDelegate:self];
}

- (void)setupAdView:(UIView *)adView {
    [self addSubview:adView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
        [self.delegate adViewDidLoad:self];
    }
    [self startTracking];
}

- (void)renderAd {
    self.adPresenter = [self createAdPresenter];
    if (!self.adPresenter) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid ad presenter."];
        [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"The server has returned an unsupported ad asset." code:0 userInfo:nil]];
        return;
    } else {
        [self.adPresenter load];
    }
}

- (void)startTracking {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        [self.adPresenter startTracking];
        [self.delegate adViewDidTrackImpression:self];
    }
}

- (void)stopTracking {
    [self.adPresenter stopTracking];
}

- (HyBidAdPresenter *)createAdPresenter {
    HyBidBannerPresenterFactory *bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
    return [bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    if (!ad) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"Server returned nil ad." code:0 userInfo:nil]];
        }
    } else {
        self.ad = ad;
        [self renderAd];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ failed with error: %@",request, error.localizedDescription]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    if (!adView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"An error has occurred while rendering the ad." code:0 userInfo:nil]];
        }
    } else {
        [self setupAdView:adView];
    }
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

-  (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackClick:)]) {
        [self.delegate adViewDidTrackClick:self];
    }
}

@end
