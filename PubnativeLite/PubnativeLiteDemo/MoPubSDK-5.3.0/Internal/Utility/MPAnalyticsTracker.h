//
//  MPAnalyticsTracker.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdConfiguration;

@interface MPAnalyticsTracker : NSObject

+ (MPAnalyticsTracker *)sharedTracker;

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration;
- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration;
- (void)sendTrackingRequestForURLs:(NSArray *)URLs;

@end
