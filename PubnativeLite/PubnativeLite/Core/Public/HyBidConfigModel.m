// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidConfigModel.h"

@implementation HyBidConfigModel

- (void)dealloc {
    self.appLevel = nil;
}

#pragma mark HyBidBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.appLevel = [NSMutableArray arrayWithArray:[HyBidDataModel parseArrayValues:dictionary[@"app_level"]]];
        }
    }
    return self;
}

#pragma mark HyBidConfigModel

- (HyBidDataModel *)appLevelWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    result = [self dataWithType:type fromList:self.appLevel];
    return result;
}


- (HyBidDataModel *)dataWithType:(NSString *)type
                        fromList:(NSArray *)list {
    HyBidDataModel *result = nil;
    if (list != nil) {
        for (HyBidDataModel *data in list) {
            if ([type isEqualToString:data.type]) {
                result = data;
                break;
            }
        }
    }
    return result;
}
@end
