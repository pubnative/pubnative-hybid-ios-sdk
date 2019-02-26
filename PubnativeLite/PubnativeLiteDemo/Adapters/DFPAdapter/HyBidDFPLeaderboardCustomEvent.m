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

#import "HyBidDFPLeaderboardCustomEvent.h"
#import "HyBidDFPUtils.h"

@interface HyBidDFPLeaderboardCustomEvent () <HyBidLeaderboardPresenterDelegate>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) HyBidLeaderboardPresenter *leaderboardPresenter;
@property (nonatomic, strong) HyBidLeaderboardPresenterFactory *leaderboardPresenterFactory;
@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidDFPLeaderboardCustomEvent

@synthesize delegate;

- (void)dealloc
{
    [self.leaderboardPresenter stopTracking];
    self.leaderboardPresenter = nil;
    self.leaderboardPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString * _Nullable)serverParameter
                  label:(NSString * _Nullable)serverLabel
                request:(nonnull GADCustomEventRequest *)request
{
    if ([HyBidDFPUtils areExtrasValid:serverParameter]) {
        if (CGSizeEqualToSize(kGADAdSizeLeaderboard.size, adSize.size)) {
            self.ad = [[HyBidAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[HyBidDFPUtils zoneID:serverParameter]];
            if (self.ad == nil) {
                [self invokeFailWithMessage:[NSString stringWithFormat:@"HyBid - Error: Could not find an ad in the cache for zone id with key: %@", [HyBidDFPUtils zoneID:serverParameter]]];
                return;
            }
            self.leaderboardPresenterFactory = [[HyBidLeaderboardPresenterFactory alloc] init];
            self.leaderboardPresenter = [self.leaderboardPresenterFactory createLeaderboardPresenterWithAd:self.ad withDelegate:self];
            if (self.leaderboardPresenter == nil) {
                [self invokeFailWithMessage:@"HyBid - Error: Could not create valid leaderboard presenter"];
                return;
            } else {
                [self.leaderboardPresenter load];
            }
        } else {
            [self invokeFailWithMessage:@"HyBid - Error: Wrong ad size."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"HyBid - Error: Failed leaderboard ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message
{
    [self.delegate customEventBanner:self didFailAd:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidLeaderboardPresenterDelegate

- (void)leaderboardPresenter:(HyBidLeaderboardPresenter *)leaderboardPresenter didLoadWithLeaderboard:(UIView *)leaderboard
{
    [self.delegate customEventBanner:self didReceiveAd:leaderboard];
    [self.leaderboardPresenter startTracking];
}

- (void)leaderboardPresenter:(HyBidLeaderboardPresenter *)leaderboardPresenter didFailWithError:(NSError *)error
{
    [self invokeFailWithMessage:[NSString stringWithFormat:@"HyBid - Internal Error: %@", error.localizedDescription]];
}

- (void)leaderboardPresenterDidClick:(HyBidLeaderboardPresenter *)leaderboardPresenter
{
    [self.delegate customEventBannerWasClicked:self];
    [self.delegate customEventBannerWillLeaveApplication:self];
}

@end
