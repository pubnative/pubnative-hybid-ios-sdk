// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.type = dictionary[@"type"];
            self.data = dictionary[@"data"];
        }
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

- (BOOL)boolean {
    return [[self numberFieldWithKey:PNLiteData.boolean] isKindOfClass:[NSNumber class]] ? [[self numberFieldWithKey:PNLiteData.boolean] boolValue] : false;
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
