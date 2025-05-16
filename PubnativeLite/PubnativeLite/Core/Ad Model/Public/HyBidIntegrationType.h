// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

typedef enum {
    HEADER_BIDDING,
    IN_APP_BIDDING,
    MEDIATION,
    STANDALONE,
} IntegrationType;

@interface HyBidIntegrationType : NSObject

+ (NSString *)integrationTypeToString:(IntegrationType)integrationType;

@end
