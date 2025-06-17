// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "ISVerveCustomAdapter.h"
#import "ISVerveUtils.h"

@implementation ISVerveCustomAdapter

- (void)init:(ISAdData *)adData delegate:(id<ISNetworkInitializationDelegate>)delegate {
    if (![ISVerveUtils isAppTokenValid:adData]) {
        if ([HyBid isInitialized]) {
            if (delegate && [delegate respondsToSelector:@selector(onInitDidSucceed)]) {
                [delegate onInitDidSucceed];
            }
        } else if (delegate && [delegate respondsToSelector:@selector(onInitDidFailWithErrorCode:errorMessage:)]) {
            [delegate onInitDidFailWithErrorCode:ISAdapterErrorMissingParams
                                       errorMessage:@"HyBid initialisation failed: Missing app token"];
        }
    } else {
        [HyBid initWithAppToken:[ISVerveUtils appToken:adData] completion:^(BOOL success) {
            if (delegate && [delegate respondsToSelector:@selector(onInitDidSucceed)]) {
                [delegate onInitDidSucceed];
            }
        }];
    }
}

- (NSString *)networkSDKVersion {
    return @"3.6.1-beta3";
}

- (NSString *)adapterVersion {
    return @"3.6.1-beta3.0";
}

@end
