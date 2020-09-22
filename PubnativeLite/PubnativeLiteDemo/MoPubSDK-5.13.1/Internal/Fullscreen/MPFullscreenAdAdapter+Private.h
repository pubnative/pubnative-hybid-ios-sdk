//
//  MPFullscreenAdAdapter+Private.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdAdapterDelegate.h"
#import "MPAdEvent.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAdTargeting.h"
#import "MPAnalyticsTracker.h"
#import "MPCountdownTimerDelegate.h"
#import "MPDiskLRUCache.h"
#import "MPFullscreenAdAdapter.h"
#import "MPFullscreenAdAdapterDelegate.h"
#import "MPFullscreenAdViewController+Web.h"
#import "MPRealTimeTimer.h"
#import "MPTimer.h"
#import "MPVASTTracking.h"
#import "MPVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapter ()

#pragma mark - Common Properties

@property (nonatomic, assign) MPAdContentType adContentType;
@property (nonatomic, strong) MPAdTargeting *targeting;
@property (nonatomic, strong) MPTimer *timeoutTimer;
@property (nonatomic, strong) MPRealTimeTimer *expirationTimer;
@property (nonatomic, assign) BOOL _hasAdAvailable; // for both `MPAdAdapter` and `MPFullscreenAdAdapter`

// Once an ad successfully loads, we want to block sending more successful load events.
@property (nonatomic, assign) BOOL hasSuccessfullyLoaded;

// Since we only notify the application of one success per load, we also only notify the application
// of one expiration per success.
@property (nonatomic, assign) BOOL hasExpired;

@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;
@property (nonatomic, assign) BOOL isUserRewarded;

@property (nonatomic, strong) MPFullscreenAdViewController * _Nullable viewController; // set to nil after dismissal

#pragma mark - (MPAdAdapter) Properties

@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic, copy) NSString *customData;
@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, weak) id<MPAdAdapterFullscreenEventDelegate, MPAdAdapterRewardEventDelegate> adapterDelegate;
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;

#pragma mark - (MPFullscreenAdAdapterDelegate) Properties

@property (nonatomic, weak, readwrite) id<MPFullscreenAdAdapterDelegate> delegate; // default to `self` in `init`
@property (nonatomic, copy) NSDictionary *localExtras;

#pragma mark - (Video) Properties

@property (nonatomic, strong) id<MPAdDestinationDisplayAgent> adDestinationDisplayAgent;
@property (nonatomic, strong) id<MPVASTTracking> vastTracking;
@property (nonatomic, strong) id<MPMediaFileCache> mediaFileCache;
@property (nonatomic, strong) MPVASTMediaFile *remoteMediaFileToPlay;
@property (nonatomic, strong) MPVideoConfig *videoConfig;

#pragma mark - Methods

/**
 This should be called right after `init` for once and only once.
 */
- (void)setUpWithAdConfiguration:(MPAdConfiguration *)adConfiguration localExtras:(NSDictionary *)localExtras;

- (void)startTimeoutTimer;

- (void)didLoadAd;

- (void)didStopLoadingAd;

- (void)handleAdEvent:(MPFullscreenAdEvent)event;

/**
 The original URL comes from the value of "x-rewarded-video-completion-url" in ad response.
 */
- (NSURL *)rewardedVideoCompletionUrlByAppendingClientParams;

/**
 Tracks an impression when called the first time. Any subsequent calls will do nothing.
 */
- (void)trackClick;

/**
 Tracks a click when called the first time. Any subsequent calls will do nothing.
 */
- (void)trackImpression;

@end

#pragma mark -

@interface MPFullscreenAdAdapter (MPCountdownTimerDelegate) <MPCountdownTimerDelegate>
@end

NS_ASSUME_NONNULL_END
