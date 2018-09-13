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

#import "PNLiteMoPubMediationMRectCustomEvent.h"
#import "HyBidMoPubUtils.h"
#import "MPLogging.h"
#import "MPConstants.h"
#import "MPError.h"

@interface PNLiteMoPubMediationMRectCustomEvent() <HyBidAdViewDelegate>

@property (nonatomic, strong) HyBidMRectAdView *mRectAdView;

@end

@implementation PNLiteMoPubMediationMRectCustomEvent

- (void)dealloc
{
    [self.mRectAdView stopTracking];
    self.mRectAdView = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    if ([HyBidMoPubUtils areExtrasValid:info]) {
        if (CGSizeEqualToSize(MOPUB_MEDIUM_RECT_SIZE, size)) {
            if ([HyBidMoPubUtils appToken:info] != nil || [[HyBidMoPubUtils appToken:info] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
                self.mRectAdView = [[HyBidMRectAdView alloc] init];
                [self.mRectAdView loadWithZoneID:[HyBidMoPubUtils zoneID:info] andWithDelegate:self];
            } else {
                [self invokeFailWithMessage:@"PubNativeLite - The provided app token doesn't match the one used to initialise PNLite."];
                return;
            }
        } else {
            [self invokeFailWithMessage:@"PubNativeLite - Error: Wrong ad size."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"PubNativeLite - Error: Failed mRect ad fetch. Missing required server extras."];
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

- (void)didDisplayAd
{
    [self.mRectAdView startTracking];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad
{
    [self.delegate bannerCustomEvent:self didLoadAd:self.mRectAdView];
}

- (void)adViewDidFailWithError:(NSError *)error
{
    [self invokeFailWithMessage:[NSString stringWithFormat:@"PubNativeLite - Internal Error: %@", error.localizedDescription]];
}

- (void)adViewDidTrackImpression
{
    [self.delegate trackImpression];
}

- (void)adViewDidTrackClick
{
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
