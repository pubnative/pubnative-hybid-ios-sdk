// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdModel.h"

@implementation HyBidAdModel

- (void)dealloc {
    self.link = nil;
    self.assets = nil;
    self.meta = nil;
    self.beacons = nil;
    self.assetgroupid = nil;
}

#pragma mark HyBidBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.link = dictionary[@"link"];
            self.assetgroupid = dictionary[@"assetgroupid"];
            self.assets = [NSMutableArray arrayWithArray:[HyBidDataModel parseArrayValues:dictionary[@"assets"]]];
            self.meta = [HyBidDataModel parseArrayValues:dictionary[@"meta"]];
            self.beacons = [HyBidDataModel parseArrayValues:dictionary[@"beacons"]];
        }
    }
    return self;
}

#pragma mark HyBidAdModel

- (HyBidDataModel *)assetWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    result = [self dataWithType:type fromList:self.assets];
    return result;
}

- (HyBidDataModel *)metaWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    result = [self dataWithType:type fromList:self.meta];
    return result;
}

- (NSArray *)beaconsWithType:(NSString *)type {
    NSArray *result = nil;
    result = [self allWithType:type fromList:self.beacons];
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

- (NSArray *)allWithType:(NSString *)type
                fromList:(NSArray *)list {
    NSMutableArray *result = nil;
    if (list != nil) {
        for (HyBidDataModel *data in list) {
            if ([type isEqualToString:data.type]) {
                if (!result) {
                    result = [[NSMutableArray alloc] init];
                }
                [result addObject:data];
            }
        }
    }
    return result;
}

@end
