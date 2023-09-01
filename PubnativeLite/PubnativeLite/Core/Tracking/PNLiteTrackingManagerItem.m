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
#import "PNLiteTrackingManagerItem.h"

NSString * const PNLiteTrackingManagerURLKey = @"url";
NSString * const PNLiteTrackingManagerTimestampKey = @"timestamp";
NSString * const PNLiteTrackingManagerTypeKey = @"type";

@implementation PNLiteTrackingManagerItem

- (void)dealloc {
    self.url = nil;
    self.timestamp = nil;
    self.type = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        self.url = [NSURL URLWithString:dictionary[PNLiteTrackingManagerURLKey]];
        self.timestamp = dictionary[PNLiteTrackingManagerTimestampKey];
        self.type = dictionary[PNLiteTrackingManagerTypeKey];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.url) {
        [dictionary setObject:[self.url absoluteString] forKey:PNLiteTrackingManagerURLKey];
    }
    
    if (self.timestamp) {
        [dictionary setObject:self.timestamp forKey:PNLiteTrackingManagerTimestampKey];
    }
    
    if (self.type) {
        [dictionary setObject:self.type forKey:PNLiteTrackingManagerTypeKey];
    }
    
    return dictionary;
}

@end
