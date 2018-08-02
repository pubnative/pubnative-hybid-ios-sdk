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

#import "PNLiteInterstitialPresenterDecorator.h"

@interface PNLiteInterstitialPresenterDecorator()

@property (nonatomic, strong) PNLiteInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) PNLiteAdTracker *adTracker;
@property (nonatomic, strong) NSObject<PNLiteInterstitialPresenterDelegate> *interstitialPresenterDelegate;

@end

@implementation PNLiteInterstitialPresenterDecorator

- (void)dealloc
{
    self.interstitialPresenter = nil;
    self.adTracker = nil;
    self.interstitialPresenterDelegate = nil;
}

- (void)load
{
    [self.interstitialPresenter load];
}

- (void)show
{
    [self.interstitialPresenter show];
}

- (void)hide
{
    [self.interstitialPresenter hide];
}

- (instancetype)initWithInterstitialPresenter:(PNLiteInterstitialPresenter *)interstitialPresenter
                                withAdTracker:(PNLiteAdTracker *)adTracker
                                 withDelegate:(NSObject<PNLiteInterstitialPresenterDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.interstitialPresenter = interstitialPresenter;
        self.adTracker = adTracker;
        self.interstitialPresenterDelegate = delegate;
    }
    return self;
}

#pragma mark PNLiteInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    [self.interstitialPresenterDelegate interstitialPresenterDidLoad:interstitialPresenter];
}

- (void)interstitialPresenterDidShow:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    [self.adTracker trackImpression];
    [self.interstitialPresenterDelegate interstitialPresenterDidShow:interstitialPresenter];
}

- (void)interstitialPresenterDidClick:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    [self.adTracker trackClick];
    [self.interstitialPresenterDelegate interstitialPresenterDidClick:interstitialPresenter];
}

- (void)interstitialPresenterDidDismiss:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    [self.interstitialPresenterDelegate interstitialPresenterDidDismiss:interstitialPresenter];
}

- (void)interstitialPresenter:(PNLiteInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error
{
    [self.interstitialPresenterDelegate interstitialPresenter:interstitialPresenter didFailWithError:error];
}

@end
