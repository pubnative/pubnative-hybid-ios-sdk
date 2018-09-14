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

#import "HyBidBannerAdView.h"
#import "HyBidBannerPresenter.h"
#import "HyBidBannerPresenterFactory.h"
#import "HyBidBannerAdRequest.h"

@interface HyBidBannerAdView() <HyBidBannerPresenterDelegate>

@property (nonatomic, strong) HyBidBannerPresenter *bannerPresenter;

@end

@implementation HyBidBannerAdView

- (void)dealloc
{
    self.bannerPresenter = nil;
}

- (instancetype)init
{
    return [super initWithFrame:CGRectMake(0, 0, 320, 50)];
}

- (HyBidAdRequest *)adRequest
{
    HyBidBannerAdRequest *bannerAdRequest = [[HyBidBannerAdRequest alloc] init];
    return bannerAdRequest;
}

- (void)renderAd
{
    HyBidBannerPresenterFactory *bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
    self.bannerPresenter = [bannerPresenterFactory createBannerPresenterWithAd:self.ad withDelegate:self];
    if (self.bannerPresenter == nil) {
        NSLog(@"HyBid - Error: Could not create valid banner presenter");
        return;
    } else {
        [self.bannerPresenter load];
    }
}

- (void)startTracking
{
    [self.bannerPresenter startTracking];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression)]) {
        [self.delegate adViewDidTrackImpression];
    }
}

- (void)stopTracking
{
    [self.bannerPresenter stopTracking];
}

#pragma mark - HyBidBannerPresenterDelegate

- (void)bannerPresenter:(HyBidBannerPresenter *)bannerPresenter didLoadWithBanner:(UIView *)banner
{
    if (banner == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFailWithError:)]) {
            [self.delegate adViewDidFailWithError:[NSError errorWithDomain:@"An error has occurred while rendering the ad" code:0 userInfo:nil]];
        }
    } else {
        [self setupAdView:banner];
    }
}

- (void)bannerPresenter:(HyBidBannerPresenter *)bannerPresenter didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFailWithError:)]) {
        [self.delegate adViewDidFailWithError:error];
    }
}

- (void)bannerPresenterDidClick:(HyBidBannerPresenter *)bannerPresenter
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackClick)]) {
        [self.delegate adViewDidTrackClick];
    }
}

@end
