// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidProtocol.h"

@implementation HyBidProtocol

+ (NSString *)protocolTypeToString:(HyBidProtocolType)protocolType {
    NSArray *protocolTypes = @[
        @"1",
        @"2",
        @"3",
        @"4",
        @"5",
        @"6",
        @"7",
        @"8",
        @"11",
        @"12",
        @"13",
        @"14",
    ];
    return protocolTypes[protocolType];
}
@end
