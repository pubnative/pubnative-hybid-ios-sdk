// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//


#import "PNLiteResponseModel.h"

@implementation PNLiteResponseModel

- (void)dealloc {
    self.status = nil;
    self.errorMessage = nil;
    self.ads = nil;
}

#pragma mark HyBidBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.status = dictionary[@"status"];
            self.errorMessage = dictionary[@"error_message"];
            self.ads = [HyBidAdModel parseArrayValues:dictionary[@"ads"]];
        }
    }
    return self;
}

@end
