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
    HyBidCountdownPieChart = 0,
    HyBidCountdownSkipOverlayTimer = 1,
    HyBidCountdownSkipOverlayProgress = 2
} HyBidCountdownStyle;
