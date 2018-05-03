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

#if TARGET_OS_MAC || TARGET_OS_TV
#elif TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#include <sys/utsname.h>
#endif

#import "PNLiteSerialization.h"
#import "PNLiteCrashTracker.h"
#import "PNLiteCollections.h"
#import "PNLiteHandledState.h"
#import "PNLiteCrashLogger.h"
#import "PNLiteKeys.h"
#import "NSDictionary+PNLite_Merge.h"
#import "PNLiteKSCrashSysInfoParser.h"
#import "PNLiteSession.h"
#import "PNLite_RFC3339DateTool.h"

NSMutableDictionary *PNLiteFormatFrame(NSDictionary *frame,
                                    NSArray *binaryImages) {
    NSMutableDictionary *formatted = [NSMutableDictionary dictionary];

    unsigned long instructionAddress =
        [frame[@"instruction_addr"] unsignedLongValue];
    unsigned long symbolAddress = [frame[@"symbol_addr"] unsignedLongValue];
    unsigned long imageAddress = [frame[@"object_addr"] unsignedLongValue];

    PNLiteDictSetSafeObject(
        formatted, [NSString stringWithFormat:PNLiteKeyFrameAddrFormat, instructionAddress],
        @"frameAddress");
    PNLiteDictSetSafeObject(formatted,
                         [NSString stringWithFormat:PNLiteKeyFrameAddrFormat, symbolAddress],
                         PNLiteKeySymbolAddr);
    PNLiteDictSetSafeObject(formatted,
                         [NSString stringWithFormat:PNLiteKeyFrameAddrFormat, imageAddress],
                         PNLiteKeyMachoLoadAddr);
    PNLiteDictInsertIfNotNil(formatted, frame[PNLiteKeyIsPC], PNLiteKeyIsPC);
    PNLiteDictInsertIfNotNil(formatted, frame[PNLiteKeyIsLR], PNLiteKeyIsLR);

    NSString *file = frame[@"object_name"];
    NSString *method = frame[@"symbol_name"];

    PNLiteDictInsertIfNotNil(formatted, file, PNLiteKeyMachoFile);
    PNLiteDictInsertIfNotNil(formatted, method, @"method");

    for (NSDictionary *image in binaryImages) {
        if ([(NSNumber *)image[@"image_addr"] unsignedLongValue] ==
            imageAddress) {
            unsigned long imageSlide =
                [image[@"image_vmaddr"] unsignedLongValue];

            PNLiteDictInsertIfNotNil(formatted, image[@"uuid"], PNLiteKeyMachoUUID);
            PNLiteDictInsertIfNotNil(formatted, image[PNLiteKeyName], PNLiteKeyMachoFile);
            PNLiteDictSetSafeObject(
                formatted, [NSString stringWithFormat:PNLiteKeyFrameAddrFormat, imageSlide],
                PNLiteKeyMachoVMAddress);

            return formatted;
        }
    }

    return nil;
}

NSString *_Nonnull PNLiteParseErrorClass(NSDictionary *error,
                                      NSString *errorType) {
    NSString *errorClass;

    if ([errorType isEqualToString:PNLiteKeyCppException]) {
        errorClass = error[PNLiteKeyCppException][PNLiteKeyName];
    } else if ([errorType isEqualToString:PNLiteKeyMach]) {
        errorClass = error[PNLiteKeyMach][PNLiteKeyExceptionName];
    } else if ([errorType isEqualToString:PNLiteKeySignal]) {
        errorClass = error[PNLiteKeySignal][PNLiteKeyName];
    } else if ([errorType isEqualToString:@"nsexception"]) {
        errorClass = error[@"nsexception"][PNLiteKeyName];
    } else if ([errorType isEqualToString:PNLiteKeyUser]) {
        errorClass = error[@"user_reported"][PNLiteKeyName];
    }

    if (!errorClass) { // use a default value
        errorClass = @"Exception";
    }
    return errorClass;
}

NSString *PNLiteParseErrorMessage(NSDictionary *report, NSDictionary *error,
                               NSString *errorType) {
    if ([errorType isEqualToString:PNLiteKeyMach] || error[PNLiteKeyReason] == nil) {
        NSString *diagnosis = [report valueForKeyPath:@"crash.diagnosis"];
        if (diagnosis && ![diagnosis hasPrefix:@"No diagnosis"]) {
            return [[diagnosis componentsSeparatedByString:@"\n"] firstObject];
        }
    }
    return error[PNLiteKeyReason] ?: @"";
}

