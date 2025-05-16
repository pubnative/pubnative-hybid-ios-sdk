// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVASTRewardedPresenter.h"
#import "PNLiteVASTPlayerRewardedViewController.h"
#import "UIApplication+PNLiteTopViewController.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteVASTRewardedPresenter()

@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerRewardedViewController *vastViewController;

@end

@implementation PNLiteVASTRewardedPresenter

- (void)dealloc {
    self.adModel = nil;
    self.vastViewController = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad
         withCloseOnFinish:(BOOL)closeOnFinish{
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.closeOnFinish = closeOnFinish;
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.vastViewController = [PNLiteVASTPlayerRewardedViewController new];
    self.vastViewController.closeOnFinish = self.closeOnFinish;
    [self.vastViewController setModalPresentationStyle: UIModalPresentationFullScreen];
    [self.vastViewController loadFullScreenPlayerWithPresenter:self withAd:self.adModel];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].topViewController presentViewController:self.vastViewController animated:NO completion:nil];
    });
    
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.SHOW ad:self.ad];
}

- (void)showFromViewController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:self.vastViewController animated:NO completion:nil];
    });
}

- (void)hideFromViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:NO completion:nil];
}

@end
