// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif
#import "HyBidSKAdNetworkViewController.h"
#import "UIApplication+PNLiteTopViewController.h"

typedef NS_ENUM(NSInteger) {
    HyBidOverrideSuperClassOption,
    HyBidOverrideWithPresentingViewControllerOption,
    HyBidOverrideWithCustomImplementationOption
} HyBidOverrideOptionsType;

NSDictionary *productParameters;

@interface HyBidSKAdNetworkViewController ()
@property (nonatomic, weak) id<SKStoreProductViewControllerDelegate> delegate;
@end

@implementation HyBidSKAdNetworkViewController

- (id)initWithProductParameters:(NSDictionary *)parameters delegate:(id<SKStoreProductViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        productParameters = parameters;
        self.delegate = delegate;
    }
    
    return self;
}

- (void)dealloc
{
    productParameters = nil;
    self.delegate = nil;
}

- (void)loadProducts:(NSDictionary *)productParameters completionHandler:(void (^)(BOOL success, SKStoreProductViewController * _Nullable skAdnetworkViewController, NSError * _Nullable error))completionHandler {
    
    SKStoreProductViewController *skAdnetworkViewController = [[SKStoreProductViewController alloc] init];
    skAdnetworkViewController.delegate = self.delegate;
    [skAdnetworkViewController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        #if !(TARGET_IPHONE_SIMULATOR)
            if (!error && result) {
                completionHandler(YES, skAdnetworkViewController, nil);
                return;
            }

            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Loading the ad failed, try to load another ad or retry the current ad."];
            completionHandler(NO, nil, error);
            return;
        #endif
    }];
    
    #if TARGET_IPHONE_SIMULATOR
        completionHandler(YES, skAdnetworkViewController, nil);
        return;
    #endif
}

- (void)presentInTopViewController:(SKStoreProductViewController *)skAdnetworkViewController
                 completionHandler:(void (^)(BOOL success))completionHandler {
    UIViewController *presenterViewController = [UIApplication sharedApplication].topViewController;
    
    if ([presenterViewController isMemberOfClass:[SKStoreProductViewController class]] ||
        [presenterViewController isMemberOfClass:[NSClassFromString(@"SKProductPageRemoteViewController") class]] ||
        [presenterViewController.presentedViewController isMemberOfClass: [SKStoreProductViewController class]]) {
        [skAdnetworkViewController loadProductWithParameters:productParameters completionBlock:nil];
        return completionHandler(NO);
    }

    if (![presenterViewController isEqual: [UIApplication sharedApplication].topViewController] || presenterViewController.isBeingDismissed) {
        return completionHandler(NO);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [presenterViewController presentViewController: skAdnetworkViewController animated: YES completion:^{
            return completionHandler(YES);
        }];
    });
}

- (void)presentSKStoreProductViewController:(void (^)(BOOL success))completionHandler {
    [self presentSKStoreProductViewControllerWithBlock:^(BOOL success, NSError *error) {
        completionHandler(success);
    }];
}

- (void)presentSKStoreProductViewControllerWithBlock:(HyBidSKProductViewBlock)completionHandler {
    [self loadProducts: productParameters completionHandler:^(BOOL success, SKStoreProductViewController * _Nullable skAdnetworkViewController, NSError *error) {
        if (success) {
            [HyBidNotificationCenter.shared post: HyBidNotificationTypeSKStoreProductViewIsReadyToPresent object: nil userInfo: nil];
            [self presentInTopViewController:skAdnetworkViewController completionHandler:^(BOOL success) {
                [HyBidNotificationCenter.shared post: HyBidNotificationTypeSKStoreProductViewIsShown object: nil userInfo: nil];
                completionHandler(success, nil);
            }];
        } else {
            completionHandler(NO, error);
        }
    }];
}

@end

@implementation SKStoreProductViewController (HyBidCustomMethods)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (@available(iOS 17.2, *)) {
        [self loadProductWithParameters:productParameters completionBlock:nil];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    HyBidOverrideOptionsType overrideOption = [self hyBidDetermineOverrideOptionWith: self.presentingViewController selector: @selector(supportedInterfaceOrientations)];
    switch (overrideOption) {
        case HyBidOverrideSuperClassOption:
            return super.supportedInterfaceOrientations;
        case HyBidOverrideWithPresentingViewControllerOption:
            return self.presentingViewController.supportedInterfaceOrientations;
        case HyBidOverrideWithCustomImplementationOption:
            return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)shouldAutorotate {
    
    HyBidOverrideOptionsType overrideOption = [self hyBidDetermineOverrideOptionWith: self.presentingViewController selector: @selector(shouldAutorotate)];
    switch (overrideOption) {
        case HyBidOverrideSuperClassOption:
            return super.shouldAutorotate;
        case HyBidOverrideWithPresentingViewControllerOption:
            return self.presentingViewController.shouldAutorotate;
        case HyBidOverrideWithCustomImplementationOption:{
            UIInterfaceOrientationMask applicationSupportedOrientations = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[[UIApplication sharedApplication] keyWindow]];
            UIInterfaceOrientationMask viewControllerSupportedOrientations = [self supportedInterfaceOrientations];
            return viewControllerSupportedOrientations & applicationSupportedOrientations;
        }
    }
}

- (HyBidOverrideOptionsType)hyBidDetermineOverrideOptionWith:(UIViewController * _Nullable)presentingViewController selector:(SEL)selector {
    if (!presentingViewController) { return HyBidOverrideSuperClassOption; }

    NSString *presentingVCBundleID = [NSBundle bundleForClass: [presentingViewController class]].bundleIdentifier;
    if (!presentingVCBundleID) { return HyBidOverrideSuperClassOption; }
    
    NSString *hyBidBundleID = [NSBundle bundleForClass: [HyBidSKAdNetworkViewController class]].bundleIdentifier;
    if (!hyBidBundleID) { return HyBidOverrideSuperClassOption; }
    
    if (![presentingVCBundleID isEqualToString: hyBidBundleID]) {
        return [[presentingViewController class] instancesRespondToSelector:selector]
        ? HyBidOverrideWithPresentingViewControllerOption
        : HyBidOverrideSuperClassOption;
    }
    
    return HyBidOverrideWithCustomImplementationOption;
}

@end
