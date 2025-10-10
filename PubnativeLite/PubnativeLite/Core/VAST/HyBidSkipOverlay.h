// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidTimerState.h"
#import "HyBidAd.h"

@protocol HyBidSkipOverlayDelegate <NSObject>

- (void)skipButtonTapped;
@optional
- (void)skipTimerCompleted;
- (void)skipOverlayStarts;
@end

@interface HyBidSkipOverlay : UIView

- (id)initWithSkipOffset:(NSInteger)skipOffset withCountdownStyle:(HyBidCountdownStyle)countdownStyle withContentInfoPositionTopLeft:(BOOL)isContentInfoInTopLeftPosition withShouldShowSkipButton:(BOOL)shouldShowSkipButton ad:(HyBidAd *)ad;

- (void)addSkipOverlayViewIn:(UIView *)adView delegate:(id<HyBidSkipOverlayDelegate>)delegate;
- (void)updateTimerStateWithRemainingSeconds:(NSInteger)seconds withTimerState:(HyBidTimerState)timerState;
- (NSInteger)getRemainingTime;

@property (nonatomic, weak) NSObject<HyBidSkipOverlayDelegate> *delegate;
@property (nonatomic) NSInteger padding;
@property (nonatomic) BOOL isContentInfoInTopLeftPosition;
@property (nonatomic) BOOL isCloseButtonShown;
@property (nonatomic) BOOL shouldShowSkipButton;

@end
