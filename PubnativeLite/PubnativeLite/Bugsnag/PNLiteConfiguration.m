//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "PNLiteConfiguration.h"
#import "PNLiteCrashTracker.h"
#import "PNLiteNotifier.h"
#import "PNLiteKeys.h"
#import "PNLite_RFC3339DateTool.h"
#import "PNLiteUser.h"
#import "PNLiteSessionTracker.h"

static NSString *const kPNLiteHeaderApiPayloadVersion = @"Bugsnag-Payload-Version";
static NSString *const kPNLiteHeaderApiKey = @"Bugsnag-Api-Key";
static NSString *const kPNLiteHeaderApiSentAt = @"Bugsnag-Sent-At";

@interface PNLiteCrashTracker ()
+ (PNLiteNotifier *)notifier;
@end

@interface PNLiteNotifier ()
@property PNLiteSessionTracker *sessionTracker;
@end

@interface PNLiteConfiguration ()
@property(nonatomic, readwrite, strong) NSMutableArray *beforeNotifyHooks;
@property(nonatomic, readwrite, strong) NSMutableArray *beforeSendBlocks;
@end

@implementation PNLiteConfiguration

- (id)init {
    if (self = [super init]) {
        _metaData = [[PNLiteMetaData alloc] init];
        _config = [[PNLiteMetaData alloc] init];
        _apiKey = @"";
        _sessionURL = [NSURL URLWithString:@"https://sessions.bugsnag.com"];
        _autoNotify = YES;
        _notifyURL = [NSURL URLWithString:PNLiteDefaultNotifyUrl];
        _beforeNotifyHooks = [NSMutableArray new];
        _beforeSendBlocks = [NSMutableArray new];
        _notifyReleaseStages = nil;
        _breadcrumbs = [PNLiteBreadcrumbs new];
        _automaticallyCollectBreadcrumbs = YES;
        if ([NSURLSession class]) {
            _session = [NSURLSession
                sessionWithConfiguration:[NSURLSessionConfiguration
                                             defaultSessionConfiguration]];
        }
#if DEBUG
        _releaseStage = PNLiteKeyDevelopment;
#else
        _releaseStage = BSGKeyProduction;
#endif
    }
    return self;
}

- (BOOL)shouldSendReports {
    return self.notifyReleaseStages.count == 0 ||
           [self.notifyReleaseStages containsObject:self.releaseStage];
}

- (void)setUser:(NSString *)userId
       withName:(NSString *)userName
       andEmail:(NSString *)userEmail {
    
    self.currentUser = [[PNLiteUser alloc] initWithUserId:userId name:userName emailAddress:userEmail];

    [self.metaData addAttribute:PNLiteKeyId withValue:userId toTabWithName:PNLiteKeyUser];
    [self.metaData addAttribute:PNLiteKeyName
                      withValue:userName
                  toTabWithName:PNLiteKeyUser];
    [self.metaData addAttribute:PNLiteKeyEmail
                      withValue:userEmail
                  toTabWithName:PNLiteKeyUser];
}

- (void)addBeforeSendBlock:(PNLiteBeforeSendBlock)block {
    [(NSMutableArray *)self.beforeSendBlocks addObject:[block copy]];
}

- (void)clearBeforeSendBlocks {
    [(NSMutableArray *)self.beforeSendBlocks removeAllObjects];
}

- (void)addBeforeNotifyHook:(PNLiteBeforeNotifyHook)hook {
    [(NSMutableArray *)self.beforeNotifyHooks addObject:[hook copy]];
}

@synthesize releaseStage = _releaseStage;

- (NSString *)releaseStage {
    @synchronized (self) {
        return _releaseStage;
    }
}

- (void)setReleaseStage:(NSString *)newReleaseStage {
    @synchronized (self) {
        _releaseStage = newReleaseStage;
        [self.config addAttribute:PNLiteKeyReleaseStage
                        withValue:newReleaseStage
                    toTabWithName:PNLiteKeyConfig];
    }
}

@synthesize notifyReleaseStages = _notifyReleaseStages;

- (NSArray *)notifyReleaseStages {
    @synchronized (self) {
        return _notifyReleaseStages;
    }
}

- (void)setNotifyReleaseStages:(NSArray *)newNotifyReleaseStages;
{
    @synchronized (self) {
        NSArray *notifyReleaseStagesCopy = [newNotifyReleaseStages copy];
        _notifyReleaseStages = notifyReleaseStagesCopy;
        [self.config addAttribute:PNLiteKeyNotifyReleaseStages
                        withValue:notifyReleaseStagesCopy
                    toTabWithName:PNLiteKeyConfig];
    }
}

@synthesize automaticallyCollectBreadcrumbs = _automaticallyCollectBreadcrumbs;

- (BOOL)automaticallyCollectBreadcrumbs {
    @synchronized (self) {
        return _automaticallyCollectBreadcrumbs;
    }
}

- (void)setAutomaticallyCollectBreadcrumbs:
    (BOOL)automaticallyCollectBreadcrumbs {
    @synchronized (self) {
        if (automaticallyCollectBreadcrumbs == _automaticallyCollectBreadcrumbs)
            return;

        _automaticallyCollectBreadcrumbs = automaticallyCollectBreadcrumbs;
        [[PNLiteCrashTracker notifier] updateAutomaticBreadcrumbDetectionSettings];
    }
}

@synthesize context = _context;

- (NSString *)context {
    @synchronized (self) {
        return _context;
    }
}

- (void)setContext:(NSString *)newContext {
    @synchronized (self) {
        _context = newContext;
        [self.config addAttribute:PNLiteKeyContext
                        withValue:newContext
                    toTabWithName:PNLiteKeyConfig];
    }
}

@synthesize appVersion = _appVersion;

- (NSString *)appVersion {
    @synchronized (self) {
        return _appVersion;
    }
}

- (void)setAppVersion:(NSString *)newVersion {
    @synchronized (self) {
        _appVersion = newVersion;
        [self.config addAttribute:PNLiteKeyAppVersion
                        withValue:newVersion
                    toTabWithName:PNLiteKeyConfig];
    }
}

@synthesize shouldAutoCaptureSessions = _shouldAutoCaptureSessions;

- (BOOL)shouldAutoCaptureSessions {
    return _shouldAutoCaptureSessions;
}

- (void)setShouldAutoCaptureSessions:(BOOL)shouldAutoCaptureSessions {
    @synchronized (self) {
        _shouldAutoCaptureSessions = shouldAutoCaptureSessions;
        
        if (shouldAutoCaptureSessions) { // track any existing sessions
            PNLiteSessionTracker *sessionTracker = [PNLiteCrashTracker notifier].sessionTracker;
            [sessionTracker onAutoCaptureEnabled];
        }
    }
}

- (NSDictionary *)errorApiHeaders {
    return @{
             kPNLiteHeaderApiPayloadVersion: @"4.0",
             kPNLiteHeaderApiKey: self.apiKey,
             kPNLiteHeaderApiSentAt: [PNLite_RFC3339DateTool stringFromDate:[NSDate new]]
    };
}

- (NSDictionary *)sessionApiHeaders {
    return @{
             kPNLiteHeaderApiPayloadVersion: @"1.0",
             kPNLiteHeaderApiKey: self.apiKey,
             kPNLiteHeaderApiSentAt: [PNLite_RFC3339DateTool stringFromDate:[NSDate new]]
             };
}
@end
