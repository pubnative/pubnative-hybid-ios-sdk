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

#import "HyBidLeaderboardPresenterDecorator.h"

@interface HyBidLeaderboardPresenterDecorator ()

@property (nonatomic, strong) HyBidLeaderboardPresenter *leaderboardPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, strong) NSObject<HyBidLeaderboardPresenterDelegate> *leaderboardPresenterDelegate;

@end

@implementation HyBidLeaderboardPresenterDecorator

- (void)dealloc
{
    self.leaderboardPresenter = nil;
    self.adTracker = nil;
    self.leaderboardPresenterDelegate = nil;
}

- (void)load
{
    [self.leaderboardPresenter load];
}

- (void)startTracking
{
    [self.leaderboardPresenter startTracking];
}

- (void)stopTracking
{
    [self.leaderboardPresenter stopTracking];
}

- (instancetype)initWithLeaderboardPresenter:(HyBidLeaderboardPresenter *)leaderboardPresenter
                               withAdTracker:(HyBidAdTracker *)adTracker
                                withDelegate:(NSObject<HyBidLeaderboardPresenterDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.leaderboardPresenter = leaderboardPresenter;
        self.adTracker = adTracker;
        self.leaderboardPresenterDelegate = delegate;
    }
    return self;
}

#pragma mark HyBidLeaderboardPresenterDelegate

- (void)leaderboardPresenter:(HyBidLeaderboardPresenter *)leaderboardPresenter didLoadWithLeaderboard:(UIView *)leaderboard
{
    [self.adTracker trackImpression];
    [self.leaderboardPresenterDelegate leaderboardPresenter:leaderboardPresenter didLoadWithLeaderboard:leaderboard];
}

- (void)leaderboardPresenterDidClick:(HyBidLeaderboardPresenter *)leaderboardPresenter
{
    [self.adTracker trackClick];
    [self.leaderboardPresenterDelegate leaderboardPresenterDidClick:leaderboardPresenter];
}

- (void)leaderboardPresenter:(HyBidLeaderboardPresenter *)leaderboardPresenter didFailWithError:(NSError *)error
{
    [self.leaderboardPresenterDelegate leaderboardPresenter:leaderboardPresenter didFailWithError:error];
}

@end
