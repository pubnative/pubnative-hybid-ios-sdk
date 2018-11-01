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
#import "HyBidLeaderboardPresenter.h"
#import "HyBidLeaderboardPresenterFactory.h"

@interface HyBidLeaderboardAdView() <HyBidLeaderboardPresenterDelegate>

@property (nonatomic, strong) HyBidLeaderboardPresenter *leaderboardPresenter;

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
    return nil;
}

- (void)renderAd
{
    HyBidLeaderboardPresenterFactory *leaderboardPresenterFactory = [[HyBidLeaderboardPresenterFactory alloc] init];
    self.leaderboardPresenter = [leaderboardPresenterFactory createLeaderboardPresenterWithAd:self.ad withDelegate:self];
    if (self.leaderboardPresenter == nil) {
        NSLog(@"HyBid - Error: Could not create valid leaderboard presenter");
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

#pragma mark - HyBidLeaderboardPresenterDelegate

- (void)leaderboardPresenter:(HyBidLeaderboardPresenter *)leaderboardPresenter didLoadWithLeaderboard:(UIView *)leaderboard
{
    if (leaderboard == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"An error has occurred while rendering the ad" code:0 userInfo:nil]];
        }
    } else {
        [self setupAdView:leaderboard];
    }
}

- (void)leaderboardPresenter:(HyBidLeaderboardPresenter *)leaderboardPresenter didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

- (void)leaderboardPresenterDidClick:(HyBidLeaderboardPresenter *)leaderboardPresenter
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackClick:)]) {
        [self.delegate adViewDidTrackClick:self];
    }
}

@end
