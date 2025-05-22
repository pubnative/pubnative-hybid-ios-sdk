// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

typedef enum {
    MRAID_1,
    MRAID_2,
    MRAID_3,
    OMID_1,
} HyBidAPIType;

@interface HyBidAPI : NSObject

+ (NSString *)apiTypeToString:(HyBidAPIType)apiType;

@end
