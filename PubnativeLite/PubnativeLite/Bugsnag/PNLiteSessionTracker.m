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

#import "PNLiteSessionTracker.h"
#import "PNLiteSessionFileStore.h"
#import "BSG_KSLogger.h"
#import "BugsnagSessionTrackingPayload.h"
#import "PNLiteSessionTrackingApiClient.h"

@interface PNLiteSessionTracker ()
@property PNLiteConfiguration *config;
@property PNLiteSessionFileStore *sessionStore;
@property PNLiteSessionTrackingApiClient *apiClient;
@property BOOL trackedFirstSession;
@end

@implementation PNLiteSessionTracker

- (instancetype)initWithConfig:(PNLiteConfiguration *)config
                     apiClient:(PNLiteSessionTrackingApiClient *)apiClient
                      callback:(void(^)(PNLiteSession *))callback {
    if (self = [super init]) {
        _config = config;
        _apiClient = apiClient;
        _callback = callback;

        NSString *bundleName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
        NSString *storePath = [BugsnagFileStore findReportStorePath:@"Sessions"
                                                         bundleName:bundleName];
        if (!storePath) {
            BSG_KSLOG_ERROR(@"Failed to initialize session store.");
        }
        _sessionStore = [PNLiteSessionFileStore storeWithPath:storePath];
    }
    return self;
}

- (void)startNewSession:(NSDate *)date
               withUser:(PNLiteUser *)user
           autoCaptured:(BOOL)autoCaptured {

    _currentSession = [[PNLiteSession alloc] initWithId:[[NSUUID UUID] UUIDString]
                                                startDate:date
                                                     user:user
                                             autoCaptured:autoCaptured];

    if ((self.config.shouldAutoCaptureSessions || !autoCaptured) && [self.config shouldSendReports]) {
        [self trackSession];
    }
    _isInForeground = YES;
}

- (void)trackSession {
    [self.sessionStore write:self.currentSession];
    self.trackedFirstSession = YES;
    
    if (self.callback) {
        self.callback(self.currentSession);
    }
}

- (void)onAutoCaptureEnabled {
    if (!self.trackedFirstSession) {
        if (self.currentSession == nil) { // unlikely case, will be initialised later
            return;
        }
        [self trackSession];
    }
}

- (void)suspendCurrentSession:(NSDate *)date {
    _isInForeground = NO;
}

- (void)incrementHandledError {
    @synchronized (self.currentSession) {
        self.currentSession.handledCount++;
        if (self.callback && (self.config.shouldAutoCaptureSessions || !self.currentSession.autoCaptured)) {
            self.callback(self.currentSession);
        }
    }
}

- (void)send {
    @synchronized (self.sessionStore) {
        NSMutableArray *sessions = [NSMutableArray new];
        NSArray *fileIds = [self.sessionStore fileIds];

        for (NSDictionary *dict in [self.sessionStore allFiles]) {
            [sessions addObject:[[PNLiteSession alloc] initWithDictionary:dict]];
        }
        BugsnagSessionTrackingPayload *payload = [[BugsnagSessionTrackingPayload alloc] initWithSessions:sessions];

        if (payload.sessions.count > 0) {
            [self.apiClient sendData:payload
                         withPayload:[payload toJson]
                               toURL:self.config.sessionURL
                             headers:self.config.sessionApiHeaders
                        onCompletion:^(id data, BOOL success, NSError *error) {

                            if (success && error == nil) {
                                NSLog(@"Sent sessions to Bugsnag");

                                for (NSString *fileId in fileIds) {
                                    [self.sessionStore deleteFileWithId:fileId];
                                }
                            } else {
                                NSLog(@"Failed to send sessions to Bugsnag: %@", error);
                            }
                        }];
        }
    }
}

@end
