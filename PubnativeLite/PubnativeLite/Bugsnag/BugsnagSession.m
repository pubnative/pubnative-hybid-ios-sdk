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

#import "PNLiteSession.h"
#import "BugsnagCollections.h"
#import "BSG_RFC3339DateTool.h"

static NSString *const kBugsnagSessionId = @"id";
static NSString *const kBugsnagUnhandledCount = @"unhandledCount";
static NSString *const kBugsnagHandledCount = @"handledCount";
static NSString *const kBugsnagStartedAt = @"startedAt";
static NSString *const kBugsnagUser = @"user";

@implementation PNLiteSession

- (instancetype)initWithId:(NSString *_Nonnull)sessionId
                 startDate:(NSDate *_Nonnull)startDate
                      user:(BugsnagUser *_Nullable)user
              autoCaptured:(BOOL)autoCaptured {

    if (self = [super init]) {
        _sessionId = sessionId;
        _startedAt = [startDate copy];
        _user = user;
        _autoCaptured = autoCaptured;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *_Nonnull)dict {
    if (self = [super init]) {
        _sessionId = dict[kBugsnagSessionId];
        _unhandledCount = [dict[kBugsnagUnhandledCount] unsignedIntegerValue];
        _handledCount = [dict[kBugsnagHandledCount] unsignedIntegerValue];
        _startedAt = [BSG_RFC3339DateTool dateFromString:dict[kBugsnagStartedAt]];

        NSDictionary *userDict = dict[kBugsnagUser];

        if (userDict) {
            _user = [[BugsnagUser alloc] initWithDictionary:userDict];
        }
    }
    return self;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    BSGDictInsertIfNotNil(dict, self.sessionId, kBugsnagSessionId);
    BSGDictInsertIfNotNil(dict, [BSG_RFC3339DateTool stringFromDate:self.startedAt], kBugsnagStartedAt);

    if (self.user) {
        BSGDictInsertIfNotNil(dict, [self.user toJson], kBugsnagUser);
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end