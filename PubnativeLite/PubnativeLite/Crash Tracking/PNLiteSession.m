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
#import "PNLiteCollections.h"
#import "PNLite_RFC3339DateTool.h"

static NSString *const kPNLiteSessionId = @"id";
static NSString *const kPNLiteUnhandledCount = @"unhandledCount";
static NSString *const kPNLiteHandledCount = @"handledCount";
static NSString *const kPNLiteStartedAt = @"startedAt";
static NSString *const kPNLiteUser = @"user";

@implementation PNLiteSession

- (instancetype)initWithId:(NSString *_Nonnull)sessionId
                 startDate:(NSDate *_Nonnull)startDate
                      user:(PNLiteUser *_Nullable)user
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
        _sessionId = dict[kPNLiteSessionId];
        _unhandledCount = [dict[kPNLiteUnhandledCount] unsignedIntegerValue];
        _handledCount = [dict[kPNLiteHandledCount] unsignedIntegerValue];
        _startedAt = [PNLite_RFC3339DateTool dateFromString:dict[kPNLiteStartedAt]];

        NSDictionary *userDict = dict[kPNLiteUser];

        if (userDict) {
            _user = [[PNLiteUser alloc] initWithDictionary:userDict];
        }
    }
    return self;
}

- (NSDictionary *)toJson {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    PNLiteDictInsertIfNotNil(dict, self.sessionId, kPNLiteSessionId);
    PNLiteDictInsertIfNotNil(dict, [PNLite_RFC3339DateTool stringFromDate:self.startedAt], kPNLiteStartedAt);

    if (self.user) {
        PNLiteDictInsertIfNotNil(dict, [self.user toJson], kPNLiteUser);
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
