// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
    self.skoverlayDelegate = nil;
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
                self.skoverlay = [[HyBidSKOverlay alloc] initWithAd:interstitialPresenter.ad
                                                         isRewarded:NO
                                                           delegate:interstitialPresenter.skoverlayDelegate];
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
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidShow:)]) {
        
        if (!self.adTracker.impressionTracked) {
            [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
            [self.interstitialPresenterDelegate interstitialPresenterDidShow:interstitialPresenter];
        }
        
        [self.skoverlay addObservers];
        [self.skoverlay presentWithAd:interstitialPresenter.ad];
        [self.customCTA presentCustomCTAWithDelay];
    }
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidClick:)]) {
        if (self.interstitialPresenter.ad.shouldReportCustomEndcardImpression) {
            [self.adTracker trackCustomEndCardClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
        } else {
            [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
        }
        [self.interstitialPresenterDelegate interstitialPresenterDidClick:interstitialPresenter];
    }
}

- (void)interstitialPresenterDidSKOverlayAutomaticClick:(HyBidInterstitialPresenter *)interstitialPresenter clickType:(HyBidSKOverlayAutomaticCLickType)clickType {
    
    switch(clickType){
        case HyBidSKOverlayAutomaticCLickVideo:
            [self.adTracker trackSKOverlayAutomaticClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
            break;
        case HyBidSKOverlayAutomaticCLickDefaultEndCard:
            [self.adTracker trackSKOverlayAutomaticDefaultEndCardClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
            break;
        case HyBidSKOverlayAutomaticCLickCustomEndCard:
            [self.adTracker trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
            break;
    }
}

- (void)interstitialPresenterDidStorekitAutomaticClick:(HyBidInterstitialPresenter *)interstitialPresenter clickType:(HyBidStorekitAutomaticClickType)clickType {
    
    switch(clickType){
        case HyBidStorekitAutomaticClickVideo:
            [self.adTracker trackStorekitAutomaticClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
            break;
        case HyBidStorekitAutomaticClickDefaultEndCard:
            [self.adTracker trackStorekitAutomaticDefaultEndCardClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
            break;
        case HyBidStorekitAutomaticClickCustomEndCard:
            [self.adTracker trackStorekitAutomaticCustomEndCardClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
            break;
    }
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidDismiss:)]) {
        if ([HyBidSDKConfig sharedConfig].reporting) {
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.INTERSTITIAL_CLOSED adFormat:HyBidReportingAdFormat.FULLSCREEN properties:nil];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
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
        if ([HyBidSDKConfig sharedConfig].reporting) {
            if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
                [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
            }
            if(self.errorReportingProperties){
                [self.errorReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:interstitialPresenter.ad withRequest:nil]];
                HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.FULLSCREEN properties:self.errorReportingProperties];
                [[HyBid reportingManager] reportEventFor:reportingEvent];
            }
        }
        [self.interstitialPresenterDelegate interstitialPresenter:interstitialPresenter didFailWithError:error];
    }
}

- (void)interstitialPresenterDidAppear:(HyBidInterstitialPresenter *)interstitialPresenter {}
- (void)interstitialPresenterDidDisappear:(HyBidInterstitialPresenter *)interstitialPresenter {}

- (void)interstitialPresenterDismissesSKOverlay:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.skoverlay dismissEntirely:YES withAd:interstitialPresenter.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)interstitialPresenterDismissesCustomCTA:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.customCTA) {
        [self.customCTA removeCustomCTA];
    }
}

- (void)interstitialPresenterWillPresentEndCard:(HyBidInterstitialPresenter *)interstitialPresenter skoverlayDelegate:(id<HyBidSKOverlayDelegate>)skoverlayDelegate customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate {
        [self.skoverlay changeDelegateFor:skoverlayDelegate];
        [self.customCTA changeDelegateFor:customCTADelegate];
}

- (void)interstitialPresenterDidPresentCustomEndCard:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self.adTracker trackCustomEndCardImpressionWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
}

- (void)interstitialPresenterDidPresentCustomCTA {
    [self.adTracker trackCustomCTAImpressionWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
}

- (void)interstitialPresenterDidClickCustomCTAOnEndCard:(BOOL)onEndCard {
    [self.adTracker trackCustomCTAClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN onEndCard:onEndCard];
}

- (void)interstitialPresenterDidReplay:(HyBidInterstitialPresenter *)interstitialPresenter
                        viewController:(UIViewController *)viewController {
    [self interstitialPresenterDismissesSKOverlay:interstitialPresenter];
    
    if (self.interstitialPresenter.ad.skoverlayEnabled && [self.interstitialPresenter.ad.skoverlayEnabled boolValue]) {
        self.skoverlay = [[HyBidSKOverlay alloc] initWithAd:interstitialPresenter.ad
                                                 isRewarded:NO
                                                   delegate:interstitialPresenter.skoverlayDelegate];
    }
    
    if ([HyBidCustomCTAView isCustomCTAValidWithAd: interstitialPresenter.ad]) {
        self.customCTA = [[HyBidCustomCTAView alloc] initWithAd:interstitialPresenter.ad
                                                 viewController:viewController
                                                       delegate:interstitialPresenter.customCTADelegate
                                                       adFormat:HyBidReportingAdFormat.FULLSCREEN];
    }
    
    [self interstitialPresenterDidShow:interstitialPresenter];
    [self.adTracker trackReplayClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
}

- (void)impressionDetectedWithView:(UIView *)view {}

@end
