// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
