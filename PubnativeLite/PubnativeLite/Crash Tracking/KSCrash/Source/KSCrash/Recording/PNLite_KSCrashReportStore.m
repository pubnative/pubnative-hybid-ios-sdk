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

#import "PNLite_KSCrashReportStore.h"

#import "PNLite_KSCrashDoctor.h"
#import "PNLite_KSCrashReportFields.h"
#import "PNLite_KSSafeCollections.h"
#import "PNLite_RFC3339DateTool.h"
#import "NSDictionary+PNLite_Merge.h"
#import "PNLite_KSLogger.h"

static NSString *const kPNLiteCrashReportSuffix = @"-CrashReport-";
#define PNLite_kRecrashReportSuffix @"-RecrashReport-"

@implementation PNLite_KSCrashReportStore

#pragma mark Properties

@synthesize demangleSwift = _demangleSwift;
@synthesize demangleCPP = _demangleCPP;

+ (PNLite_KSCrashReportStore *)storeWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path
                       filenameSuffix:kPNLiteCrashReportSuffix];
}

- (instancetype)initWithPath:(NSString *)path
              filenameSuffix:(NSString *)filenameSuffix {
    if ((self = [super initWithPath:path filenameSuffix:filenameSuffix])) {
        self.demangleCPP = YES;
        self.demangleSwift = YES;
    }
    return self;
}

- (NSString *)recrashReportFilenameWithID:(NSString *)reportID {
    return [NSString stringWithFormat:@"%@"
                                              PNLite_kRecrashReportSuffix
                                              "%@.json",
                                      self.bundleName, reportID];
}

- (NSString *)pathToRecrashReportWithID:(NSString *)reportID {
    NSString *filename = [self recrashReportFilenameWithID:reportID];
    return [self.path stringByAppendingPathComponent:filename];
}

- (NSString *)getReportType:(NSDictionary *)report {
    NSDictionary *reportSection = report[@PNLite_KSCrashField_Report];
    if (reportSection) {
        return reportSection[@PNLite_KSCrashField_Type];
    }
    PNLite_KSLOG_ERROR(@"Expected a report section in the report.");
    return nil;
}


- (void)deleteFileWithId:(NSString *)fileId {
    [super deleteFileWithId:fileId];
    NSError *error = nil;

    // Don't care if this succeeds or not since it may not exist.
    [[NSFileManager defaultManager]
            removeItemAtPath:[self pathToRecrashReportWithID:fileId]
                       error:&error];
}


- (NSDictionary *)fileWithId:(NSString *)fileId {
    NSDictionary *dict = [super fileWithId:fileId];

    if (dict != nil) {
        return dict;
    } else {
        NSMutableDictionary *fileContents = [NSMutableDictionary new];
        NSMutableDictionary *recrashReport =
                [self readFile:[self pathToRecrashReportWithID:fileId] error:nil];
        [fileContents bsg_ksc_setObjectIfNotNil:recrashReport
                                         forKey:@PNLite_KSCrashField_RecrashReport];
        return fileContents;
    }
}


- (NSMutableDictionary *)fixupCrashReport:(NSDictionary *)report {
    if (![report isKindOfClass:[NSDictionary class]]) {
        PNLite_KSLOG_ERROR(@"Report should be a dictionary, not %@",
                [report class]);
        return nil;
    }

    NSMutableDictionary *mutableReport = [report mutableCopy];
    NSMutableDictionary *mutableInfo =
            [report[@PNLite_KSCrashField_Report] mutableCopy];
    [mutableReport bsg_ksc_setObjectIfNotNil:mutableInfo
                                      forKey:@PNLite_KSCrashField_Report];

    // Timestamp gets stored as a unix timestamp. Convert it to rfc3339.
    [self convertTimestamp:@PNLite_KSCrashField_Timestamp inReport:mutableInfo];

    [self mergeDictWithKey:@PNLite_KSCrashField_SystemAtCrash
           intoDictWithKey:@PNLite_KSCrashField_System
                  inReport:mutableReport];

    [self mergeDictWithKey:@PNLite_KSCrashField_UserAtCrash
           intoDictWithKey:@PNLite_KSCrashField_User
                  inReport:mutableReport];

    NSMutableDictionary *crashReport =
            [report[@PNLite_KSCrashField_Crash] mutableCopy];
    [mutableReport bsg_ksc_setObjectIfNotNil:crashReport
                                      forKey:@PNLite_KSCrashField_Crash];
    PNLite_KSCrashDoctor *doctor = [PNLite_KSCrashDoctor doctor];
    [crashReport bsg_ksc_setObjectIfNotNil:[doctor diagnoseCrash:report]
                                    forKey:@PNLite_KSCrashField_Diagnosis];

    return mutableReport;
}

- (void)mergeDictWithKey:(NSString *)srcKey
         intoDictWithKey:(NSString *)dstKey
                inReport:(NSMutableDictionary *)report {
    NSDictionary *srcDict = report[srcKey];
    if (srcDict == nil) {
        // It's OK if the source dict didn't exist.
        return;
    }

    NSDictionary *dstDict = report[dstKey];
    if (dstDict == nil) {
        dstDict = [NSDictionary dictionary];
    }
    if (![dstDict isKindOfClass:[NSDictionary class]]) {
        PNLite_KSLOG_ERROR(@"'%@' should be a dictionary, not %@", dstKey,
                [dstDict class]);
        return;
    }

    [report bsg_ksc_setObjectIfNotNil:[srcDict bsg_mergedInto:dstDict]
                               forKey:dstKey];
    [report removeObjectForKey:srcKey];
}

- (void)convertTimestamp:(NSString *)key
                inReport:(NSMutableDictionary *)report {
    NSNumber *timestamp = report[key];
    if (timestamp == nil) {
        PNLite_KSLOG_ERROR(@"entry '%@' not found", key);
        return;
    }
    [report
            setValue:[PNLite_RFC3339DateTool
                    stringFromUNIXTimestamp:[timestamp unsignedLongLongValue]]
              forKey:key];
}

- (NSMutableDictionary *)readFile:(NSString *)path
                            error:(NSError *__autoreleasing *)error {
    NSMutableDictionary *report = [super readFile:path error:error];

    NSString *reportType = [self getReportType:report];
    if ([reportType isEqualToString:@PNLite_KSCrashReportType_Standard] ||
            [reportType isEqualToString:@PNLite_KSCrashReportType_Minimal]) {
        report = [self fixupCrashReport:report];
    }

    return report;
}

@end
