// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVASTInterstitialPresenter.h"
#import "PNLiteVASTPlayerInterstitialViewController.h"
#import "UIApplication+PNLiteTopViewController.h"

@interface PNLiteVASTInterstitialPresenter()

@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerInterstitialViewController *vastViewController;

@end

@implementation PNLiteVASTInterstitialPresenter

- (void)dealloc {
    self.adModel = nil;
    self.vastViewController = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad
            withSkipOffset:(HyBidSkipOffset *)skipOffset
         withCloseOnFinish:(BOOL)closeOnFinish {
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.skipOffset = skipOffset;
        self.closeOnFinish = closeOnFinish;
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.vastViewController = [PNLiteVASTPlayerInterstitialViewController new];
    self.vastViewController.closeOnFinish = self.closeOnFinish;
    [self.vastViewController setModalPresentationStyle: UIModalPresentationFullScreen];
    [self.vastViewController loadFullScreenPlayerWithPresenter:self withAd:self.adModel withSkipOffset:self.skipOffset];
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

- (void)hideFromViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:NO completion:nil];
}

@end
