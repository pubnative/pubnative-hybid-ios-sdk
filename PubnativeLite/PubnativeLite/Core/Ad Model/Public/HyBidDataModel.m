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

#import "HyBidDataModel.h"
#import "PNLiteMeta.h"
#import "PNLiteData.h"

@implementation HyBidDataModel

- (void)dealloc {
    self.type = nil;
    self.data = nil;
}

#pragma mark HyBidBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.type = dictionary[@"type"];
        self.data = dictionary[@"data"];
    }
    return self;
}

- (instancetype)initWithHTMLAsset:(NSString *)assetName withValue:(NSString *)value {
    self = [super initWithDictionary:[NSDictionary dictionary]];
    if (self) {
        self.type = assetName;
        self.data = [NSDictionary dictionaryWithObjectsAndKeys:value, @"html", nil];
    }
    return self;
}

- (instancetype)initWithVASTAsset:(NSString *)assetName withValue:(NSString *)value {
    self = [super initWithDictionary:[NSDictionary dictionary]];
    if (self) {
        self.type = assetName;
        self.data = [NSDictionary dictionaryWithObjectsAndKeys:value, @"vast2", nil];
    }
    return self;
}

#pragma mark HyBidDataModel

- (NSString *)text {
    return [self stringFieldWithKey:PNLiteData.text];
}

- (NSString *)vast {
    return [self stringFieldWithKey:PNLiteData.vast];
}

- (NSNumber *)number {
    return [self numberFieldWithKey:PNLiteData.number];
}

- (NSString *)url {
    return [self stringFieldWithKey:PNLiteData.url];
}

- (NSString *)js {
    return [self stringFieldWithKey:PNLiteData.js];
}

- (NSString *)html {
    return [self stringFieldWithKey:PNLiteData.html];
}

- (NSNumber *)eCPM {
    return [self numberFieldWithKey:PNLiteData.number];
}

- (NSNumber *)width {
    return [self numberFieldWithKey:PNLiteData.width];
}

- (NSNumber *)height {
    return [self numberFieldWithKey:PNLiteData.height];
}

- (NSDictionary *)jsonData {
    return [self dictionaryFieldWithKey:PNLiteData.jsonData];
}

- (NSString *)stringFieldWithKey:(NSString *)key {
    return (NSString *) [self dataForKey:key];
}

- (NSNumber *)numberFieldWithKey:(NSString *)key {
    return (NSNumber *) [self dataForKey:key];
}

- (NSObject *)dataForKey:(NSString *)key {
    NSObject *result = nil;
    if (self.data != nil && [self hasFieldForKey:key]) {
        result = [self.data objectForKey:key];
    }
    return result;
}

- (BOOL)hasFieldForKey:(NSString *)key {
    return [self.data objectForKey:key] ? YES : NO;
}

- (NSDictionary *)dictionaryFieldWithKey:(NSString *)key {
    return (NSDictionary *) [self dataForKey:key];
}

@end
