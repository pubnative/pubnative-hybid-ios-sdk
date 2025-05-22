// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidInterstitialPresenter.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidInterstitialPresenter

- (void)dealloc {
    self.delegate = nil;
}

- (void)load {
    // Do nothing, this method should be overriden
}

- (void)show {
    // Do nothing, this method should be overriden
}

- (void)showFromViewController:(UIViewController *)viewController {
    // Do nothing, this method should be overriden
}

- (void)hideFromViewController:(UIViewController *)viewController
{
    // Do nothing, this method should be overriden
}

- (HyBidAd *)ad {
    return nil;
}

@end