NSString *PNLiteParseContext(NSDictionary *report, NSDictionary *metaData) {
    id context = [report valueForKeyPath:@"user.overrides.context"];
    if ([context isKindOfClass:[NSString class]])
        return context;
    context = metaData[PNLiteKeyContext];
    if ([context isKindOfClass:[NSString class]])
        return context;
    context = [report valueForKeyPath:@"user.config.context"];
    if ([context isKindOfClass:[NSString class]])
        return context;
    return nil;
}

NSString *PNLiteParseGroupingHash(NSDictionary *report, NSDictionary *metaData) {
    id groupingHash = [report valueForKeyPath:@"user.overrides.groupingHash"];
    if (groupingHash)
        return groupingHash;
    groupingHash = metaData[PNLiteKeyGroupingHash];
    if ([groupingHash isKindOfClass:[NSString class]])
        return groupingHash;
    return nil;
}

NSArray *PNLiteParseBreadcrumbs(NSDictionary *report) {
    return [report valueForKeyPath:@"user.overrides.breadcrumbs"]
               ?: [report valueForKeyPath:@"user.state.crash.breadcrumbs"];
}

NSString *PNLiteParseReleaseStage(NSDictionary *report) {
    return [report valueForKeyPath:@"user.overrides.releaseStage"]
               ?: [report valueForKeyPath:@"user.config.releaseStage"];
}

PNLiteSeverity PNLiteParseSeverity(NSString *severity) {
    if ([severity isEqualToString:PNLiteKeyInfo])
        return PNLiteSeverityInfo;
    else if ([severity isEqualToString:PNLiteKeyWarning])
        return PNLiteSeverityWarning;
    return PNLiteSeverityError;
}

NSString *PNLiteFormatSeverity(PNLiteSeverity severity) {
    switch (severity) {
    case PNLiteSeverityInfo:
        return PNLiteKeyInfo;
    case PNLiteSeverityError:
        return PNLiteKeyError;
    case PNLiteSeverityWarning:
        return PNLiteKeyWarning;
    }
}

NSDictionary *PNLiteParseCustomException(NSDictionary *report,
                                      NSString *errorClass, NSString *message) {
    id frames =
        [report valueForKeyPath:@"user.overrides.customStacktraceFrames"];
    id type = [report valueForKeyPath:@"user.overrides.customStacktraceType"];
    if (type && frames) {
        return @{
            PNLiteKeyStacktrace : frames,
            PNLiteKeyType : type,
            PNLiteKeyErrorClass : errorClass,
            PNLiteKeyMessage : message
        };
    }

    return nil;
}

static NSString *const PNLITE_DEFAULT_EXCEPTION_TYPE = @"cocoa";

@interface NSDictionary (PNLiteKSMerge)
- (NSDictionary *)PNLite_mergedInto:(NSDictionary *)dest;
@end

@interface PNLiteRegisterErrorData : NSObject
@property (nonatomic, strong) NSString *errorClass;
@property (nonatomic, strong) NSString *errorMessage;
+ (instancetype)errorDataFromThreads:(NSArray *)threads;
- (instancetype)initWithClass:(NSString *_Nonnull)errorClass message:(NSString *_Nonnull)errorMessage NS_DESIGNATED_INITIALIZER;
@end

@interface PNLiteCrashReport ()

/**
 *  The type of the error, such as `mach` or `user`
 */
@property(nonatomic, readwrite, copy, nullable) NSString *errorType;
/**
 *  The UUID of the dSYM file
 */
@property(nonatomic, readonly, copy, nullable) NSString *dsymUUID;
/**
 *  A unique hash identifying this device for the application or vendor
 */
@property(nonatomic, readonly, copy, nullable) NSString *deviceAppHash;
/**
 *  Binary images used to identify application symbols
 */
@property(nonatomic, readonly, copy, nullable) NSArray *binaryImages;
/**
 *  Thread information captured at the time of the error
 */
@property(nonatomic, readonly, copy, nullable) NSArray *threads;
/**
 *  User-provided exception metadata
 */
@property(nonatomic, readwrite, copy, nullable) NSDictionary *customException;
@property(nonatomic) PNLiteSession *session;

@end

@implementation PNLiteCrashReport

