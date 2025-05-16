// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidIntegrationType.h"

@implementation HyBidIntegrationType

+ (NSString *)integrationTypeToString:(IntegrationType)integrationType {
    NSArray *integrationTypes = @[
                                  @"hb",
                                  @"b",
                                  @"m",
                                  @"s",
                                  ];
    return integrationTypes[integrationType];
}
@end
