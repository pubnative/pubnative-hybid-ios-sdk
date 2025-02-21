//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
#import <objc/runtime.h>

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
        return doesClassHasMethod([presentingViewController class], selector)
        ? HyBidOverrideWithPresentingViewControllerOption
        : HyBidOverrideSuperClassOption;
    }
    
    return HyBidOverrideWithCustomImplementationOption;
}

// Method to detect during run time whether the presentingViewController overrides or not shouldAutorotate & supportedInterfaceOrientations method (due the use of a Category)
BOOL doesClassHasMethod(Class cls, SEL sel) {
    unsigned int methodCount;
    Method *methods = class_copyMethodList(cls, &methodCount);

    BOOL result = NO;
    for (unsigned int i = 0; i < methodCount; ++i) {
        if (method_getName(methods[i]) == sel) {
            result = YES;
            break;
        }
    }

    free(methods);
    return result;
}

@end
