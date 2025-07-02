// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidConfigResponseModel.h"

@implementation HyBidConfigResponseModel

- (void)dealloc {
    self.status = nil;
    self.errorMessage = nil;
    self.configs = nil;
}

#pragma mark HyBidBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.status = dictionary[@"status"];
            self.errorMessage = dictionary[@"error_message"];
            self.configs = dictionary[@"configs"];
        }
    }
    return self;
}
@end
