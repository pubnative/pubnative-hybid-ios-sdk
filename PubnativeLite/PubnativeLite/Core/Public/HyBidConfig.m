// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidConfig.h"
#import "HyBidConfigParameter.h"

@interface HyBidConfig ()

@property (nonatomic, strong)HyBidConfigModel *data;

@end

@implementation HyBidConfig

- (void)dealloc {
    self.data = nil;
}

- (instancetype)initWithData:(HyBidConfigModel *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (BOOL)atomEnabled {
    BOOL result = NO;
    HyBidDataModel *data = [self appLevelDataWithType:HyBidConfigParameter.atomEnabled];
    if (data) {
        result = data.boolean;
    }
    return result;
}

- (HyBidDataModel *)appLevelDataWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    if (self.data) {
        result = [self.data appLevelWithType:type];
    }
    return result;
}

@end
