// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//


#import "HyBidGAMBaseCustomEvent.h"
#import "HyBidGAMUtils.h"

@implementation HyBidGAMBaseCustomEvent

#pragma mark - GADMediationAdapter

+ (GADVersionNumber)adSDKVersion {
    return [HyBidGAMUtils adSDKVersion];
}

+ (GADVersionNumber)adapterVersion {
    return [HyBidGAMUtils adapterVersion];
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return [HyBidGAMUtils networkExtrasClass];
}

@end
