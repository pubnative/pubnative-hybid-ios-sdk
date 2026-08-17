// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVASTInterstitialPresenter.h"
#import "PNLiteVASTPlayerInterstitialViewController.h"
#import "HyBidVASTPlayerPresentation.h"

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
    [HyBidVASTPlayerPresentation showPlayer:self.vastViewController onTopWithAd:self.ad];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [HyBidVASTPlayerPresentation showPlayer:self.vastViewController fromViewController:viewController];
}

- (void)hideFromViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:NO completion:nil];
}

@end