- (instancetype)initWithKSReport:(NSDictionary *)report {
    if (self = [super init]) {
        _notifyReleaseStages =
            [report valueForKeyPath:@"user.config.notifyReleaseStages"];
        _releaseStage = PNLiteParseReleaseStage(report);

        _error = [report valueForKeyPath:@"crash.error"];
        _errorType = _error[PNLiteKeyType];
        _threads = [report valueForKeyPath:@"crash.threads"];
        PNLiteRegisterErrorData *data = [PNLiteRegisterErrorData errorDataFromThreads:_threads];
        if (data) {
            _errorClass = data.errorClass;
            _errorMessage = data.errorMessage;
        } else {
            _errorClass = PNLiteParseErrorClass(_error, _errorType);
            _errorMessage = PNLiteParseErrorMessage(report, _error, _errorType);
        }
        _binaryImages = report[@"binary_images"];
        _breadcrumbs = PNLiteParseBreadcrumbs(report);
        _severity = PNLiteParseSeverity(
            [report valueForKeyPath:@"user.state.crash.severity"]);
        _depth = [[report valueForKeyPath:@"user.state.crash.depth"]
            unsignedIntegerValue];
        _dsymUUID = [report valueForKeyPath:@"system.app_uuid"];
        _deviceAppHash = [report valueForKeyPath:@"system.device_app_hash"];
        _metaData =
            [report valueForKeyPath:@"user.metaData"] ?: [NSDictionary new];
        _context = PNLiteParseContext(report, _metaData);
        _deviceState = PNLiteParseDeviceState(report);
        _device = PNLiteParseDevice(report);
        _app = PNLiteParseApp(report[PNLiteKeySystem]);
        _appState = PNLiteParseAppState(report[PNLiteKeySystem]);
        _groupingHash = PNLiteParseGroupingHash(report, _metaData);
        _overrides = [report valueForKeyPath:@"user.overrides"];
        _customException = PNLiteParseCustomException(report, [_errorClass copy],
                                                   [_errorMessage copy]);

        NSDictionary *recordedState =
            [report valueForKeyPath:@"user.handledState"];

        if (recordedState) {
            _handledState =
                [[PNLiteHandledState alloc] initWithDictionary:recordedState];
        } else { // the event was unhandled.
            BOOL isSignal = [PNLiteKeySignal isEqualToString:_errorType];
            PNLiteSeverityReasonType severityReason =
                isSignal ? PNLite_Signal : PNLite_UnhandledException;
            _handledState = [PNLiteHandledState
                handledStateWithSeverityReason:severityReason
                                      severity:PNLiteSeverityError
                                     attrValue:_errorClass];
        }
        _severity = _handledState.currentSeverity;

        if (report[@"user"][@"id"]) {
            _session = [[PNLiteSession alloc] initWithDictionary:report[@"user"]];
        }
    }
    return self;
}

- (instancetype _Nonnull)
initWithErrorName:(NSString *_Nonnull)name
     errorMessage:(NSString *_Nonnull)message
    configuration:(PNLiteConfiguration *_Nonnull)config
         metaData:(NSDictionary *_Nonnull)metaData
     handledState:(PNLiteHandledState *_Nonnull)handledState
          session:(PNLiteSession *_Nullable)session {
    if (self = [super init]) {
        _errorClass = name;
        _errorMessage = message;
        _metaData = metaData ?: [NSDictionary new];
        _releaseStage = config.releaseStage;
        _notifyReleaseStages = config.notifyReleaseStages;
        _context = PNLiteParseContext(nil, metaData);
        _breadcrumbs = [config.breadcrumbs arrayValue];
        _overrides = [NSDictionary new];

        _handledState = handledState;
        _severity = handledState.currentSeverity;
        _session = session;
    }
    return self;
}

@synthesize metaData = _metaData;

- (NSDictionary *)metaData {
    @synchronized (self) {
        return _metaData;
    }
}

- (void)setMetaData:(NSDictionary *)metaData {
    @synchronized (self) {
        _metaData = PNLiteSanitizeDict(metaData);
    }
}

- (void)addMetadata:(NSDictionary *_Nonnull)tabData
      toTabWithName:(NSString *_Nonnull)tabName {
    NSDictionary *cleanedData = PNLiteSanitizeDict(tabData);
    if ([cleanedData count] == 0) {
        pnlite_log_err(@"Failed to add metadata: Values not convertible to JSON");
        return;
    }
    NSMutableDictionary *allMetadata = [self.metaData mutableCopy];
    NSMutableDictionary *allTabData =
        allMetadata[tabName] ?: [NSMutableDictionary new];
    allMetadata[tabName] = [cleanedData PNLite_mergedInto:allTabData];
    self.metaData = allMetadata;
}

