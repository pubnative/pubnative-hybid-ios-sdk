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

#import "PNLiteHandledState.h"

static NSString *const kPNLiteUnhandled = @"unhandled";
static NSString *const kPNLiteSeverityReasonType = @"severityReasonType";
static NSString *const kPNLiteOriginalSeverity = @"originalSeverity";
static NSString *const kPNLiteCurrentSeverity = @"currentSeverity";
static NSString *const kPNLiteAttrValue = @"attrValue";
static NSString *const kPNLiteAttrKey = @"attrKey";

static NSString *const kPNLiteUnhandledException = @"unhandledException";
static NSString *const kPNLiteSignal = @"signal";
static NSString *const kPNLitePromiseRejection = @"unhandledPromiseRejection";
static NSString *const kPNLiteHandledError = @"handledError";
static NSString *const kPNLiteLogGenerated = @"log";
static NSString *const kPNLiteHandledException = @"handledException";
static NSString *const kPNLiteUserSpecifiedSeverity = @"userSpecifiedSeverity";
static NSString *const kPNLiteUserCallbackSetSeverity = @"userCallbackSetSeverity";

@implementation PNLiteHandledState

+ (instancetype)handledStateWithSeverityReason:
    (PNLiteSeverityReasonType)severityReason {
    return [self handledStateWithSeverityReason:severityReason
                                       severity:BSGSeverityWarning
                                      attrValue:nil];
}

+ (instancetype)handledStateWithSeverityReason:
                    (PNLiteSeverityReasonType)severityReason
                                      severity:(BSGSeverity)severity
                                     attrValue:(NSString *)attrValue {
    BOOL unhandled = NO;

    switch (severityReason) {
    case PromiseRejection:
        severity = BSGSeverityError;
        unhandled = YES;
        break;
    case Signal:
        severity = BSGSeverityError;
        unhandled = YES;
        break;
    case HandledError:
        severity = BSGSeverityWarning;
        break;
    case HandledException:
        severity = BSGSeverityWarning;
        break;
    case LogMessage:
    case UserSpecifiedSeverity:
    case UserCallbackSetSeverity:
        break;
    case UnhandledException:
        severity = BSGSeverityError;
        unhandled = YES;
        break;
    }

    return [[PNLiteHandledState alloc] initWithSeverityReason:severityReason
                                                      severity:severity
                                                     unhandled:unhandled
                                                     attrValue:attrValue];
}

- (instancetype)initWithSeverityReason:(PNLiteSeverityReasonType)severityReason
                              severity:(BSGSeverity)severity
                             unhandled:(BOOL)unhandled
                             attrValue:(NSString *)attrValue {
    if (self = [super init]) {
        _severityReasonType = severityReason;
        _currentSeverity = severity;
        _originalSeverity = severity;
        _unhandled = unhandled;

        if (severityReason == Signal) {
            _attrValue = attrValue;
            _attrKey = @"signalType";
        } else if (severityReason == LogMessage) {
            _attrValue = attrValue;
            _attrKey = @"level";
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _unhandled = [dict[kPNLiteUnhandled] boolValue];
        _severityReasonType = [PNLiteHandledState
            severityReasonFromString:dict[kPNLiteSeverityReasonType]];
        _originalSeverity = BSGParseSeverity(dict[kPNLiteOriginalSeverity]);
        _currentSeverity = BSGParseSeverity(dict[kPNLiteCurrentSeverity]);
        _attrKey = dict[kPNLiteAttrKey];
        _attrValue = dict[kPNLiteAttrValue];
    }
    return self;
}

- (PNLiteSeverityReasonType)calculateSeverityReasonType {
    return _originalSeverity == _currentSeverity ? _severityReasonType
                                                 : UserCallbackSetSeverity;
}

+ (NSString *)stringFromSeverityReason:(PNLiteSeverityReasonType)severityReason {
    switch (severityReason) {
    case Signal:
        return kPNLiteSignal;
    case HandledError:
        return kPNLiteHandledError;
    case HandledException:
        return kPNLiteHandledException;
    case UserCallbackSetSeverity:
        return kPNLiteUserCallbackSetSeverity;
    case PromiseRejection:
        return kPNLitePromiseRejection;
    case UserSpecifiedSeverity:
        return kPNLiteUserSpecifiedSeverity;
    case LogMessage:
        return kPNLiteLogGenerated;
    case UnhandledException:
        return kPNLiteUnhandledException;
    }
}

+ (PNLiteSeverityReasonType)severityReasonFromString:(NSString *)string {
    if ([kPNLiteUnhandledException isEqualToString:string]) {
        return UnhandledException;
    } else if ([kPNLiteSignal isEqualToString:string]) {
        return Signal;
    } else if ([kPNLiteLogGenerated isEqualToString:string]) {
        return LogMessage;
    } else if ([kPNLiteHandledError isEqualToString:string]) {
        return HandledError;
    } else if ([kPNLiteHandledException isEqualToString:string]) {
        return HandledException;
    } else if ([kPNLiteUserSpecifiedSeverity isEqualToString:string]) {
        return UserSpecifiedSeverity;
    } else if ([kPNLiteUserCallbackSetSeverity isEqualToString:string]) {
        return UserCallbackSetSeverity;
    } else if ([kPNLitePromiseRejection isEqualToString:string]) {
        return PromiseRejection;
    } else {
        return UnhandledException;
    }
}

- (NSDictionary *)toJson {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[kPNLiteUnhandled] = @(self.unhandled);
    dict[kPNLiteSeverityReasonType] =
        [PNLiteHandledState stringFromSeverityReason:self.severityReasonType];
    dict[kPNLiteOriginalSeverity] = BSGFormatSeverity(self.originalSeverity);
    dict[kPNLiteCurrentSeverity] = BSGFormatSeverity(self.currentSeverity);
    dict[kPNLiteAttrKey] = self.attrKey;
    dict[kPNLiteAttrValue] = self.attrValue;
    return dict;
}

@end
