//
//  MPInlineAdAdapter+Private.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdImpressionTimer.h"
#import "MPInlineAdAdapter.h"
#import "MPInlineAdAdapter+MPInlineAdAdapterDelegate.h"
#import "MPTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPInlineAdAdapter () <MPAdImpressionTimerDelegate>

@property (nonatomic, weak, readwrite) id<MPInlineAdAdapterDelegate> delegate; // default is `self`

@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) MPTimer *timeoutTimer;

@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, weak) id<MPAdAdapterBaseDelegate> adapterDelegate;
@property (nonatomic, copy) NSDictionary *localExtras;
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;

- (void)didStopLoading;

- (void)startTimeoutTimer;

- (void)startViewableTrackingTimer;

- (void)trackImpression;
- (void)trackClick;

@end

NS_ASSUME_NONNULL_END