- (void)addAttribute:(NSString *)attributeName
           withValue:(id)value
       toTabWithName:(NSString *)tabName {
    NSMutableDictionary *allMetadata = [self.metaData mutableCopy];
    NSMutableDictionary *allTabData =
        allMetadata[tabName] ?: [NSMutableDictionary new];
    if (value) {
        id cleanedValue = PNLiteSanitizeObject(value);
        if (!cleanedValue) {
            pnlite_log_err(@"Failed to add metadata: Value of type %@ is not "
                        @"convertible to JSON",
                        [value class]);
            return;
        }
        allTabData[attributeName] = cleanedValue;
    } else {
        [allTabData removeObjectForKey:attributeName];
    }
    allMetadata[tabName] = allTabData;
    self.metaData = allMetadata;
}

- (BOOL)shouldBeSent {
    return [self.notifyReleaseStages containsObject:self.releaseStage] ||
           (self.notifyReleaseStages.count == 0 &&
            [[PNLiteCrashTracker configuration] shouldSendReports]);
}

@synthesize context = _context;

- (NSString *)context {
    @synchronized (self) {
        return _context;
    }
}

- (void)setContext:(NSString *)context {
    [self setOverrideProperty:PNLiteKeyContext value:context];
    @synchronized (self) {
        _context = context;
    }
}

@synthesize groupingHash = _groupingHash;

- (NSString *)groupingHash {
    @synchronized (self) {
        return _groupingHash;
    }
}

- (void)setGroupingHash:(NSString *)groupingHash {
    [self setOverrideProperty:PNLiteKeyGroupingHash value:groupingHash];
    @synchronized (self) {
        _groupingHash = groupingHash;
    }
}

@synthesize breadcrumbs = _breadcrumbs;

- (NSArray *)breadcrumbs {
    @synchronized (self) {
        return _breadcrumbs;
    }
}

- (void)setBreadcrumbs:(NSArray *)breadcrumbs {
    [self setOverrideProperty:PNLiteKeyBreadcrumbs value:breadcrumbs];
    @synchronized (self) {
        _breadcrumbs = breadcrumbs;
    }
}

@synthesize releaseStage = _releaseStage;

- (NSString *)releaseStage {
    @synchronized (self) {
        return _releaseStage;
    }
}

- (void)setReleaseStage:(NSString *)releaseStage {
    [self setOverrideProperty:PNLiteKeyReleaseStage value:releaseStage];
    @synchronized (self) {
        _releaseStage = releaseStage;
    }
}

- (void)attachCustomStacktrace:(NSArray *)frames withType:(NSString *)type {
    [self setOverrideProperty:@"customStacktraceFrames" value:frames];
    [self setOverrideProperty:@"customStacktraceType" value:type];
}

@synthesize severity = _severity;

- (PNLiteSeverity)severity {
    @synchronized (self) {
        return _severity;
    }
}

- (void)setSeverity:(PNLiteSeverity)severity {
    @synchronized (self) {
        _severity = severity;
        _handledState.currentSeverity = severity;
    }
}

- (void)setOverrideProperty:(NSString *)key value:(id)value {
    @synchronized (self) {
        NSMutableDictionary *metadata = [self.overrides mutableCopy];
        if (value) {
            metadata[key] = value;
        } else {
            [metadata removeObjectForKey:key];
        }
        _overrides = metadata;
    }
    
}

- (NSDictionary *)serializableValueWithTopLevelData:
    (NSMutableDictionary *)data {
    return [self toJson];
}

