//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidJSBeaconLoader.h"

NS_ASSUME_NONNULL_BEGIN

/// Test-only stub: swaps +loadBeacon:completion: so callers get a synchronous result without a real WKWebView.
@interface HyBidJSBeaconLoader (Testing)

+ (void)hybid_stubLoadWithError:(nullable NSError *)error;
+ (void)hybid_removeLoadStub;

@end

NS_ASSUME_NONNULL_END
