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

@interface PNLiteVASTInterstitialPresenter : HyBidInterstitialPresenter

- (instancetype)initWithAd:(HyBidAd *)ad
            withSkipOffset:(HyBidSkipOffset *)skipOffset
         withCloseOnFinish:(BOOL)closeOnFinish;

@property (nonatomic, readwrite, assign) HyBidSkipOffset *skipOffset;
@property (nonatomic, readwrite, assign) BOOL closeOnFinish;

@end