- (NSDictionary *)toJson {
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    NSMutableDictionary *metaData = [[self metaData] mutableCopy];

    if (self.customException) {
        PNLiteDictSetSafeObject(event, @[ self.customException ], PNLiteKeyExceptions);
        PNLiteDictSetSafeObject(event, [self serializeThreadsWithException:nil],
                             PNLiteKeyThreads);
    } else {
        NSMutableDictionary *exception = [NSMutableDictionary dictionary];
        PNLiteDictSetSafeObject(exception, [self errorClass], PNLiteKeyErrorClass);
        PNLiteDictInsertIfNotNil(exception, [self errorMessage], PNLiteKeyMessage);
        PNLiteDictInsertIfNotNil(exception, PNLITE_DEFAULT_EXCEPTION_TYPE, PNLiteKeyType);
        PNLiteDictSetSafeObject(event, @[ exception ], PNLiteKeyExceptions);

        PNLiteDictSetSafeObject(
            event, [self serializeThreadsWithException:exception], PNLiteKeyThreads);
    }
    // Build Event
    PNLiteDictSetSafeObject(event, PNLiteFormatSeverity(self.severity), PNLiteKeySeverity);
    PNLiteDictSetSafeObject(event, [self breadcrumbs], PNLiteKeyBreadcrumbs);
    PNLiteDictSetSafeObject(event, metaData, PNLiteKeyMetaData);
    
    NSDictionary *device = [self.device pnlite_mergedInto:self.deviceState];
    PNLiteDictSetSafeObject(event, device, PNLiteKeyDevice);
    
    NSMutableDictionary *appObj = [NSMutableDictionary new];
    [appObj addEntriesFromDictionary:self.app];
    
    for (NSString *key in self.appState) {
        PNLiteDictInsertIfNotNil(appObj, self.appState[key], key);
    }
    
    if (self.dsymUUID) {
        PNLiteDictInsertIfNotNil(appObj, @[self.dsymUUID], @"dsymUUIDs");
    }
    
    PNLiteDictSetSafeObject(event, appObj, PNLiteKeyApp);
    
    PNLiteDictSetSafeObject(event, [self context], PNLiteKeyContext);
    PNLiteDictInsertIfNotNil(event, self.groupingHash, PNLiteKeyGroupingHash);
    

    PNLiteDictSetSafeObject(event, @(self.handledState.unhandled), PNLiteKeyUnhandled);

    // serialize handled/unhandled into payload
    NSMutableDictionary *severityReason = [NSMutableDictionary new];
    NSString *reasonType = [PNLiteHandledState
        stringFromSeverityReason:self.handledState.calculateSeverityReasonType];
    severityReason[PNLiteKeyType] = reasonType;

    if (self.handledState.attrKey && self.handledState.attrValue) {
        severityReason[PNLiteKeyAttributes] =
            @{self.handledState.attrKey : self.handledState.attrValue};
    }

    PNLiteDictSetSafeObject(event, severityReason, PNLiteKeySeverityReason);

    //  Inserted into `context` property
    [metaData removeObjectForKey:PNLiteKeyContext];
    // Build metadata
    PNLiteDictSetSafeObject(metaData, [self error], PNLiteKeyError);

    // Make user mutable and set the id if the user hasn't already
    NSMutableDictionary *user = [metaData[PNLiteKeyUser] mutableCopy];
    if (user == nil) {
        user = [NSMutableDictionary dictionary];
    }
    PNLiteDictInsertIfNotNil(event, user, PNLiteKeyUser);

    if (!user[PNLiteKeyId] && self.device[PNLiteKeyId]) { // if device id is null, don't set user id to default
        PNLiteDictSetSafeObject(user, [self deviceAppHash], PNLiteKeyId);
    }

    if (self.session) {
        PNLiteDictSetSafeObject(event, [self generateSessionDict], PNLiteKeySession);
    }
    return event;
}

- (NSDictionary *)generateSessionDict {
    NSDictionary *events = @{
            @"handled": @(self.session.handledCount),
            @"unhandled": @(self.session.unhandledCount)
    };

    NSDictionary *sessionJson = @{
            PNLiteKeyId: self.session.sessionId,
            @"startedAt": [PNLite_RFC3339DateTool stringFromDate:self.session.startedAt],
            @"events": events
    };
    return sessionJson;
}

