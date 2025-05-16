// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidRewardedPresenter.h"

@interface PNLiteVASTPlayerRewardedViewController : UIViewController

- (void)loadFullScreenPlayerWithPresenter:(HyBidRewardedPresenter *)rewardedPresenter withAd:(HyBidAd *)ad;

@property (nonatomic, assign) BOOL closeOnFinish;

@end
