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

#import "PNLite_KSCrashDoctor.h"
#import "PNLite_KSCrashReportFields.h"
#import "PNLite_KSSystemInfo.h"

#define PNLite_kUserCrashHandler "kscrw_i_callUserCrashHandler"

typedef enum {
    PNLite_CPUFamilyUnknown,
    PNLite_CPUFamilyArm,
    PNLite_CPUFamilyArm64,
    PNLite_CPUFamilyX86,
    PNLite_CPUFamilyX86_64
} PNLite_CPUFamily;

@interface PNLite_KSCrashDoctorParam : NSObject

@property(nonatomic, readwrite, retain) NSString *className;
@property(nonatomic, readwrite, retain) NSString *previousClassName;
@property(nonatomic, readwrite, retain) NSString *type;
@property(nonatomic, readwrite, assign) BOOL isInstance;
@property(nonatomic, readwrite, assign) uintptr_t address;
@property(nonatomic, readwrite, retain) NSString *value;

@end

@implementation PNLite_KSCrashDoctorParam

@synthesize className = _className;
@synthesize previousClassName = _previousClassName;
@synthesize isInstance = _isInstance;
@synthesize address = _address;
@synthesize value = _value;
@synthesize type = _type;

@end

@interface PNLite_KSCrashDoctorFunctionCall : NSObject

@property(nonatomic, readwrite, retain) NSString *name;
@property(nonatomic, readwrite, retain) NSArray *params;

@end

@implementation PNLite_KSCrashDoctorFunctionCall

@synthesize name = _name;
@synthesize params = _params;

- (NSString *)descriptionForObjCCall {
    if (![self.name isEqualToString:@"objc_msgSend"]) {
        return nil;
    }
    PNLite_KSCrashDoctorParam *receiverParam = self.params[0];
    NSString *receiver = receiverParam.previousClassName;
    if (receiver == nil) {
        receiver = receiverParam.className;
        if (receiver == nil) {
            receiver = @"id";
        }
    }

    PNLite_KSCrashDoctorParam *selectorParam = self.params[1];
    if (![selectorParam.type isEqualToString:@PNLite_KSCrashMemType_String]) {
        return nil;
    }
    NSArray *splitSelector =
        [selectorParam.value componentsSeparatedByString:@":"];
    int paramCount = (int)[splitSelector count] - 1;

    NSMutableString *string = [NSMutableString
            stringWithFormat:@"-[%@ %@", receiver, splitSelector[0]];
    for (int paramNum = 0; paramNum < paramCount; paramNum++) {
        [string appendString:@":"];
        if (paramNum < 2) {
            PNLite_KSCrashDoctorParam *param =
                    self.params[(NSUInteger) paramNum + 2];
            if (param.value != nil) {
                if ([param.type isEqualToString:@PNLite_KSCrashMemType_String]) {
                    [string appendFormat:@"\"%@\"", param.value];
                } else {
                    [string appendString:param.value];
                }
            } else if (param.previousClassName != nil) {
                [string appendString:param.previousClassName];
            } else if (param.className != nil) {
                [string appendFormat:@"%@ (%@)", param.className,
                                     param.isInstance ? @"instance" : @"class"];
            } else {
                [string appendString:@"?"];
            }
        } else {
            [string appendString:@"?"];
        }
        if (paramNum < paramCount - 1) {
            [string appendString:@" "];
        }
    }

    [string appendString:@"]"];
    return string;
}

- (NSString *)descriptionWithParamCount:(int)paramCount {
    NSString *objCCall = [self descriptionForObjCCall];
    if (objCCall != nil) {
        return objCCall;
    }

    if (paramCount > (int)[self.params count]) {
        paramCount = (int)[self.params count];
    }
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"Function: %@\n", self.name];
    for (int i = 0; i < paramCount; i++) {
        PNLite_KSCrashDoctorParam *param =
                self.params[(NSUInteger) i];
        [str appendFormat:@"Param %d:  ", i + 1];
        if (param.className != nil) {
            [str appendFormat:@"%@ (%@) ", param.className,
                              param.isInstance ? @"instance" : @"class"];
        }
        if (param.value != nil) {
            [str appendFormat:@"%@ ", param.value];
        }
        if (param.previousClassName != nil) {
            [str appendFormat:@"(was %@)", param.previousClassName];
        }
        if (i < paramCount - 1) {
            [str appendString:@"\n"];
        }
    }
    return str;
}

@end

@implementation PNLite_KSCrashDoctor

+ (PNLite_KSCrashDoctor *)doctor {
    return [[self alloc] init];
}

- (NSDictionary *)recrashReport:(NSDictionary *)report {
    return report[@PNLite_KSCrashField_RecrashReport];
}

- (NSDictionary *)systemReport:(NSDictionary *)report {
    return report[@PNLite_KSCrashField_System];
}

