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

#import "PNLiteAdPresenterDecorator.h"
#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"

@interface PNLiteAdPresenterDecorator ()

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, weak) NSObject<HyBidAdPresenterDelegate> *adPresenterDelegate;

@end

@implementation PNLiteAdPresenterDecorator

- (void)dealloc {
    [self stopTracking];
    self.adPresenter = nil;
    self.adTracker = nil;
    self.adPresenterDelegate = nil;
}

- (void)load {
    [self.adPresenter load];
}

- (void)startTracking {
    [self.adPresenter startTracking];
}

- (void)stopTracking {
    [self.adPresenter stopTracking];
}

- (instancetype)initWithAdPresenter:(HyBidAdPresenter *)adPresenter
                      withAdTracker:(HyBidAdTracker *)adTracker
                       withDelegate:(NSObject<HyBidAdPresenterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.adPresenter = adPresenter;
        self.adTracker = adTracker;
        self.adPresenterDelegate = delegate;
    }
    return self;
}

#pragma mark HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenter:didLoadWithAd:)]) {
        if (self.adPresenter.ad.adType != kHyBidAdTypeVideo) {
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.IMPRESSION adFormat:HyBidReportingAdFormat.BANNER properties:nil];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
            [self.adTracker trackImpression];
        }
        [self.adPresenterDelegate adPresenter:adPresenter didLoadWithAd:adView];
    }
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidClick:)]) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CLICK adFormat:HyBidReportingAdFormat.BANNER properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.adTracker trackClick];
        [self.adPresenterDelegate adPresenterDidClick:adPresenter];
    }
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenter:didFailWithError:)]) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.BANNER properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.adPresenterDelegate adPresenter:adPresenter didFailWithError:error];
    }
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)]) {
        HyBidReportingEvent* reportingVideoStartedEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.VIDEO_STARTED adFormat:HyBidReportingAdFormat.BANNER properties:nil];
        HyBidReportingEvent* reportingImpressionEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.IMPRESSION adFormat:HyBidReportingAdFormat.BANNER properties:nil];
        
        [[HyBid reportingManager] reportEventsFor:[NSArray arrayWithObjects:reportingVideoStartedEvent, reportingImpressionEvent, nil]];         
        [self.adTracker trackImpression];
        [self.adPresenterDelegate adPresenterDidStartPlaying:adPresenter];
    }
}


@end
