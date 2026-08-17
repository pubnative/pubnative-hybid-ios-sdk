//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTPlayerPresentation.h"
#import "UIApplication+PNLiteTopViewController.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface HyBidVASTPlayerPresentation()

+ (BOOL)presentPlayer:(UIViewController *)player fromViewController:(UIViewController *)viewController;

@end

@implementation HyBidVASTPlayerPresentation

+ (void)showPlayer:(UIViewController *)player onTopWithAd:(HyBidAd *)ad {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self presentPlayer:player fromViewController:[UIApplication sharedApplication].topViewController]) {
            [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.SHOW ad:ad];
        }
    });
}

+ (void)showPlayer:(UIViewController *)player fromViewController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentPlayer:player fromViewController:viewController];
    });
}

+ (BOOL)presentPlayer:(UIViewController *)player fromViewController:(UIViewController *)viewController {
    if (!player || !viewController || viewController == player) { return NO; }
    if (player.presentingViewController || player.isBeingPresented) { return NO; }
    [viewController presentViewController:player animated:NO completion:nil];
    return YES;
}

@end
