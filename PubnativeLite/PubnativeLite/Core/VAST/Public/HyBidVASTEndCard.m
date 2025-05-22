// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTEndCard.h"

@implementation HyBidVASTEndCard

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clickTrackings = [NSArray new];
    }
    return self;
}

@end
