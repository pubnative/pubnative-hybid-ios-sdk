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

#import "PNLiteMRectAdView.h"
#import "PNLiteMRectPresenter.h"
#import "PNLiteMRectPresenterFactory.h"
#import "HyBidMRectAdRequest.h"

@interface PNLiteMRectAdView() <PNLiteMRectPresenterDelegate>

@property (nonatomic, strong) PNLiteMRectPresenter *mRectPresenter;

@end

@implementation PNLiteMRectAdView

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
    PNLiteMRectPresenterFactory *mRectPresenterFactory = [[PNLiteMRectPresenterFactory alloc] init];
    self.mRectPresenter = [mRectPresenterFactory createMRectPresenterWithAd:self.ad withDelegate:self];
    if (self.mRectPresenter == nil) {
        NSLog(@"PubNativeLite - Error: Could not create valid mRect presenter");
        return;
    } else {
        [self.mRectPresenter load];
    }
}

- (void)startTracking
{
    [self.mRectPresenter startTracking];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression)]) {
        [self.delegate adViewDidTrackImpression];
    }
}

- (void)stopTracking
{
    [self.mRectPresenter stopTracking];
}

#pragma mark - PNLiteMRectPresenterDelegate

- (void)mRectPresenter:(PNLiteMRectPresenter *)mRectPresenter didLoadWithMRect:(UIView *)mRect
{
    if (mRect == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFailWithError:)]) {
            [self.delegate adViewDidFailWithError:[NSError errorWithDomain:@"An error has occurred while rendering the ad" code:0 userInfo:nil]];
        }
    } else {
        [self setupAdView:mRect];
    }
}

- (void)mRectPresenter:(PNLiteMRectPresenter *)mRectPresenter didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFailWithError:)]) {
        [self.delegate adViewDidFailWithError:error];
    }
}

- (void)mRectPresenterDidClick:(PNLiteMRectPresenter *)mRectPresenter
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackClick)]) {
        [self.delegate adViewDidTrackClick];
    }
}

@end
