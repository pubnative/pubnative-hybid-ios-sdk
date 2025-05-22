// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidNativeAdRequest.h"

@implementation HyBidNativeAdRequest

- (HyBidAdSize *)adSize {
    return HyBidAdSize.SIZE_NATIVE;
}

- (NSArray<NSString *> *)supportedAPIFrameworks {
    return nil;
}

@end
