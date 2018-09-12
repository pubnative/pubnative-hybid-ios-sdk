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

#import "PNLiteMoPubBannerCustomEvent.h"
#import "PNLiteMoPubUtils.h"
#import "MPLogging.h"
#import "MPConstants.h"
#import "MPError.h"

@interface PNLiteMoPubBannerCustomEvent () <HyBidBannerPresenterDelegate>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) HyBidBannerPresenter *bannerPresenter;
@property (nonatomic, strong) HyBidBannerPresenterFactory *bannerPresenterFactory;
@property (nonatomic, strong) PNLiteAd *ad;

@end

@implementation PNLiteMoPubBannerCustomEvent

- (void)dealloc
{
    [self.bannerPresenter stopTracking];
    self.bannerPresenter = nil;
    self.bannerPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    if ([PNLiteMoPubUtils isZoneIDValid:info]) {
        self.size = size;
        if (CGSizeEqualToSize(MOPUB_BANNER_SIZE, size)) {
            self.ad = [[PNLiteAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[PNLiteMoPubUtils zoneID:info]];
            if (self.ad == nil) {
                [self invokeFailWithMessage:[NSString stringWithFormat:@"PubNativeLite - Error: Could not find an ad in the cache for zone id with key: %@", [PNLiteMoPubUtils zoneID:info]]];
                return;
            }
            self.bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
            self.bannerPresenter = [self.bannerPresenterFactory createBannerPresenterWithAd:self.ad withDelegate:self];
            if (self.bannerPresenter == nil) {
                [self invokeFailWithMessage:@"PubNativeLite - Error: Could not create valid banner presenter"];
                return;
            } else {
                [self.bannerPresenter load];
            } 
        } else {
            [self invokeFailWithMessage:@"PubNativeLite - Error: Wrong ad size."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"PubNativeLite - Error: Failed banner ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString *)message
{
    MPLogError(message);
    [self.delegate bannerCustomEvent:self
            didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                         code:0
                                                     userInfo:nil]];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

#pragma mark - HyBidBannerPresenterDelegate

- (void)bannerPresenter:(HyBidBannerPresenter *)bannerPresenter didLoadWithBanner:(UIView *)banner
{
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:banner];
    [self.bannerPresenter startTracking];
}

- (void)bannerPresenter:(HyBidBannerPresenter *)bannerPresenter didFailWithError:(NSError *)error
{
    [self invokeFailWithMessage:[NSString stringWithFormat:@"PubNativeLite - Internal Error: %@", error.localizedDescription]];
}

- (void)bannerPresenterDidClick:(HyBidBannerPresenter *)bannerPresenter
{
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
