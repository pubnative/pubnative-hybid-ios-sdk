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

#import "PNLiteUser.h"
#import "PNLiteCollections.h"

@implementation PNLiteUser

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _userId = dict[@"id"];
        _emailAddress = dict[@"emailAddress"];
        _name = dict[@"name"];
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name emailAddress:(NSString *)emailAddress {
    self = [super init];
    if (self) {
        self.userId = userId;
        self.name = name;
        self.emailAddress = emailAddress;
    }
    return self;
}

+ (instancetype)userWithUserId:(NSString *)userId name:(NSString *)name emailAddress:(NSString *)emailAddress {
    return [[self alloc] initWithUserId:userId name:name emailAddress:emailAddress];
}


- (NSDictionary *)toJson {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    BSGDictInsertIfNotNil(dict, self.userId, @"id");
    BSGDictInsertIfNotNil(dict, self.emailAddress, @"emailAddress");
    BSGDictInsertIfNotNil(dict, self.name, @"name");
    return [NSDictionary dictionaryWithDictionary:dict];
}
@end
