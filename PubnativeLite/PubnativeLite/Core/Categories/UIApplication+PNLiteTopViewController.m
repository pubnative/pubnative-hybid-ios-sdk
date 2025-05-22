// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "UIApplication+PNLiteTopViewController.h"

@implementation UIApplication (PNLiteTopViewController)

- (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = tabController.selectedViewController;
        return [self topViewController:lastViewController];
    }
    
    if (rootViewController.childViewControllers.count > 0) {
        return [self topViewController: rootViewController.childViewControllers.lastObject];
    }
    
    if (!rootViewController.presentedViewController) {
        return rootViewController;
    }
    
    UIViewController* presentedViewController = rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
