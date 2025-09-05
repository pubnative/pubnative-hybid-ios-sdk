// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
    if ([HyBidSDKConfig sharedConfig].atomEnabled) {
        [self startATOM];
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
            SEL selector = NSSelectorFromString(@"getCohortsWithCompletion:");
            if ([Atom respondsToSelector:selector]) {
                [Atom performSelector:selector withObject:^(NSArray<ATOMCohort *> *cohorts) {
                    [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"ATOM: Received ATOM cohorts: %@", cohorts]];
                }];
            }
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"ATOM: started"]];
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
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Stopping ATOM"]];
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"ATOM: stopped"]];
            [self reportHyBidEventWithStatus:HyBidATOMStatusStopped];
            [HyBidReportingManager sharedInstance].isAtomStarted = false;
        } else {
            NSString *atomStopResultMessage = [[NSString alloc] initWithFormat:@"Coultdn't stop ATOM"];
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: atomStopResultMessage, NSStringFromSelector(_cmd)]];
        }
    }];
    #endif
}

// MARK: Reporting events

+ (void)reportHyBidEventWithStatus:(HyBidATOMStatus)status {
    atomStatus = status;
    NSString *reportingType = HyBidReportingEventType.ATOM_DEACTIVATED;
    if (status == HyBidATOMStatusStarted) {
        reportingType = HyBidReportingEventType.ATOM_ACTIVATED;
    }
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent *reportingEvent = [[HyBidReportingEvent alloc] initWith:reportingType adFormat:nil properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

+ (void)reportReceivedRemoteConfig:(NSString*)name{
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent *reportingEvent = [[HyBidReportingEvent alloc] initWith:name adFormat:nil properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

@end
