// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidBaseModel.h"

@implementation HyBidBaseModel

- (void)dealloc {
    self.dictionary = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.dictionary = dictionary;
        }
    }
    return self;
}

+ (NSArray *)parseArrayValues:(NSArray *)array {
    NSMutableArray *result;
    if(array && [array isKindOfClass: [NSArray class]]) {
        result = [NSMutableArray array];
        for (NSDictionary *valueDictionary in array) {
            NSObject *value = [[self alloc] initWithDictionary:valueDictionary];
            [result addObject:value];
        }
    }
    return result;
}

@end
