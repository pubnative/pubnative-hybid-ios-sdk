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

#import "HyBidLeaderboardAdView.h"
#import "HyBidAdPresenter.h"
#import "HyBidLeaderboardPresenterFactory.h"
#import "HyBidLeaderboardAdRequest.h"

@interface HyBidLeaderboardAdView() <HyBidAdPresenterDelegate>

@property (nonatomic, strong) HyBidAdPresenter *leaderboardPresenter;

@end

@implementation HyBidLeaderboardAdView

- (void)dealloc
{
    self.leaderboardPresenter = nil;
}

- (instancetype)init
{
    return [super initWithFrame:CGRectMake(0, 0, 728, 90)];
}

- (HyBidAdRequest *)adRequest
{
    HyBidLeaderboardAdRequest *leaderboardAdRequest = [[HyBidLeaderboardAdRequest alloc] init];
    return leaderboardAdRequest;
}

- (void)renderAd
{
    HyBidLeaderboardPresenterFactory *leaderboardPresenterFactory = [[HyBidLeaderboardPresenterFactory alloc] init];
    self.leaderboardPresenter = [leaderboardPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
    if (self.leaderboardPresenter == nil) {
        NSLog(@"HyBid - Error: Could not create valid leaderboard presenter");
        [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"The server has returned an unsupported ad asset" code:0 userInfo:nil]];
        return;
    } else {
        [self.leaderboardPresenter load];
    }
}

- (void)startTracking
{
    [self.leaderboardPresenter startTracking];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        [self.delegate adViewDidTrackImpression:self];
    }
}

- (void)stopTracking
{
    [self.leaderboardPresenter stopTracking];
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView
{
    if (adView == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"An error has occurred while rendering the ad" code:0 userInfo:nil]];
        }
    } else {
        [self setupAdView:adView];
    }
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackClick:)]) {
        [self.delegate adViewDidTrackClick:self];
    }
}

@end
