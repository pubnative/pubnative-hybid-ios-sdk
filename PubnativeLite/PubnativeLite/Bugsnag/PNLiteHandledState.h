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

#import "BugsnagCrashReport.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PNLiteSeverityReasonType) {
    UnhandledException,
    Signal,
    HandledError,
    HandledException,
    UserSpecifiedSeverity,
    UserCallbackSetSeverity,
    PromiseRejection,
    LogMessage
};

@interface PNLiteHandledState : NSObject

@property(nonatomic, readonly) BOOL unhandled;
@property(nonatomic, readonly) PNLiteSeverityReasonType severityReasonType;
@property(nonatomic, readonly) BSGSeverity originalSeverity;
@property(nonatomic) BSGSeverity currentSeverity;
@property(nonatomic, readonly) PNLiteSeverityReasonType calculateSeverityReasonType;
@property(nonatomic, readonly) NSString *attrValue;
@property(nonatomic, readonly) NSString *attrKey;

+ (NSString *)stringFromSeverityReason:(PNLiteSeverityReasonType)severityReason;
+ (PNLiteSeverityReasonType)severityReasonFromString:(NSString *)string;

+ (instancetype)handledStateWithSeverityReason:
    (PNLiteSeverityReasonType)severityReason;

+ (instancetype)handledStateWithSeverityReason:
                    (PNLiteSeverityReasonType)severityReason
                                      severity:(BSGSeverity)severity
                                     attrValue:(NSString *)attrValue;

- (NSDictionary *)toJson;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
