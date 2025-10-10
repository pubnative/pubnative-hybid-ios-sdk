// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteRewardedPresenterDecorator.h"
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

@interface PNLiteRewardedPresenterDecorator() <PNLiteImpressionTrackerDelegate>

@property (nonatomic, strong) HyBidRewardedPresenter *rewardedPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic) NSObject<HyBidRewardedPresenterDelegate> *rewardedPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) HyBidSKOverlay *skOverlay;
@property (nonatomic, strong) PNLiteImpressionTracker *impressionTracker;
@property (nonatomic, strong) HyBidCustomCTAView *customCTA;

@end

@implementation PNLiteRewardedPresenterDecorator

- (void)dealloc {
    self.rewardedPresenter = nil;
    self.adTracker = nil;
    self.rewardedPresenterDelegate = nil;
    self.errorReportingProperties = nil;
    self.skOverlay = nil;
    self.customCTA = nil;
    self.skOverlayDelegate = nil;
}

- (void)load {
    [self.rewardedPresenter load];
}

- (void)show {
    [self.rewardedPresenter show];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [self.rewardedPresenter showFromViewController:viewController];
}

- (void)hideFromViewController:(UIViewController *)viewController {
    [self.rewardedPresenter hideFromViewController:viewController];
}

- (instancetype)initWithRewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.rewardedPresenter = rewardedPresenter;
        self.adTracker = adTracker;
        self.rewardedPresenterDelegate = delegate;
        self.errorReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark HyBidRewardedPresenterDelegate

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidLoad:)]) {
        if (self.rewardedPresenter.ad.skOverlayEnabled) {
            if ([self.rewardedPresenter.ad.skOverlayEnabled boolValue]) {
                self.skOverlay = [[HyBidSKOverlay alloc] initWithAd:rewardedPresenter.ad
                                                         isRewarded:YES
                                                           delegate:rewardedPresenter.skOverlayDelegate];
            }
        } 
        [self.rewardedPresenterDelegate rewardedPresenterDidLoad:rewardedPresenter];
        
        if(!self.impressionTracker) {
            self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
            [self.impressionTracker determineViewbilityRemoteConfig:rewardedPresenter.ad];
        }
        
        if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerRender) {
            [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.REWARDED];
        }
    }
}

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter viewController:(UIViewController *)viewController {
    [self rewardedPresenterDidLoad:rewardedPresenter];
    if ([HyBidCustomCTAView isCustomCTAValidWithAd: rewardedPresenter.ad]) {
        self.customCTA = [[HyBidCustomCTAView alloc] initWithAd:rewardedPresenter.ad viewController: viewController delegate:rewardedPresenter.customCTADelegate adFormat:HyBidReportingAdFormat.REWARDED];
    }
}

- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidShow:)]) {
        
        if (!self.adTracker.impressionTracked) {
            [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.REWARDED];
            [self.rewardedPresenterDelegate rewardedPresenterDidShow:rewardedPresenter];
        }

        [self.skOverlay addObservers];
        [self.skOverlay presentWithAd:rewardedPresenter.ad];
        [self.customCTA presentCustomCTAWithDelay];
    }
}

- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidClick:)]) {
        if (self.rewardedPresenter.ad.shouldReportCustomEndcardImpression) {
            [self.adTracker trackCustomEndCardClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
        } else {
            [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
        }
        [self.rewardedPresenterDelegate rewardedPresenterDidClick:rewardedPresenter];
    }
}

- (void)rewardedPresenterDidSKOverlayAutomaticClick:(HyBidRewardedPresenter *)rewardedPresenter clickType:(HyBidSKOverlayAutomaticCLickType)clickType {
    
    switch(clickType){
        case HyBidSKOverlayAutomaticCLickVideo:
            [self.adTracker trackSKOverlayAutomaticClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
            break;
        case HyBidSKOverlayAutomaticCLickDefaultEndCard:
            [self.adTracker trackSKOverlayAutomaticDefaultEndCardClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
            break;
        case HyBidSKOverlayAutomaticCLickCustomEndCard:
            [self.adTracker trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
            break;
    }
}

- (void)rewardedPresenterDidStorekitAutomaticClick:(HyBidRewardedPresenter *)rewardedPresenter clickType:(HyBidStorekitAutomaticClickType)clickType {
    
    switch(clickType){
        case HyBidStorekitAutomaticClickVideo:
            [self.adTracker trackStorekitAutomaticClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
            break;
        case HyBidStorekitAutomaticClickDefaultEndCard:
            [self.adTracker trackStorekitAutomaticDefaultEndCardClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
            break;
        case HyBidStorekitAutomaticClickCustomEndCard:
            [self.adTracker trackStorekitAutomaticCustomEndCardClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
            break;
    }
}

- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidDismiss:)]) {
        if ([HyBidSDKConfig sharedConfig].reporting) {
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.REWARDED_CLOSED adFormat:HyBidReportingAdFormat.REWARDED properties:nil];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
        [self.rewardedPresenterDelegate rewardedPresenterDidDismiss:rewardedPresenter];
        [self.skOverlay dismissEntirely:YES withAd:rewardedPresenter.ad causedByAutoCloseTimerCompletion:NO];
    }
    
    if (self.customCTA) {
        [self.customCTA removeCustomCTA];
    }
}

- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter
{
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidFinish:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidFinish:rewardedPresenter];
    }
}

- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter didFailWithError:(NSError *)error {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenter:didFailWithError:)]) {
        if ([HyBidSDKConfig sharedConfig].reporting) {
            if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
                [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
            }
            if(self.errorReportingProperties){
                [self.errorReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:rewardedPresenter.ad withRequest:nil]];
                
                HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.REWARDED properties:self.errorReportingProperties];
                [[HyBid reportingManager] reportEventFor:reportingEvent];
            }
        }
        [self.rewardedPresenterDelegate rewardedPresenter:rewardedPresenter didFailWithError:error];
    }
}

- (void)rewardedPresenterDidAppear:(HyBidRewardedPresenter *)rewardedPresenter {}
- (void)rewardedPresenterDidDisappear:(HyBidRewardedPresenter *)rewardedPresenter {}

- (void)rewardedPresenterDismissesSKOverlay:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.skOverlay dismissEntirely:YES withAd:rewardedPresenter.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)rewardedPresenterDismissesCustomCTA:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.customCTA) {
        [self.customCTA removeCustomCTA];
    }
}

- (void)rewardedPresenteWillPresentEndCard:(HyBidRewardedPresenter *)rewardedPresenter
                         skOverlayDelegate:(id<HyBidSKOverlayDelegate>)skOverlayDelegate
                         customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate {
    [self.skOverlay changeDelegateFor:skOverlayDelegate];
    [self.customCTA changeDelegateFor:customCTADelegate];
}

- (void)rewardedPresenterDidPresentCustomEndCard:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.adTracker trackCustomEndCardImpressionWithAdFormat:HyBidReportingAdFormat.REWARDED];
}

- (void)rewardedPresenterDidPresentsCustomCTA {
    [self.adTracker trackCustomCTAImpressionWithAdFormat:HyBidReportingAdFormat.REWARDED];
}

- (void)rewardedPresenterDidClickCustomCTAOnEndCard:(BOOL)OnEndCard {
    [self.adTracker trackCustomCTAClickWithAdFormat:HyBidReportingAdFormat.REWARDED onEndCard:OnEndCard];
}

- (void)rewardedPresenterDidReplay:(HyBidRewardedPresenter *)rewardedPresenter viewController:(UIViewController *)viewController {
    [self rewardedPresenterDismissesSKOverlay:rewardedPresenter];
    
    if (self.rewardedPresenter.ad.skOverlayEnabled && [self.rewardedPresenter.ad.skOverlayEnabled boolValue]) {
        self.skOverlay = [[HyBidSKOverlay alloc] initWithAd:rewardedPresenter.ad
                                                 isRewarded:YES
                                                   delegate:rewardedPresenter.skOverlayDelegate];
    }
    
    if ([HyBidCustomCTAView isCustomCTAValidWithAd: rewardedPresenter.ad]) {
        self.customCTA = [[HyBidCustomCTAView alloc] initWithAd:rewardedPresenter.ad viewController: viewController delegate:rewardedPresenter.customCTADelegate adFormat:HyBidReportingAdFormat.REWARDED];
    }
    
    [self rewardedPresenterDidShow:rewardedPresenter];
    [self.adTracker trackReplayClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
}

- (void)impressionDetectedWithView:(UIView *)view {}

@end
