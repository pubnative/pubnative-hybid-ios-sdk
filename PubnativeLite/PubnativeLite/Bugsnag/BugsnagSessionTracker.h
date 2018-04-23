//
//  BugsnagSessionTracker.h
//  Bugsnag
//
//  Created by Jamie Lynch on 24/11/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PNLiteSession.h"
#import "PNLiteConfiguration.h"

@class PNLiteSessionTrackingApiClient;

typedef void (^SessionTrackerCallback)(PNLiteSession *newSession);

@interface BugsnagSessionTracker : NSObject

- (instancetype)initWithConfig:(PNLiteConfiguration *)config
                     apiClient:(PNLiteSessionTrackingApiClient *)apiClient
                      callback:(void(^)(PNLiteSession *))callback;

- (void)startNewSession:(NSDate *)date
               withUser:(PNLiteUser *)user
           autoCaptured:(BOOL)autoCaptured;

- (void)suspendCurrentSession:(NSDate *)date;
- (void)incrementHandledError;
- (void)send;
- (void)onAutoCaptureEnabled;

@property (readonly) PNLiteSession *currentSession;
@property (readonly) BOOL isInForeground;

/**
 * Called when a session is altered
 */
@property SessionTrackerCallback callback;

@end