- (NSDictionary *)crashReport:(NSDictionary *)report {
    return report[@PNLite_KSCrashField_Crash];
}

- (NSDictionary *)infoReport:(NSDictionary *)report {
    return report[@PNLite_KSCrashField_Report];
}

- (NSDictionary *)errorReport:(NSDictionary *)report {
    return [self crashReport:report][@PNLite_KSCrashField_Error];
}

- (PNLite_CPUFamily)cpuFamily:(NSDictionary *)report {
    NSDictionary *system = [self systemReport:report];
    NSString *cpuArch = system[@PNLite_KSSystemField_CPUArch];
    if ([cpuArch isEqualToString:@"arm64"]) {
        return PNLite_CPUFamilyArm64;
    }
    if ([cpuArch rangeOfString:@"arm"].location == 0) {
        return PNLite_CPUFamilyArm;
    }
    if ([cpuArch rangeOfString:@"i"].location == 0 &&
        [cpuArch rangeOfString:@"86"].location == 2) {
        return PNLite_CPUFamilyX86;
    }
    if ([@[@"x86_64", @"x86"] containsObject:cpuArch]) {
        return PNLite_CPUFamilyX86_64;
    }
    return PNLite_CPUFamilyUnknown;
}

- (NSString *)registerNameForFamily:(PNLite_CPUFamily)family
                         paramIndex:(int)index {
    switch (family) {
    case PNLite_CPUFamilyArm: {
        switch (index) {
        case 0:
            return @"r0";
        case 1:
            return @"r1";
        case 2:
            return @"r2";
        case 3:
            return @"r3";
        }
    }
    case PNLite_CPUFamilyArm64: {
        switch (index) {
            case 0:
                return @"x0";
            case 1:
                return @"x1";
            case 2:
                return @"x2";
            case 3:
                return @"x3";
        }
    }
    case PNLite_CPUFamilyX86: {
        switch (index) {
        case 0:
            return @"edi";
        case 1:
            return @"esi";
        case 2:
            return @"edx";
        case 3:
            return @"ecx";
        }
    }
    case PNLite_CPUFamilyX86_64: {
        switch (index) {
        case 0:
            return @"rdi";
        case 1:
            return @"rsi";
        case 2:
            return @"rdx";
        case 3:
            return @"rcx";
        }
    }
    case PNLite_CPUFamilyUnknown:
        return nil;
    }
    return nil;
}

- (NSString *)mainExecutableNameForReport:(NSDictionary *)report {
    NSDictionary *info = [self infoReport:report];
    return info[@PNLite_KSCrashField_ProcessName];
}

- (NSDictionary *)crashedThreadReport:(NSDictionary *)report {
    NSDictionary *crashReport = [self crashReport:report];
    NSDictionary *crashedThread =
            crashReport[@PNLite_KSCrashField_CrashedThread];
    if (crashedThread != nil) {
        return crashedThread;
    }

    for (NSDictionary *thread in
            crashReport[@PNLite_KSCrashField_Threads]) {
        if ([thread[@PNLite_KSCrashField_Crashed] boolValue]) {
            return thread;
        }
    }
    return nil;
}

- (NSArray *)backtraceFromThreadReport:(NSDictionary *)threadReport {
    NSDictionary *backtrace =
            threadReport[@PNLite_KSCrashField_Backtrace];
    return backtrace[@PNLite_KSCrashField_Contents];
}

- (NSDictionary *)basicRegistersFromThreadReport:(NSDictionary *)threadReport {
    NSDictionary *registers =
            threadReport[@PNLite_KSCrashField_Registers];
    NSDictionary *basic = registers[@PNLite_KSCrashField_Basic];
    return basic;
}

- (NSDictionary *)lastInAppStackEntry:(NSDictionary *)report {
    NSString *executableName = [self mainExecutableNameForReport:report];
    NSDictionary *crashedThread = [self crashedThreadReport:report];
    NSArray *backtrace = [self backtraceFromThreadReport:crashedThread];
    for (NSDictionary *entry in backtrace) {
        NSString *objectName =
                entry[@PNLite_KSCrashField_ObjectName];
        if ([objectName isEqualToString:executableName]) {
            return entry;
        }
    }
    return nil;
}

- (NSDictionary *)lastStackEntry:(NSDictionary *)report {
    NSDictionary *crashedThread = [self crashedThreadReport:report];
    NSArray *backtrace = [self backtraceFromThreadReport:crashedThread];
    if ([backtrace count] > 0) {
        return backtrace[0];
    }
    return nil;
}

