// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

typedef enum {
    VAST_1_0,
    VAST_2_0,
    VAST_3_0,
    VAST_1_0_WRAPPER,
    VAST_2_0_WRAPPER,
    VAST_3_0_WRAPPER,
    VAST_4_0,
    VAST_4_0_WRAPPER,
    VAST_4_1,
    VAST_4_1_WRAPPER,
    VAST_4_2,
    VAST_4_2_WRAPPER,
} HyBidProtocolType;

@interface HyBidProtocol : NSObject

+ (NSString *)protocolTypeToString:(HyBidProtocolType)protocolType;

@end
