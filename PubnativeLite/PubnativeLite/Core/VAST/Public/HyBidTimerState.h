// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

typedef NS_ENUM(NSInteger){
    HyBidTimerState_Start,
    HyBidTimerState_Pause,
    HyBidTimerState_Stop
} HyBidTimerState;

typedef enum {
    HyBidCountdownSimple = 0,
    HyBidCountdownPieChart __attribute__((deprecated("Use HyBidCountdownSimple instead"))) = HyBidCountdownSimple,
    HyBidCountdownSkipOverlayTimer = 1,
    HyBidCountdownSkipOverlayProgress = 2
} HyBidCountdownStyle;
