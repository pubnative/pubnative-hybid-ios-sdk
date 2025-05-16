// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAPI.h"

@implementation HyBidAPI

+ (NSString *)apiTypeToString:(HyBidAPIType)apiType {
    NSArray *apiTypes = @[
        @"3",
        @"5",
        @"6",
        @"7",
    ];
    return apiTypes[apiType];
}

@end
