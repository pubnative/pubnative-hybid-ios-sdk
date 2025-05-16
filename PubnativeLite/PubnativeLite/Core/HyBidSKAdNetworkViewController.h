// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <StoreKit/SKStoreProductViewController.h>

@interface HyBidSKAdNetworkViewController: NSObject

typedef void(^HyBidSKProductViewBlock)(BOOL success, NSError *error);

- (id)initWithProductParameters:(NSDictionary*)productParameters delegate:(id<SKStoreProductViewControllerDelegate>)delegate;
- (void)presentSKStoreProductViewControllerWithBlock:(HyBidSKProductViewBlock)completionHandler;
- (void)presentSKStoreProductViewController:(void (^)(BOOL success))completionHandler;
@end