- (BOOL)isInvalidAddress:(NSDictionary *)errorReport {
    NSDictionary *machError = errorReport[@PNLite_KSCrashField_Mach];
    if (machError != nil) {
        NSString *exceptionName =
                machError[@PNLite_KSCrashField_ExceptionName];
        return [exceptionName isEqualToString:@"EXC_BAD_ACCESS"];
    }
    NSDictionary *signal = errorReport[@PNLite_KSCrashField_Signal];
    NSString *sigName = signal[@PNLite_KSCrashField_Name];
    return [sigName isEqualToString:@"SIGSEGV"];
}

- (BOOL)isMathError:(NSDictionary *)errorReport {
    NSDictionary *machError = errorReport[@PNLite_KSCrashField_Mach];
    if (machError != nil) {
        NSString *exceptionName =
                machError[@PNLite_KSCrashField_ExceptionName];
        return [exceptionName isEqualToString:@"EXC_ARITHMETIC"];
    }
    NSDictionary *signal = errorReport[@PNLite_KSCrashField_Signal];
    NSString *sigName = signal[@PNLite_KSCrashField_Name];
    return [sigName isEqualToString:@"SIGFPE"];
}

- (BOOL)isMemoryCorruption:(NSDictionary *)report {
    NSDictionary *crashedThread = [self crashedThreadReport:report];
    NSArray *notableAddresses =
            crashedThread[@PNLite_KSCrashField_NotableAddresses];
    for (NSDictionary *address in [notableAddresses objectEnumerator]) {
        NSString *type = address[@PNLite_KSCrashField_Type];
        if ([type isEqualToString:@"string"]) {
            NSString *value = address[@PNLite_KSCrashField_Value];
            if ([value rangeOfString:@"autorelease pool page"].location !=
                    NSNotFound &&
                [value rangeOfString:@"corrupted"].location != NSNotFound) {
                return YES;
            }
            if ([value rangeOfString:@"incorrect checksum for freed object"]
                    .location != NSNotFound) {
                return YES;
            }
        }
    }

    NSArray *backtrace = [self backtraceFromThreadReport:crashedThread];
    for (NSDictionary *entry in backtrace) {
        NSString *objectName =
                entry[@PNLite_KSCrashField_ObjectName];
        NSString *symbolName =
                entry[@PNLite_KSCrashField_SymbolName];
        if ([symbolName isEqualToString:@"objc_autoreleasePoolPush"]) {
            return YES;
        }
        if ([symbolName isEqualToString:@"free_list_checksum_botch"]) {
            return YES;
        }
        if ([symbolName isEqualToString:@"szone_malloc_should_clear"]) {
            return YES;
        }
        if ([symbolName isEqualToString:@"lookUpMethod"] &&
            [objectName isEqualToString:@"libobjc.A.dylib"]) {
            return YES;
        }
    }

    return NO;
}

- (PNLite_KSCrashDoctorFunctionCall *)lastFunctionCall:(NSDictionary *)report {
    PNLite_KSCrashDoctorFunctionCall *function =
        [[PNLite_KSCrashDoctorFunctionCall alloc] init];
    NSDictionary *lastStackEntry = [self lastStackEntry:report];
    function.name = lastStackEntry[@PNLite_KSCrashField_SymbolName];

    NSDictionary *crashedThread = [self crashedThreadReport:report];
    NSDictionary *notableAddresses =
            crashedThread[@PNLite_KSCrashField_NotableAddresses];
    PNLite_CPUFamily family = [self cpuFamily:report];
    NSDictionary *registers =
        [self basicRegistersFromThreadReport:crashedThread];
    NSMutableArray *regNames = [NSMutableArray arrayWithCapacity:4];
    for (int paramIndex = 0; paramIndex <= 3; paramIndex++) {
        NSString *regName = [self registerNameForFamily:family paramIndex:paramIndex];
        if (regName.length > 0) {
            [regNames addObject:regName];
        }
    }
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:4];
    for (NSString *regName in regNames) {
        PNLite_KSCrashDoctorParam *param = [[PNLite_KSCrashDoctorParam alloc] init];
        param.address =
            (uintptr_t)[registers[regName] unsignedLongLongValue];
        NSDictionary *notableAddress = notableAddresses[regName];
        if (notableAddress == nil) {
            param.value =
                [NSString stringWithFormat:@"%p", (void *)param.address];
        } else {
            param.type = notableAddress[@PNLite_KSCrashField_Type];
            NSString *className =
                    notableAddress[@PNLite_KSCrashField_Class];
            NSString *previousClass = notableAddress[@PNLite_KSCrashField_LastDeallocObject];
            NSString *value =
                    notableAddress[@PNLite_KSCrashField_Value];

            if ([param.type isEqualToString:@PNLite_KSCrashMemType_String]) {
                param.value = value;
            } else if ([param.type
                           isEqualToString:@PNLite_KSCrashMemType_Object]) {
                param.className = className;
                param.isInstance = YES;
            } else if ([param.type isEqualToString:@PNLite_KSCrashMemType_Class]) {
                param.className = className;
                param.isInstance = NO;
            }
            param.previousClassName = previousClass;
        }

        [params addObject:param];
    }

    function.params = params;
    return function;
}

