// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteAdPresenterDecorator.h"
#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"
#import "PNLiteImpressionTracker.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteAdPresenterDecorator () <PNLiteImpressionTrackerDelegate,PercentVisibleDelegate>

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, weak) NSObject<HyBidAdPresenterDelegate> *adPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) PNLiteImpressionTracker *impressionTracker;
@property (nonatomic, strong) UIView *trackedView;
@property (nonatomic, assign) BOOL videoStarted;
@property (nonatomic, assign) BOOL impressionConfirmed;

@end

NSString * const kUserDefaultsHyBidPreviousBannerPresenterDecoratorKey = @"kUserDefaultsHyBidPreviousBannerPresenterDecorator";

@implementation PNLiteAdPresenterDecorator

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] setValue:self.description forKeyPath:kUserDefaultsHyBidPreviousBannerPresenterDecoratorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self stopTracking];
    self.adPresenter = nil;
    self.adTracker = nil;
    self.adPresenterDelegate = nil;
    self.errorReportingProperties = nil;
    if (self.impressionTracker) {
        [self.impressionTracker clear];
    }
    self.impressionTracker = nil;
    self.trackedView = nil;
    self.videoStarted = NO;
    self.impressionConfirmed = NO;
}

- (void)load {
    [self.adPresenter load];
}

- (void)loadMarkupWithSize:(HyBidAdSize *)adSize {
    [self.adPresenter loadMarkupWithSize:adSize];
}

- (void)startTracking {
    if(self.adPresenter.ad.adType != kHyBidAdTypeVideo) {
        [self.adPresenter startTracking];
    }
}

- (void)stopTracking {
    if (self.impressionTracker) {
        [self.impressionTracker clear];
    }
    self.impressionTracker = nil;
    
    [self.adPresenter stopTracking];
}

- (instancetype)initWithAdPresenter:(HyBidAdPresenter *)adPresenter
                      withAdTracker:(HyBidAdTracker *)adTracker
                       withDelegate:(NSObject<HyBidAdPresenterDelegate> *)delegate{
    self = [super init];
    if (self) {
        self.adPresenter = adPresenter;
        self.adTracker = adTracker;
        self.adPresenterDelegate = delegate;
        self.errorReportingProperties = [NSMutableDictionary new];
        self.videoStarted = NO;
        self.impressionConfirmed = NO;
    }
    return self;
}

#pragma mark HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    self.trackedView = adView;
    if(!self.impressionTracker) {
        self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
        self.impressionTracker.visibilityTracker.visibilityDelegate = self;
        [self.impressionTracker determineViewbilityRemoteConfig:self.adPresenter.ad];
        self.impressionTracker.delegate = self;
    }
    if (self.trackedView) {
        if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerViewable) {
            [self.impressionTracker addView:self.trackedView];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression could not be fired - Tracked view not available"];
    }
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenter:didLoadWithAd:)]) {
        [self.adPresenterDelegate adPresenter:adPresenter didLoadWithAd:adView];
        if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerRender) {
            [self impressionDetectedWithView:self.trackedView];
        }
    }
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidClick:)]) {
        if (self.adPresenter.ad.shouldReportCustomEndcardImpression) {
            [self.adTracker trackCustomEndCardClickWithAdFormat:HyBidReportingAdFormat.BANNER];
        } else {
            [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.BANNER];
        }
        [self.adPresenterDelegate adPresenterDidClick:adPresenter];
    }
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenter:didFailWithError:)]) {
        if ([HyBidSDKConfig sharedConfig].reporting) {
            if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
                [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
            }
            if(self.errorReportingProperties) {
                [self.errorReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:adPresenter.ad withRequest:nil]];
                
                HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.BANNER properties:self.errorReportingProperties];
                [[HyBid reportingManager] reportEventFor:reportingEvent];
            }
        }
        [self.adPresenterDelegate adPresenter:adPresenter didFailWithError:error];
    }
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter {
    self.videoStarted = YES;
    if (!self.videoStarted || !self.impressionConfirmed) {return;}
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] && !self.adTracker.impressionTracked && self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerViewable) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
    }
}

- (void)adPresenterDidAppear:(HyBidAdPresenter *)adPresenter {
    // in case impressionTrackingMethod is render, we trigger adPresenterDidStartPlaying which will fire impression.
    if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerRender && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] ) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
    }
}

- (void)adPresenterDidDisappear:(HyBidAdPresenter *)adPresenter {
    
}

- (void)adPresenterDidPresentCustomEndCard:(HyBidAdPresenter *)adPresenter {
    if (self.adPresenter.ad.shouldReportCustomEndcardImpression) {
        [self.adTracker trackCustomEndCardImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
    }
}

- (void)adPresenterDidReplay {
    [self.adTracker trackReplayClickWithAdFormat:HyBidReportingAdFormat.BANNER];
}

#pragma mark PNLiteImpressionTrackerDelegate

- (void)impressionDetectedWithView:(UIView *)view {
    if (self.adPresenter.ad.adType != kHyBidAdTypeVideo && !self.adTracker.impressionTracked) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        if ([self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] ) {
            [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
        }
    } else {
        self.impressionConfirmed = YES;
        if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] && !self.adTracker.impressionTracked) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.adPresenter startTracking];
            });
        }
    }
}

- (void)percentVisibleDidChange:(CGFloat)newValue {
    self.adPresenter.adSessionData.viewability = [NSNumber numberWithFloat:newValue];
    if(self.adPresenter.adSessionData !=  nil) {
        [ATOMManager fireAdSessionEventWithData:self.adPresenter.adSessionData];
    }
}

@end
