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
                                       severity:PNLiteSeverityWarning
                                      attrValue:nil];
}

+ (instancetype)handledStateWithSeverityReason:
                    (PNLiteSeverityReasonType)severityReason
                                      severity:(PNLiteSeverity)severity
                                     attrValue:(NSString *)attrValue {
    BOOL unhandled = NO;

    switch (severityReason) {
    case PNLite_PromiseRejection:
        severity = PNLiteSeverityError;
        unhandled = YES;
        break;
    case PNLite_Signal:
        severity = PNLiteSeverityError;
        unhandled = YES;
        break;
    case PNLite_HandledError:
        severity = PNLiteSeverityWarning;
        break;
    case PNLite_HandledException:
        severity = PNLiteSeverityWarning;
        break;
    case PNLite_LogMessage:
    case PNLite_UserSpecifiedSeverity:
    case PNLite_UserCallbackSetSeverity:
        break;
    case PNLite_UnhandledException:
        severity = PNLiteSeverityError;
        unhandled = YES;
        break;
    }

    return [[PNLiteHandledState alloc] initWithSeverityReason:severityReason
                                                      severity:severity
                                                     unhandled:unhandled
                                                     attrValue:attrValue];
}

- (instancetype)initWithSeverityReason:(PNLiteSeverityReasonType)severityReason
                              severity:(PNLiteSeverity)severity
                             unhandled:(BOOL)unhandled
                             attrValue:(NSString *)attrValue {
    if (self = [super init]) {
        _severityReasonType = severityReason;
        _currentSeverity = severity;
        _originalSeverity = severity;
        _unhandled = unhandled;

        if (severityReason == PNLite_Signal) {
            _attrValue = attrValue;
            _attrKey = @"signalType";
        } else if (severityReason == PNLite_LogMessage) {
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
        _originalSeverity = PNLiteParseSeverity(dict[kPNLiteOriginalSeverity]);
        _currentSeverity = PNLiteParseSeverity(dict[kPNLiteCurrentSeverity]);
        _attrKey = dict[kPNLiteAttrKey];
        _attrValue = dict[kPNLiteAttrValue];
    }
    return self;
}

- (PNLiteSeverityReasonType)calculateSeverityReasonType {
    return _originalSeverity == _currentSeverity ? _severityReasonType
                                                 : PNLite_UserCallbackSetSeverity;
}

+ (NSString *)stringFromSeverityReason:(PNLiteSeverityReasonType)severityReason {
    switch (severityReason) {
    case PNLite_Signal:
        return kPNLiteSignal;
    case PNLite_HandledError:
        return kPNLiteHandledError;
    case PNLite_HandledException:
        return kPNLiteHandledException;
    case PNLite_UserCallbackSetSeverity:
        return kPNLiteUserCallbackSetSeverity;
    case PNLite_PromiseRejection:
        return kPNLitePromiseRejection;
    case PNLite_UserSpecifiedSeverity:
        return kPNLiteUserSpecifiedSeverity;
    case PNLite_LogMessage:
        return kPNLiteLogGenerated;
    case PNLite_UnhandledException:
        return kPNLiteUnhandledException;
    }
}

+ (PNLiteSeverityReasonType)severityReasonFromString:(NSString *)string {
    if ([kPNLiteUnhandledException isEqualToString:string]) {
        return PNLite_UnhandledException;
    } else if ([kPNLiteSignal isEqualToString:string]) {
        return PNLite_Signal;
    } else if ([kPNLiteLogGenerated isEqualToString:string]) {
        return PNLite_LogMessage;
    } else if ([kPNLiteHandledError isEqualToString:string]) {
        return PNLite_HandledError;
    } else if ([kPNLiteHandledException isEqualToString:string]) {
        return PNLite_HandledException;
    } else if ([kPNLiteUserSpecifiedSeverity isEqualToString:string]) {
        return PNLite_UserSpecifiedSeverity;
    } else if ([kPNLiteUserCallbackSetSeverity isEqualToString:string]) {
        return PNLite_UserCallbackSetSeverity;
    } else if ([kPNLitePromiseRejection isEqualToString:string]) {
        return PNLite_PromiseRejection;
    } else {
        return PNLite_UnhandledException;
    }
}

- (NSDictionary *)toJson {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[kPNLiteUnhandled] = @(self.unhandled);
    dict[kPNLiteSeverityReasonType] =
        [PNLiteHandledState stringFromSeverityReason:self.severityReasonType];
    dict[kPNLiteOriginalSeverity] = PNLiteFormatSeverity(self.originalSeverity);
    dict[kPNLiteCurrentSeverity] = PNLiteFormatSeverity(self.currentSeverity);
    dict[kPNLiteAttrKey] = self.attrKey;
    dict[kPNLiteAttrValue] = self.attrValue;
    return dict;
}

@end
