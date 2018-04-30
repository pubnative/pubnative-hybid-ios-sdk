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

#import "PNLiteSink.h"
#import "PNLiteCrashTracker.h"
#import "PNLiteCollections.h"
#import "PNLiteNotifier.h"
#import "PNLiteKeys.h"
#import "PNLite_KSSystemInfo.h"

// This is private in PNLite, but really we want package private so define
// it here.
@interface PNLiteCrashTracker ()
+ (PNLiteNotifier *)notifier;
@end

@implementation PNLiteSink

- (instancetype)initWithApiClient:(PNLiteErrorReportApiClient *)apiClient {
    if (self = [super init]) {
        self.apiClient = apiClient;
    }
    return self;
}

// Entry point called by PNLite_KSCrash when a report needs to be sent. Handles
// report filtering based on the configuration options for
// `notifyReleaseStages`. Removes all reports not meeting at least one of the
// following conditions:
// - the report-specific config specifies the `notifyReleaseStages` property and
// it contains the current stage
// - the report-specific and global `notifyReleaseStages` properties are unset
// - the report-specific `notifyReleaseStages` property is unset and the global
// `notifyReleaseStages` property
//   and it contains the current stage
- (void)filterReports:(NSArray *)reports
         onCompletion:(PNLite_KSCrashReportFilterCompletion)onCompletion {
    NSMutableArray *pnliteReports = [NSMutableArray new];
    PNLiteConfiguration *configuration = [PNLiteCrashTracker configuration];
    
    for (NSDictionary *report in reports) {
        PNLiteCrashReport *pnliteReport = [[PNLiteCrashReport alloc] initWithKSReport:report];
        BOOL incompleteReport = (![@"standard" isEqualToString:[report valueForKeyPath:@"report.type"]] ||
                                 [[report objectForKey:@"incomplete"] boolValue]);
        
        if (incompleteReport) { // append app/device data as this is unlikely to change between sessions
            NSDictionary *sysInfo = [PNLite_KSSystemInfo systemInfo];
            
            // reset any existing data as it will be corrupted/nil
            pnliteReport.appState = @{};
            pnliteReport.deviceState = @{};


            NSMutableDictionary *appDict = [NSMutableDictionary new];
            PNLiteDictInsertIfNotNil(appDict, sysInfo[@PNLite_KSSystemField_BundleVersion], @"bundleVersion");
            PNLiteDictInsertIfNotNil(appDict, sysInfo[@PNLite_KSSystemField_BundleID], @"id");
            PNLiteDictInsertIfNotNil(appDict, configuration.releaseStage, @"releaseStage");
            PNLiteDictInsertIfNotNil(appDict, sysInfo[@PNLite_KSSystemField_SystemName], @"type");
            PNLiteDictInsertIfNotNil(appDict, sysInfo[@PNLite_KSSystemField_BundleShortVersion], @"version");

            NSMutableDictionary *deviceDict = [NSMutableDictionary new];
            PNLiteDictInsertIfNotNil(deviceDict, sysInfo[@PNLite_KSSystemField_Jailbroken], @"jailbroken");
            PNLiteDictInsertIfNotNil(deviceDict, [[NSLocale currentLocale] localeIdentifier], @"locale");
            PNLiteDictInsertIfNotNil(deviceDict, sysInfo[@"Apple"], @"manufacturer");
            PNLiteDictInsertIfNotNil(deviceDict, sysInfo[@PNLite_KSSystemField_Machine], @"model");
            PNLiteDictInsertIfNotNil(deviceDict, sysInfo[@PNLite_KSSystemField_Model], @"modelNumber");
            PNLiteDictInsertIfNotNil(deviceDict, sysInfo[@PNLite_KSSystemField_SystemName], @"osName");
            PNLiteDictInsertIfNotNil(deviceDict, sysInfo[@PNLite_KSSystemField_SystemVersion], @"osVersion");

            pnliteReport.app = appDict;
            pnliteReport.device = deviceDict;
        }
        
        if (![pnliteReport shouldBeSent])
            continue;
        BOOL shouldSend = YES;
        for (PNLiteBeforeSendBlock block in configuration.beforeSendBlocks) {
            shouldSend = block(report, pnliteReport);
            if (!shouldSend)
                break;
        }
        if (shouldSend) {
            [pnliteReports addObject:pnliteReport];
        }
    }

    if (pnliteReports.count == 0) {
        if (onCompletion) {
            onCompletion(pnliteReports, YES, nil);
        }
        return;
    }

    NSDictionary *reportData = [self getBodyFromReports:pnliteReports];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    for (PNLiteBeforeNotifyHook hook in configuration.beforeNotifyHooks) {
        if (reportData) {
            reportData = hook(reports, reportData);
        } else {
            break;
        }
    }
#pragma clang diagnostic pop

    if (reportData == nil) {
        if (onCompletion) {
            onCompletion(@[], YES, nil);
        }
        return;
    }

    [self.apiClient sendData:pnliteReports
                 withPayload:reportData
                       toURL:configuration.notifyURL
            headers:[configuration errorApiHeaders]
                onCompletion:onCompletion];
}


// Generates the payload for notifying PNLite
- (NSDictionary *)getBodyFromReports:(NSArray *)reports {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    PNLiteDictSetSafeObject(data, [PNLiteCrashTracker notifier].details, PNLiteKeyNotifier);
    PNLiteDictSetSafeObject(data, [PNLiteCrashTracker notifier].configuration.apiKey, PNLiteKeyApiKey);
    PNLiteDictSetSafeObject(data, @"4.0", @"payloadVersion");

    NSMutableArray *formatted =
            [[NSMutableArray alloc] initWithCapacity:[reports count]];

    for (PNLiteCrashReport *report in reports) {
        PNLiteArrayAddSafeObject(formatted, [report toJson]);
    }

    PNLiteDictSetSafeObject(data, formatted, PNLiteKeyEvents);
    return data;
}

@end
