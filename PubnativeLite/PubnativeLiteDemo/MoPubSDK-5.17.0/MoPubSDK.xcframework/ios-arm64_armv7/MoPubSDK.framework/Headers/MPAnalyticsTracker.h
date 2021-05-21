//
//  MPAnalyticsTracker.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@class MPAdConfiguration;
@class MPVASTTrackingEvent;

@protocol MPAnalyticsTracker <NSObject>

/**
 Fires all impression tracking URLs associated with @c configuration and tracks
 @c SKAdNetwork @c startImpression on the given @c configuration object.
 @param configuration the ad configuration from which to track the impression metrics
 */
- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration;

/**
 Fires all click tracking URLs associated with @c configuration.
 @param configuration the ad configuration from which to track the click metrics
 */
- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration;

/**
 Fires-and-forgets an array of URLs.
 @c URLs the array of URLs to send requests to.
 */
- (void)sendTrackingRequestForURLs:(NSArray<NSURL *> *)URLs;

/**
 Tracks @c SKAdNetwork @c endImpression for the given @c configuration.
 @param configuration the ad configuration from which to track the impression metrics
 */
- (void)trackEndImpressionForConfiguration:(MPAdConfiguration *)configuration;

/**
 Tracks @c SKAdNetwork @c startImpression for the given @c configuration. Does
 not track impression URLs! Note that @c trackImpressionForConfiguration calls
 @c trackSKAdNetworkStartImpressionForConfiguration automatically, so calling
 this manually after calling @c trackImpressionForConfiguration is redundant
 and possibly unwanted.
 @param configuration the ad configuration from which to track the impression metrics
 */
- (void)trackSKAdNetworkStartImpressionForConfiguration:(MPAdConfiguration *)configuration;

@end

@interface MPAnalyticsTracker : NSObject

+ (MPAnalyticsTracker *)sharedTracker;

@end

@interface MPAnalyticsTracker (MPAnalyticsTracker) <MPAnalyticsTracker>
@end
