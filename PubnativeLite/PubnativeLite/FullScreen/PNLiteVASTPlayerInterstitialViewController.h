// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidInterstitialPresenter.h"
#import "HyBidAd.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteVASTPlayerInterstitialViewController : UIViewController

- (void)loadFullScreenPlayerWithPresenter:(HyBidInterstitialPresenter *)interstitialPresenter withAd:(HyBidAd *)ad withSkipOffset:(HyBidSkipOffset *)skipOffset;

@property (nonatomic, assign) BOOL closeOnFinish;

@end
