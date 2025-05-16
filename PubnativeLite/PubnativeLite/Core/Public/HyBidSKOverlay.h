// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "HyBidAd.h"
#import "HyBidTimerState.h"
#import "HyBidSKOverlayTimerType.h"
#import "HyBidSKOverlayDelegate.h"

@interface HyBidSKOverlay : NSObject

- (instancetype)initWithAd:(HyBidAd *)ad
                isRewarded:(BOOL)isRewarded
                  delegate:(NSObject <HyBidSKOverlayDelegate> *)delegate;
- (void)presentWithAd:(HyBidAd *)ad;
- (void)dismissEntirely:(BOOL)completed withAd:(HyBidAd *)ad causedByAutoCloseTimerCompletion:(BOOL)autoCloseTimerCompleted;
- (void)updateTimerStateWithRemainingSeconds:(NSInteger)seconds
                              withTimerState:(HyBidTimerState)timerState
                                forTimerType:(HyBidSKOverlayTimerType)timerType;
- (void)addObservers;
- (void)changeDelegateFor:(NSObject <HyBidSKOverlayDelegate> *)delegate;
+ (BOOL)isValidToCreateSKOverlayWithModel:(HyBidSkAdNetworkModel *)skAdNetworkModel;

@end