- (NSString *)zombieCall:(PNLite_KSCrashDoctorFunctionCall *)functionCall {
    if ([functionCall.name isEqualToString:@"objc_msgSend"] &&
        functionCall.params.count > 0 &&
        [functionCall.params[0] previousClassName] != nil) {
        return [functionCall descriptionWithParamCount:4];
    } else if ([functionCall.name isEqualToString:@"objc_retain"] &&
               functionCall.params.count > 0 &&
               [functionCall.params[0] previousClassName] !=
                   nil) {
        return [functionCall descriptionWithParamCount:1];
    }
    return nil;
}

- (BOOL)isStackOverflow:(NSDictionary *)crashedThreadReport {
    NSDictionary *stack =
            crashedThreadReport[@PNLite_KSCrashField_Stack];
    return [stack[@PNLite_KSCrashField_Overflow] boolValue];
}

- (BOOL)isDeadlock:(NSDictionary *)report {
    NSDictionary *errorReport = [self errorReport:report];
    NSString *crashType = errorReport[@PNLite_KSCrashField_Type];
    return [@PNLite_KSCrashExcType_Deadlock isEqualToString:crashType];
}

- (NSString *)appendOriginatingCall:(NSString *)string
                           callName:(NSString *)callName {
    if (callName != nil && ![callName isEqualToString:@"main"]) {
        return [string
            stringByAppendingFormat:@"\nOriginated at or in a subcall of %@",
                                    callName];
    }
    return string;
}

- (NSString *)diagnoseCrash:(NSDictionary *)report {
    @try {
        NSString *lastFunctionName = [self lastInAppStackEntry:report][@PNLite_KSCrashField_SymbolName];
        NSDictionary *crashedThreadReport = [self crashedThreadReport:report];
        NSDictionary *errorReport = [self errorReport:report];

        if ([self isDeadlock:report]) {
            return [NSString stringWithFormat:@"Main thread deadlocked in %@",
                                              lastFunctionName];
        }

        if ([self isStackOverflow:crashedThreadReport]) {
            return [NSString
                stringWithFormat:@"Stack overflow in %@", lastFunctionName];
        }

        NSString *crashType = errorReport[@PNLite_KSCrashField_Type];
        if ([crashType isEqualToString:@PNLite_KSCrashExcType_NSException]) {
            NSDictionary *exception =
                    errorReport[@PNLite_KSCrashField_NSException];
            NSString *name = exception[@PNLite_KSCrashField_Name];
            NSString *reason =
                    exception[@PNLite_KSCrashField_Reason];
            return [self
                appendOriginatingCall:
                    [NSString
                        stringWithFormat:@"Application threw exception %@: %@",
                                         name, reason]
                             callName:lastFunctionName];
        }

        if ([self isMemoryCorruption:report]) {
            return @"Rogue memory write has corrupted memory.";
        }

        if ([self isMathError:errorReport]) {
            return [self
                appendOriginatingCall:
                    [NSString
                        stringWithFormat:
                            @"Math error (usually caused from division by 0)."]
                             callName:lastFunctionName];
        }

        PNLite_KSCrashDoctorFunctionCall *functionCall =
            [self lastFunctionCall:report];
        NSString *zombieCall = [self zombieCall:functionCall];
        if (zombieCall != nil) {
            return [self
                appendOriginatingCall:
                    [NSString stringWithFormat:@"Possible zombie in call: %@",
                                               zombieCall]
                             callName:lastFunctionName];
        }

        if ([self isInvalidAddress:errorReport]) {
            uintptr_t address = (uintptr_t)[errorReport[@PNLite_KSCrashField_Address] unsignedLongLongValue];
            if (address == 0) {
                return [self appendOriginatingCall:
                                 @"Attempted to dereference null pointer."
                                          callName:lastFunctionName];
            }
            return [self
                appendOriginatingCall:
                    [NSString
                        stringWithFormat:
                            @"Attempted to dereference garbage pointer %p.",
                            (void *)address]
                             callName:lastFunctionName];
        }

        return nil;
    } @catch (NSException *e) {
        NSArray *symbols = [e callStackSymbols];
        if (symbols) {
            return
                [NSString stringWithFormat:@"No diagnosis due to exception "
                                           @"%@:\n%@\nPlease file a bug report "
                                           @"to the PNLite_KSCrash project.",
                                           e, symbols];
        }
        return [NSString
            stringWithFormat:@"No diagnosis due to exception %@\nPlease file a "
                             @"bug report to the PNLite_KSCrash project.",
                             e];
    }
}

@end