// Build all stacktraces for threads and the error
- (NSArray *)serializeThreadsWithException:(NSMutableDictionary *)exception {
    NSMutableArray *pnliteThreads = [NSMutableArray array];
    for (NSDictionary *thread in [self threads]) {
        NSArray *backtrace = thread[@"backtrace"][@"contents"];
        BOOL stackOverflow = [thread[@"stack"][@"overflow"] boolValue];
        BOOL isCrashedThread = [thread[@"crashed"] boolValue];
        
        if (isCrashedThread) {
            NSUInteger seen = 0;
            NSMutableArray *stacktrace = [NSMutableArray array];

            for (NSDictionary *frame in backtrace) {
                NSMutableDictionary *mutableFrame = [frame mutableCopy];
                if (seen++ >= [self depth]) {
                    // Mark the frame so we know where it came from
                    if (seen == 1 && !stackOverflow) {
                        PNLiteDictSetSafeObject(mutableFrame, @YES, PNLiteKeyIsPC);
                    }
                    if (seen == 2 && !stackOverflow &&
                        [@[ PNLiteKeySignal, @"deadlock", PNLiteKeyMach ]
                            containsObject:[self errorType]]) {
                        PNLiteDictSetSafeObject(mutableFrame, @YES, PNLiteKeyIsLR);
                    }
                    PNLiteArrayInsertIfNotNil(
                        stacktrace,
                        PNLiteFormatFrame(mutableFrame, [self binaryImages]));
                }
            }

            PNLiteDictSetSafeObject(exception, stacktrace, PNLiteKeyStacktrace);
        } else {
            NSMutableArray *threadStack = [NSMutableArray array];

            for (NSDictionary *frame in backtrace) {
                PNLiteArrayInsertIfNotNil(
                    threadStack, PNLiteFormatFrame(frame, [self binaryImages]));
            }

            NSMutableDictionary *threadDict = [NSMutableDictionary dictionary];
            PNLiteDictSetSafeObject(threadDict, thread[@"index"], PNLiteKeyId);
            PNLiteDictSetSafeObject(threadDict, threadStack, PNLiteKeyStacktrace);
            PNLiteDictSetSafeObject(threadDict, PNLITE_DEFAULT_EXCEPTION_TYPE, PNLiteKeyType);
            // only if this is enabled in PNLite_KSCrash.
            if (thread[PNLiteKeyName]) {
                PNLiteDictSetSafeObject(threadDict, thread[PNLiteKeyName], PNLiteKeyName);
            }

            PNLiteArrayAddSafeObject(pnliteThreads, threadDict);
        }
    }
    return pnliteThreads;
}

- (NSString *_Nullable)enhancedErrorMessageForThread:(NSDictionary *_Nullable)thread {
    return [self errorMessage];
}

@end

@implementation PNLiteRegisterErrorData
+ (instancetype)errorDataFromThreads:(NSArray *)threads {
    for (NSDictionary *thread in threads) {
        if (![thread[@"crashed"] boolValue]) {
            continue;
        }
        NSDictionary *notableAddresses = thread[@"notable_addresses"];
        NSMutableArray *interestingValues = [NSMutableArray new];
        NSString *reservedWord = nil;

        for (NSString *key in notableAddresses) {
            if ([key hasPrefix:@"stack"]) { // skip stack frames, only use register values
                continue;
            }
            NSDictionary *data = notableAddresses[key];
            if (![@"string" isEqualToString:data[PNLiteKeyType]]) {
                continue;
            }
            NSString *contentValue = data[@"value"];

            if ([self isReservedWord:contentValue]) {
                reservedWord = contentValue;
            } else if (!([[contentValue componentsSeparatedByString:@"/"] count] > 2)) {
                // must be a string that isn't a reserved word and isn't a filepath
                [interestingValues addObject:contentValue];
            }
        }

        [interestingValues sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        NSString *message = [interestingValues componentsJoinedByString:@" | "];
        return [[PNLiteRegisterErrorData alloc] initWithClass:reservedWord
                                                message:message];
    }
    return nil;
}

/**
 * Determines whether a string is a "reserved word" that identifies it as a known value.
 *
 * For fatalError, preconditionFailure, and assertionFailure, "fatal error" will be in one of the registers.
 *
 * For assert, "assertion failed" will be in one of the registers.
 */
+ (BOOL)isReservedWord:(NSString *)contentValue {
    return [@"assertion failed" caseInsensitiveCompare:contentValue] == NSOrderedSame
    || [@"fatal error" caseInsensitiveCompare:contentValue] == NSOrderedSame
    || [@"precondition failed" caseInsensitiveCompare:contentValue] == NSOrderedSame;
}

- (instancetype)init {
    return [self initWithClass:@"Unknown" message:@"<unset>"];
}

- (instancetype)initWithClass:(NSString *)errorClass message:(NSString *)errorMessage {
    if (errorClass.length == 0) {
        return nil;
    }
    if (self = [super init]) {
        _errorClass = errorClass;
        _errorMessage = errorMessage;
    }
    return self;
}
@end
