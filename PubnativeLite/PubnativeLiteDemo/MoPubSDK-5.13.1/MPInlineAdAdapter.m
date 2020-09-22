//
//  MPInlineAdAdapter.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapter+Internal.h"
#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPInlineAdAdapter+Private.h"

#import "MPAnalyticsTracker.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"
#import "MPError.h"
#import "MPLogging.h"

static CGFloat const kDefaultRequiredPixelsInViewForImpression         = 1.0;
static NSTimeInterval const kDefaultRequiredSecondsInViewForImpression = 0.0;

#pragma mark -

@implementation MPInlineAdAdapter

- (void)dealloc
{
    if ([self respondsToSelector:@selector(invalidate)]) {
        // Secret API to allow us to detach the adapter from (shared instance) routers synchronously
        [self performSelector:@selector(invalidate)];
    }
    
    [self.timeoutTimer invalidate];
}

- (instancetype)init {
    if (self = [super init]) {
        _delegate = self;
        self.analyticsTracker = [MPAnalyticsTracker sharedTracker];
    }
    
    return self;
}

- (void)trackImpression {
    // ensures the impression is tracked only once
    if (self.hasTrackedImpression) {
        return;
    }
    
    self.hasTrackedImpression = YES;
    
    [self.analyticsTracker trackImpressionForConfiguration:self.configuration];
    
    // Notify delegate that an impression tracker was fired
    [self.adapterDelegate adDidReceiveImpressionEventForAdapter:self];
}

- (void)trackClick {
    // ensures the click is tracked only once
    if (self.hasTrackedClick) {
        return;
    }
    
    self.hasTrackedClick = YES;
    [self.analyticsTracker trackClickForConfiguration:self.configuration];
}

#pragma mark - Requesting Ads

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
    self.configuration.adTimeoutInterval : BANNER_TIMEOUT_INTERVAL;
    
    if (timeInterval > 0) {
        __typeof__(self) __weak weakSelf = self;
        self.timeoutTimer = [MPTimer timerWithTimeInterval:timeInterval repeats:NO block:^(MPTimer * _Nonnull timer) {
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf timeout];
        }];
        [self.timeoutTimer scheduleNow];
    }
}

- (void)timeout
{
    NSError * error = [NSError errorWithCode:MOPUBErrorAdRequestTimedOut
                           localizedDescription:@"Banner ad request timed out"];
    [self.adapterDelegate adapter:self didFailToLoadAdWithError:error];
}

#pragma mark - 1px impression tracking methods

- (void)startViewableTrackingTimer
{
    // Use defaults if server did not send values
    NSTimeInterval minimumSecondsForImpression = self.configuration.impressionMinVisibleTimeInSec >= 0 ? self.configuration.impressionMinVisibleTimeInSec : kDefaultRequiredSecondsInViewForImpression;
    CGFloat minimumPixelsForImpression = self.configuration.impressionMinVisiblePixels >= 0 ? self.configuration.impressionMinVisiblePixels : kDefaultRequiredPixelsInViewForImpression;
    
    self.impressionTimer = [[MPAdImpressionTimer alloc] initWithRequiredSecondsForImpression:minimumSecondsForImpression
                                                                requiredViewVisibilityPixels:minimumPixelsForImpression];
    self.impressionTimer.delegate = self;
    [self.impressionTimer startTrackingView:self.adView];
}

#pragma mark - MPAdImpressionTimerDelegate

- (void)adViewWillLogImpression:(UIView *)adView
{
    // Track impression for all impression trackers known by the SDK
    [self trackImpression];
    // Track impression for all impression trackers included in the markup
    [self trackImpressionsIncludedInMarkup];
    // Start viewability tracking
    [self startViewabilityTracker];
}

@end

#pragma mark -

@implementation MPInlineAdAdapter (MPInlineAdAdapter)

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load a banner here.
}

- (void)didDisplayAd
{
    // The default implementation of this method does nothing. Subclasses may override this method
    // to be notified when the ad is actually displayed on screen.
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Subclasses may override this method to return NO to perform impression and click tracking
    // manually.
    return YES;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    // The default implementation of this method does nothing. Subclasses may override this method
    // to be notified when the parent MPAdView receives -rotateToOrientation: calls.
}

@end
