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
#import "HyBidSKOverlay.h"
#import "PNLiteImpressionTracker.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteInterstitialPresenterDecorator() <PNLiteImpressionTrackerDelegate>

@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic) NSObject<HyBidInterstitialPresenterDelegate> *interstitialPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) HyBidSKOverlay *skoverlay;
@property (nonatomic, strong) PNLiteImpressionTracker *impressionTracker;
@property (nonatomic, strong) HyBidCustomCTAView *customCTA;

@end

@implementation PNLiteInterstitialPresenterDecorator

- (void)dealloc {
    self.interstitialPresenter = nil;
    self.adTracker = nil;
    self.interstitialPresenterDelegate = nil;
    self.errorReportingProperties = nil;
    self.skoverlay = nil;
    self.customCTA = nil;
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

- (void)hideFromViewController:(UIViewController *)viewController
{
    [self.interstitialPresenter hideFromViewController:viewController];
}

- (instancetype)initWithInterstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidInterstitialPresenterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.interstitialPresenter = interstitialPresenter;
        self.adTracker = adTracker;
        self.interstitialPresenterDelegate = delegate;
        self.errorReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    if(!self.impressionTracker) {
        self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
        [self.impressionTracker determineViewbilityRemoteConfig:interstitialPresenter.ad];
    }
    
    if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerRender) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
    }
    
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidLoad:)]) {
        if (self.interstitialPresenter.ad.skoverlayEnabled) {
            if ([self.interstitialPresenter.ad.skoverlayEnabled boolValue]) {
                self.skoverlay = [[HyBidSKOverlay alloc] initWithAd:interstitialPresenter.ad isRewarded:NO];
            }
        }
        [self.interstitialPresenterDelegate interstitialPresenterDidLoad:interstitialPresenter];
    }
}

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter viewController:(UIViewController *)viewController {
    [self interstitialPresenterDidLoad: interstitialPresenter];
    if ([HyBidCustomCTAView isCustomCTAValidWithAd: interstitialPresenter.ad]) {
        self.customCTA = [[HyBidCustomCTAView alloc] initWithAd:interstitialPresenter.ad viewController:viewController delegate:interstitialPresenter.customCTADelegate adFormat:HyBidReportingAdFormat.FULLSCREEN];
    }
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidShow:)] && !self.adTracker.impressionTracked) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
        [self.interstitialPresenterDelegate interstitialPresenterDidShow:interstitialPresenter];
        [self.skoverlay addObservers];
        [self.skoverlay presentWithAd:interstitialPresenter.ad];
        [self.customCTA presentCustomCTAWithDelay];
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
        [self.skoverlay dismissEntirely:YES withAd:interstitialPresenter.ad causedByAutoCloseTimerCompletion:NO];
    }
    
    if (self.customCTA) {
        [self.customCTA removeCustomCTA];
    }
}

- (void)interstitialPresenterDidFinish:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidFinish:)]) {
        [self.interstitialPresenterDelegate interstitialPresenterDidFinish:interstitialPresenter];
    }
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenter:didFailWithError:)]) {
        if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
            [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        }
        if(self.errorReportingProperties){
            [self.errorReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:interstitialPresenter.ad withRequest:nil]];
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.FULLSCREEN properties:self.errorReportingProperties];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
        [self.interstitialPresenterDelegate interstitialPresenter:interstitialPresenter didFailWithError:error];
    }
}

- (void)interstitialPresenterDidAppear:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.skoverlay presentWithAd:interstitialPresenter.ad];
}

- (void)interstitialPresenterDidDisappear:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.skoverlay dismissEntirely:NO withAd:interstitialPresenter.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)interstitialPresenterPresentsSKOverlay:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.skoverlay presentWithAd:interstitialPresenter.ad];
}

- (void)interstitialPresenterDismissesSKOverlay:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.skoverlay dismissEntirely:YES withAd:interstitialPresenter.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)interstitialPresenterDismissesCustomCTA:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.customCTA) {
        [self.customCTA removeCustomCTA];
    }
}

@end
