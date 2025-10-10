// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@class OMIDPubnativenetAdSession;

#import "HyBidViewabilityAdSession.h"
#import "OMIDAdSessionWrapper.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidViewabilityNativeVideoAdSession : HyBidViewabilityAdSession

- (OMIDAdSessionWrapper*)createOMIDAdSessionforNativeVideo:(UIView *)view withScript:(NSMutableArray *)scripts;
- (void)fireOMIDStartEventWithDuration:(CGFloat)duration withVolume:(CGFloat)volume;
- (void)fireOMIDFirstQuartileEvent;
- (void)fireOMIDMidpointEvent;
- (void)fireOMIDThirdQuartileEvent;
- (void)fireOMIDCompleteEvent;
- (void)fireOMIDPauseEvent;
- (void)fireOMIDResumeEvent;
- (void)fireOMIDBufferStartEvent;
- (void)fireOMIDBufferFinishEvent;
- (void)fireOMIDClickedEvent;
- (void)fireOMIDVolumeChangeEventWithVolume:(CGFloat)volume;
- (void)fireOMIDSkippedEvent;
- (void)fireOMIDPlayerStateEventWithFullscreenInfo:(BOOL)isFullScreen;

@end
