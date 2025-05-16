// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidRewardedPresenter.h"

@interface PNLiteVASTRewardedPresenter : HyBidRewardedPresenter

- (instancetype)initWithAd:(HyBidAd *)ad
         withCloseOnFinish:(BOOL)closeOnFinish;

@property (nonatomic, readwrite, assign) BOOL closeOnFinish;

@end
