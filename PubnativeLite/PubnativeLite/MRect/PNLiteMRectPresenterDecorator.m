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

#import "PNLiteMRectPresenterDecorator.h"

@interface PNLiteMRectPresenterDecorator ()

@property (nonatomic, strong) HyBidMRectPresenter *mRectPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, strong) NSObject<HyBidMRectPresenterDelegate> *mRectPresenterDelegate;

@end

@implementation PNLiteMRectPresenterDecorator

- (void)dealloc
{
    self.mRectPresenter = nil;
    self.adTracker = nil;
    self.mRectPresenterDelegate = nil;
}

- (void)load
{
    [self.mRectPresenter load];
}

- (void)startTracking
{
    [self.mRectPresenter startTracking];
}

- (void)stopTracking
{
    [self.mRectPresenter stopTracking];
}

- (instancetype)initWithMRectPresenter:(HyBidMRectPresenter *)mRectPresenter
                         withAdTracker:(HyBidAdTracker *)adTracker
                          withDelegate:(NSObject<HyBidMRectPresenterDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.mRectPresenter = mRectPresenter;
        self.adTracker = adTracker;
        self.mRectPresenterDelegate = delegate;
    }
    return self;
}

#pragma mark HyBidMRectPresenterDelegate

- (void)mRectPresenter:(HyBidMRectPresenter *)mRectPresenter didLoadWithMRect:(UIView *)mRect
{
    [self.adTracker trackImpression];
    [self.mRectPresenterDelegate mRectPresenter:mRectPresenter didLoadWithMRect:mRect];
}

- (void)mRectPresenterDidClick:(HyBidMRectPresenter *)mRectPresenter
{
    [self.adTracker trackClick];
    [self.mRectPresenterDelegate mRectPresenterDidClick:mRectPresenter];
}

- (void)mRectPresenter:(HyBidMRectPresenter *)mRectPresenter didFailWithError:(NSError *)error
{
    [self.mRectPresenterDelegate mRectPresenter:mRectPresenter didFailWithError:error];
}

@end
