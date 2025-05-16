// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <AppLovinSDK/AppLovinSDK.h>
#import <HyBid/HyBid.h>
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface AppLovinMediationVerveCustomNetworkAdapter : ALMediationAdapter <MAAdViewAdapter, MAInterstitialAdapter, MARewardedAdapter, MANativeAdAdapter>

@end
