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

#import "PNLiteBannerPresenterDecorator.h"

@interface PNLiteBannerPresenterDecorator ()

@property (nonatomic, strong) PNLiteBannerPresenter *bannerPresenter;
@property (nonatomic, strong) NSObject<PNLiteBannerPresenterDelegate> *bannerPresenterDelegate;
// TO-DO: Add Ad Tracker Delegate property

@end

@implementation PNLiteBannerPresenterDecorator

- (void)dealloc
{
    self.bannerPresenter = nil;
    self.bannerPresenterDelegate = nil;
}

- (void)load
{
    [self.bannerPresenter load];
}

- (instancetype)initWithBannerPresenter:(PNLiteBannerPresenter *)bannerPresenter
                           withDelegate:(NSObject<PNLiteBannerPresenterDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.bannerPresenter = bannerPresenter;
        self.bannerPresenterDelegate = delegate;
        // TO-DO: Add Tracker initialization
    }
    return self;
}

#pragma mark PNLiteBannerPresenterDelegate

- (void)bannerPresenter:(PNLiteBannerPresenter *)bannerPresenter didLoadWithBanner:(UIView *)banner
{
    // TO-DO: Call delegate method when banner is tracked
    [self.bannerPresenterDelegate bannerPresenter:bannerPresenter didLoadWithBanner:banner];
}

- (void)bannerPresenterDidClick:(PNLiteBannerPresenter *)bannerPresenter
{
    // TO-DO: Call delegate method when banner is clicked
    [self.bannerPresenterDelegate bannerPresenterDidClick:bannerPresenter];
}

- (void)bannerPresenter:(PNLiteBannerPresenter *)bannerPresenter didFailWithError:(NSError *)error
{
    [self.bannerPresenterDelegate bannerPresenter:bannerPresenter didFailWithError:error];
}

@end
