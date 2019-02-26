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

#import "HyBidMRectAdView.h"
#import "HyBidMRectPresenter.h"
#import "HyBidMRectPresenterFactory.h"
#import "HyBidMRectAdRequest.h"

@interface HyBidMRectAdView() <HyBidMRectPresenterDelegate>

@property (nonatomic, strong) HyBidMRectPresenter *mRectPresenter;

@end

@implementation HyBidMRectAdView

- (void)dealloc
{
    self.mRectPresenter = nil;
}

- (instancetype)init
{
    return [super initWithFrame:CGRectMake(0, 0, 300, 250)];
}

- (HyBidAdRequest *)adRequest
{
    HyBidMRectAdRequest *mRectAdRequest = [[HyBidMRectAdRequest alloc] init];
    return mRectAdRequest;
}

- (void)renderAd
{
    HyBidMRectPresenterFactory *mRectPresenterFactory = [[HyBidMRectPresenterFactory alloc] init];
    self.mRectPresenter = [mRectPresenterFactory createMRectPresenterWithAd:self.ad withDelegate:self];
    if (self.mRectPresenter == nil) {
        NSLog(@"HyBid - Error: Could not create valid mRect presenter");
        [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"The server has returned an unsupported ad asset" code:0 userInfo:nil]];
        return;
    } else {
        [self.mRectPresenter load];
    }
}

- (void)startTracking
{
    [self.mRectPresenter startTracking];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        [self.delegate adViewDidTrackImpression:self];
    }
}

- (void)stopTracking
{
    [self.mRectPresenter stopTracking];
}

#pragma mark - HyBidMRectPresenterDelegate

- (void)mRectPresenter:(HyBidMRectPresenter *)mRectPresenter didLoadWithMRect:(UIView *)mRect
{
    if (mRect == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"An error has occurred while rendering the ad" code:0 userInfo:nil]];
        }
    } else {
        [self setupAdView:mRect];
    }
}

- (void)mRectPresenter:(HyBidMRectPresenter *)mRectPresenter didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

- (void)mRectPresenterDidClick:(HyBidMRectPresenter *)mRectPresenter
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackClick:)]) {
        [self.delegate adViewDidTrackClick:self];
    }
}

@end
