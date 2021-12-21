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
#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"

@interface PNLiteInterstitialPresenterDecorator()

@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, weak) NSObject<HyBidInterstitialPresenterDelegate> *interstitialPresenterDelegate;

@end

@implementation PNLiteInterstitialPresenterDecorator

- (void)dealloc {
    self.interstitialPresenter = nil;
    self.adTracker = nil;
    self.interstitialPresenterDelegate = nil;
}

- (void)load {
    [self.interstitialPresenter load];
}

- (void)show {
    [self.interstitialPresenter show];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [self.interstitialPresenter showFromViewController:viewController];
}

- (void)hide {
    [self.interstitialPresenter hide];
}

- (instancetype)initWithInterstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidInterstitialPresenterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.interstitialPresenter = interstitialPresenter;
        self.adTracker = adTracker;
        self.interstitialPresenterDelegate = delegate;
    }
    return self;
}

#pragma mark HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidLoad:)]) {
        [self.interstitialPresenterDelegate interstitialPresenterDidLoad:interstitialPresenter];
    }
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidShow:)]) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
        [self.interstitialPresenterDelegate interstitialPresenterDidShow:interstitialPresenter];
    }
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidClick:)]) {
        [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
        [self.interstitialPresenterDelegate interstitialPresenterDidClick:interstitialPresenter];
    }
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidDismiss:)]) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.INTERSTITIAL_CLOSED adFormat:HyBidReportingAdFormat.FULLSCREEN properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.interstitialPresenterDelegate interstitialPresenterDidDismiss:interstitialPresenter];
    }
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenter:didFailWithError:)]) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.FULLSCREEN properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.interstitialPresenterDelegate interstitialPresenter:interstitialPresenter didFailWithError:error];
    }
}

@end
