// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidSignalDataModel.h"

@implementation HyBidSignalDataModel

- (void)dealloc {
    self.status = nil;
    self.tagid = nil;
    self.admurl = nil;
    self.adm = nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.status = dictionary[@"status"];
            self.tagid = dictionary[@"tagid"];
            self.admurl = dictionary[@"admurl"];
            self.adm = [[PNLiteResponseModel alloc] initWithDictionary:dictionary[@"adm"]];
        }
    }
    return self;
}

@end
