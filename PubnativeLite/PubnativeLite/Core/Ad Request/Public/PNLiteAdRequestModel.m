// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteAdRequestModel.h"

@implementation PNLiteAdRequestModel

- (void)dealloc {
    self.requestParameters = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestParameters = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
