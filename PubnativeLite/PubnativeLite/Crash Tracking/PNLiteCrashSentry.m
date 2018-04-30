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

#import "PNLite_KSCrashAdvanced.h"
#import "PNLite_KSCrashC.h"

#import "PNLiteCrashSentry.h"
#import "PNLiteCrashLogger.h"
#import "PNLiteSink.h"

NSUInteger const PNLITE_MAX_STORED_REPORTS = 12;

@implementation PNLiteCrashSentry

- (void)install:(PNLiteConfiguration *)config
      apiClient:(PNLiteErrorReportApiClient *)apiClient
        onCrash:(PNLite_KSReportWriteCallback)onCrash {

    PNLiteSink *sink = [[PNLiteSink alloc] initWithApiClient:apiClient];
    [PNLite_KSCrash sharedInstance].sink = sink;
    [PNLite_KSCrash sharedInstance].introspectMemory = YES;
    [PNLite_KSCrash sharedInstance].deleteBehaviorAfterSendAll =
        PNLite_KSCDeleteOnSucess;
    [PNLite_KSCrash sharedInstance].onCrash = onCrash;
    [PNLite_KSCrash sharedInstance].maxStoredReports = PNLITE_MAX_STORED_REPORTS;
    [PNLite_KSCrash sharedInstance].demangleLanguages = 0;

    if (!config.autoNotify) {
        bsg_kscrash_setHandlingCrashTypes(PNLite_KSCrashTypeUserReported);
    }
    if (![[PNLite_KSCrash sharedInstance] install]) {
        pnlite_log_err(@"Failed to install crash handler. No exceptions will be "
                    @"reported!");
    }

    [sink.apiClient flushPendingData];
}

- (void)reportUserException:(NSString *)reportName
                     reason:(NSString *)reportMessage {

    [[PNLite_KSCrash sharedInstance] reportUserException:reportName
                                               reason:reportMessage
                                             language:NULL
                                           lineOfCode:@""
                                           stackTrace:@[]
                                     terminateProgram:NO];
}

@end
