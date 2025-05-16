// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidGADBaseCustomEvent.h"
#import "HyBidGADUtils.h"

@implementation HyBidGADBaseCustomEvent

#pragma mark - GADMediationAdapter

+ (GADVersionNumber)adSDKVersion {
    return [HyBidGADUtils adSDKVersion];
}

+ (GADVersionNumber)adapterVersion {
    return [HyBidGADUtils adapterVersion];
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return [HyBidGADUtils networkExtrasClass];
}

@end
