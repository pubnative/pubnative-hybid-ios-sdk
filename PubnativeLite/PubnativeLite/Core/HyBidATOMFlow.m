//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidATOMFlow.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

@implementation HyBidATOMFlow

typedef NS_ENUM(NSInteger, HyBidATOMStatus) {
    HyBidATOMStatusIdle,
    HyBidATOMStatusStopped,
    HyBidATOMStatusStarted
};

static HyBidATOMStatus atomStatus = HyBidATOMStatusIdle;

+ (void)initFlow {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeAtomEnabled:)
                                                 name:@"didChangeAtomEnabledNotification"
                                               object:nil];
    
    if (HyBidConstants.atomEnabled) {
        [self startATOM];
    }
}

+ (void)didChangeAtomEnabled:(NSNotification *)notification {
    BOOL atomEnabled = [notification.userInfo[kStoredATOMState] boolValue];
    if (atomEnabled) {
        if (atomStatus != HyBidATOMStatusStarted) {
            [self startATOM];
        }
    } else {
        if (atomStatus != HyBidATOMStatusStopped) {
            [self stopATOM];
        }
    }
}

// MARK: ATOM Lifecycle
+ (void)startATOM
{
    #if __has_include(<ATOM/ATOM-Swift.h>)
    NSError *atomError = nil;
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    [Atom startWithApiKey:bundleID isTest:NO error:&atomError withCallback:^(BOOL isSuccess) {
        if (isSuccess) {
            NSArray *atomCohorts = [Atom getCohorts];
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: [[NSString alloc] initWithFormat: @"ATOM: Received ATOM cohorts: %@", atomCohorts], NSStringFromSelector(_cmd)]];
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: [[NSString alloc] initWithFormat: @"ATOM: started"], NSStringFromSelector(_cmd)]];
            [self reportHyBidEventWithStatus:HyBidATOMStatusStarted];
            [HyBidReportingManager sharedInstance].isAtomStarted = true;
        } else {
            NSString *atomInitResultMessage = [[NSString alloc] initWithFormat:@"Coultdn't initialize ATOM with error: %@", [atomError localizedDescription]];
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: atomInitResultMessage, NSStringFromSelector(_cmd)]];
        }
    }];
    #endif
}

+ (void)stopATOM
{
    #if __has_include(<ATOM/ATOM-Swift.h>)
    [Atom stopWithCallback:^(BOOL isSuccess) {
        if (isSuccess) {
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: [[NSString alloc] initWithFormat: @"Stopping ATOM"], NSStringFromSelector(_cmd)]];
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: [[NSString alloc] initWithFormat: @"ATOM: stopped"], NSStringFromSelector(_cmd)]];
            [self reportHyBidEventWithStatus:HyBidATOMStatusStopped];
            [HyBidReportingManager sharedInstance].isAtomStarted = false;
        } else {
            NSString *atomStopResultMessage = [[NSString alloc] initWithFormat:@"Coultdn't stop ATOM"];
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: atomStopResultMessage, NSStringFromSelector(_cmd)]];
        }
    }];
    #endif
}

// MARK: Triggering Notification based on atomEnabled value
+ (void)setAtomEnabled:(NSNumber*)enabled {
    if (enabled) {
        BOOL savedATOMState = [[NSUserDefaults standardUserDefaults] boolForKey:kStoredATOMState];
        BOOL remoteConfigATOMState = enabled.intValue >= 0 ? [enabled boolValue] : savedATOMState;
        [self reportReceivedRemoteConfig: (remoteConfigATOMState ? HyBidReportingEventType.ATOM_ACTIVATED_RECEIVED : HyBidReportingEventType.ATOM_DEACTIVATED_RECEIVED)];
        if (savedATOMState != remoteConfigATOMState) {
            [[NSUserDefaults standardUserDefaults] setBool:remoteConfigATOMState forKey:kStoredATOMState];
            [self postAtomEnabledDidChangeNotification:remoteConfigATOMState];
        }
    }
}

+ (void)postAtomEnabledDidChangeNotification:(BOOL)enabled {
    NSDictionary *userInfo = @{kStoredATOMState: @(enabled)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeAtomEnabledNotification"
                                                        object:self
                                                      userInfo:userInfo];
}

// MARK: Reporting events

+ (void)reportHyBidEventWithStatus:(HyBidATOMStatus)status {
    atomStatus = status;
    NSString *reportingType = HyBidReportingEventType.ATOM_DEACTIVATED;
    if (status == HyBidATOMStatusStarted) {
        reportingType = HyBidReportingEventType.ATOM_ACTIVATED;
    }
    HyBidReportingEvent *reportingEvent = [[HyBidReportingEvent alloc] initWith:reportingType adFormat:nil properties:nil];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
}

+ (void)reportReceivedRemoteConfig:(NSString*)name{
    HyBidReportingEvent *reportingEvent = [[HyBidReportingEvent alloc] initWith:name adFormat:nil properties:nil];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
}

@end
