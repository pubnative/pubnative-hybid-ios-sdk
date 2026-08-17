// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVASTRewardedPresenter.h"
#import "PNLiteVASTPlayerRewardedViewController.h"
#import "HyBidVASTPlayerPresentation.h"
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
    [HyBidVASTPlayerPresentation showPlayer:self.vastViewController onTopWithAd:self.ad];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [HyBidVASTPlayerPresentation showPlayer:self.vastViewController fromViewController:viewController];
}

- (void)hideFromViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:NO completion:nil];
}

@end
