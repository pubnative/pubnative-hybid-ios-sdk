// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidOpenRTBDataModel.h"
#import "PNLiteMeta.h"
#import "PNLiteData.h"

@implementation HyBidOpenRTBDataModel

- (void)dealloc {
    self.data = nil;
    self.type = nil;
}

#pragma mark HyBidBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            if (dictionary[@"data"] != nil) {
                NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                self.type = dictionary[@"data"][@"label"];
                
                id value = dictionary[@"data"][@"value"];
                [newDict setObject:value forKey:([self.type isEqual: @"rating"] ? @"number" : @"text")];
                [newDict removeObjectForKey:@"value"];
                
                self.data = newDict;
            } else if (dictionary[@"img"] != nil) {
                NSDictionary *typeDict = @{@1: @"icon", @3: @"banner"};
                self.type = typeDict[dictionary[@"img"][@"type"]];
                self.data = dictionary[@"img"];
            } else if (dictionary[@"title"] != nil) {
                self.type = @"title";
                self.data = dictionary[@"title"];
            } else if (dictionary[@"skadn"] != nil) {
                self.type = [PNLiteMeta skadnetwork];
                self.data = dictionary[@"skadn"];
            }
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary preferedValue:(NSString *)key {
    self = [super initWithDictionary:dictionary];
    if (self && [dictionary isKindOfClass:[NSDictionary class]] && dictionary[key] != nil) {
        self.type = key;
        self.data = dictionary[key];
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

#pragma mark HyBidOpenRTBDataModel

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

- (NSString *)html {
    return [self stringFieldWithKey:PNLiteData.html];
}

- (NSString *)stringFieldWithKey:(NSString *)key {
    return (NSString *) [self dataWithKey:key];
}

- (NSNumber *)numberFieldWithKey:(NSString *)key {
    return (NSNumber *) [self dataWithKey:key];
}

- (NSObject *)dataWithKey:(NSString *)key {
    NSObject *result = nil;
    if (self.data != nil && [self.data objectForKey:key]) {
        result = [self.data objectForKey:key];
    }
    return result;
}

@end
