//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidSkipOverlay.h"
#import "HyBidTimerState.h"

/// Mock delegate for skip overlay callbacks.
@interface MockSkipOverlayDelegate : NSObject <HyBidSkipOverlayDelegate>
@property (nonatomic, assign) BOOL skipButtonTappedCalled;
@property (nonatomic, assign) BOOL skipTimerCompletedCalled;
@end
@implementation MockSkipOverlayDelegate
- (void)skipButtonTapped { self.skipButtonTappedCalled = YES; }
- (void)skipTimerCompleted { self.skipTimerCompletedCalled = YES; }
@end

/// Unit tests for HyBidSkipOverlay to improve code coverage.
@interface HyBidSkipOverlayTests : XCTestCase
@end

@implementation HyBidSkipOverlayTests

- (void)testInitWithSkipOffset_PieChart_nilAd_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownPieChart
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    XCTAssertNotNil(overlay);
}

- (void)testInitWithSkipOffset_SkipOverlayTimer_nilAd_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSkipOverlayTimer
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    XCTAssertNotNil(overlay);
}

- (void)testInitWithSkipOffset_SkipOverlayProgress_nilAd_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSkipOverlayProgress
                                              withContentInfoPositionTopLeft:YES
                                                    withShouldShowSkipButton:NO
                                                                         ad:nil];
    XCTAssertNotNil(overlay);
}

- (void)testGetRemainingTime_afterInit_returnsSkipOffset {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:10
                                                          withCountdownStyle:HyBidCountdownPieChart
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    NSInteger remaining = [overlay getRemainingTime];
    XCTAssertEqual(remaining, 10);
}

- (void)testUpdateTimerStateWithRemainingSeconds_Start_then_Stop_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownPieChart
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    [overlay updateTimerStateWithRemainingSeconds:5 withTimerState:HyBidTimerState_Start];
    // Start dispatches async to main queue; drain so it runs before we stop and while overlay is alive.
    XCTestExpectation *drain = [self expectationWithDescription:@"Main queue drain"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drain fulfill]; });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    [overlay updateTimerStateWithRemainingSeconds:0 withTimerState:HyBidTimerState_Stop];
    XCTAssertEqual([overlay getRemainingTime], -1);
}

- (void)testUpdateTimerState_Pause_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownPieChart
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    [overlay updateTimerStateWithRemainingSeconds:3 withTimerState:HyBidTimerState_Pause];
    (void)[overlay getRemainingTime];
}

- (void)testAddSkipOverlayViewIn_delegate_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownPieChart
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    MockSkipOverlayDelegate *delegate = [[MockSkipOverlayDelegate alloc] init];
    [overlay addSkipOverlayViewIn:container delegate:delegate];
    // Drain main queue so dispatch_async blocks (addSubview, activateConstraints) run while overlay/container are still alive.
    // Otherwise they can run during a later test's waitForExpectationsWithTimeout and crash with EXC_BAD_ACCESS.
    XCTestExpectation *drain = [self expectationWithDescription:@"Main queue drain"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drain fulfill]; });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssertNotNil(overlay.superview);
}

@end
