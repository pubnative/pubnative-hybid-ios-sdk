//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidSkipOverlay.h"
#import "HyBidTimerState.h"
#import "HyBidCloseButton.h"
#import "HyBidAd.h"
#import "HyBidAd+Internal.h"
#import "HyBidAdModel.h"

@interface HyBidSkipOverlay (VMI1731Testing)
- (void)skipTimerFinished;
@end

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

- (void)testInitWithSkipOffset_Simple_nilAd_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSimple
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
                                                          withCountdownStyle:HyBidCountdownSimple
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    NSInteger remaining = [overlay getRemainingTime];
    XCTAssertEqual(remaining, 10);
}

- (void)testUpdateTimerStateWithRemainingSeconds_Start_then_Stop_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSimple
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
                                                          withCountdownStyle:HyBidCountdownSimple
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                         ad:nil];
    [overlay updateTimerStateWithRemainingSeconds:3 withTimerState:HyBidTimerState_Pause];
    (void)[overlay getRemainingTime];
}

- (void)testAddSkipOverlayViewIn_delegate_doesNotCrash {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSimple
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

- (HyBidAd *)adWithRemoteConfigs:(NSDictionary *)jsondata {
    NSDictionary *adDictionary = @{
        @"assetgroupid": @15,
        @"assets": @[],
        @"meta": @[ @{@"type": @"remoteconfigs", @"data": @{@"jsondata": jsondata}} ]
    };
    HyBidAdModel *adModel = [[HyBidAdModel alloc] initWithDictionary:adDictionary];
    return [[HyBidAd alloc] initWithData:adModel withZoneID:@"1"];
}

- (HyBidCloseButton *)laidOutCloseButtonForAd:(HyBidAd *)ad skip:(BOOL)skip {
    UIView *root = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    HyBidCloseButton *button = [[HyBidCloseButton alloc] initWithRootView:root action:@selector(description) target:self showSkipButton:skip ad:ad];
    [root layoutIfNeeded];
    XCTAssertTrue(CGSizeEqualToSize(button.bounds.size, CGSizeMake(30, 30)), @"the drawn control must stay 30pt");
    return button;
}

- (void)test_touchSize_defaultsToTheDrawnSizeAndIsFlooredAtIt {
    XCTAssertEqual([HyBidCloseButton touchSizeBasedOn:nil], 30.f);
    XCTAssertEqual([HyBidCloseButton touchSizeBasedOn:[self adWithRemoteConfigs:@{}]], 30.f);
    XCTAssertEqual([HyBidCloseButton touchSizeBasedOn:[self adWithRemoteConfigs:@{@"close_button_touch_size": @60}]], 60.f);
    XCTAssertEqual([HyBidCloseButton touchSizeBasedOn:[self adWithRemoteConfigs:@{@"close_button_touch_size": @10}]], 30.f, @"floored");
    XCTAssertEqual([HyBidCloseButton touchSizeBasedOn:[self adWithRemoteConfigs:@{@"close_button_touch_size": @400}]], 100.f, @"clamped");
}

- (void)test_initialTouchSize_isAppliedAsServedAndFallsBackToTheRegularSize {
    XCTAssertEqual([HyBidCloseButton initialTouchSizeBasedOn:nil], 30.f);
    XCTAssertEqual([HyBidCloseButton initialTouchSizeBasedOn:[self adWithRemoteConfigs:@{@"close_button_touch_size": @60}]], 60.f, @"falls back to the regular resolution");
    XCTAssertEqual([HyBidCloseButton initialTouchSizeBasedOn:[self adWithRemoteConfigs:@{@"close_button_initial_touch_size": @12}]], 12.f, @"no floor");
    XCTAssertEqual([HyBidCloseButton initialTouchSizeBasedOn:[self adWithRemoteConfigs:@{@"close_button_initial_touch_size": @1}]], 1.f);
}

- (void)test_touchArea_growsAndShrinksSymmetrically {
    CGRect drawn = CGRectMake(0, 0, 30, 30);
    XCTAssertTrue(CGRectEqualToRect([HyBidCloseButton touchAreaForBounds:drawn touchSize:50.f], CGRectMake(-10, -10, 50, 50)));
    XCTAssertTrue(CGRectEqualToRect([HyBidCloseButton touchAreaForBounds:drawn touchSize:12.f], CGRectMake(9, 9, 12, 12)));
    XCTAssertTrue(CGRectEqualToRect([HyBidCloseButton touchAreaForBounds:drawn touchSize:30.f], drawn));
    XCTAssertTrue(CGRectEqualToRect([HyBidCloseButton touchAreaForBounds:drawn touchSize:0.f], drawn));
    XCTAssertTrue(CGRectEqualToRect([HyBidCloseButton touchAreaForBounds:CGRectMake(0, 0, 20, 20) touchSize:60.f], CGRectMake(-20, -20, 60, 60)));
}

- (void)test_closeButton_claimsTheGrownRing {
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:[self adWithRemoteConfigs:@{@"close_button_touch_size": @60}] skip:NO];
    XCTAssertTrue([button pointInside:CGPointMake(15, 15) withEvent:nil], @"drawn bounds");
    XCTAssertTrue([button pointInside:CGPointMake(-10, -10) withEvent:nil], @"grown ring");
    XCTAssertTrue([button pointInside:CGPointMake(40, 40) withEvent:nil], @"grown ring, far corner");
    XCTAssertFalse([button pointInside:CGPointMake(-20, -20) withEvent:nil], @"outside the configured area");
}

- (void)test_closeButton_withNoConfigBehavesAsToday {
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:[self adWithRemoteConfigs:@{}] skip:NO];
    XCTAssertTrue([button pointInside:CGPointMake(15, 15) withEvent:nil]);
    XCTAssertTrue([button pointInside:CGPointMake(0, 0) withEvent:nil]);
    XCTAssertFalse([button pointInside:CGPointMake(-1, -1) withEvent:nil]);
    XCTAssertFalse([button pointInside:CGPointMake(30, 30) withEvent:nil]);
}

- (void)test_closeButton_shrinksUntilTheFirstClickThenUsesTheRegularSize {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"close_button_initial_touch_size": @12}];
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:ad skip:NO];

    XCTAssertTrue([button pointInside:CGPointMake(15, 15) withEvent:nil], @"centre of the shrunk area");
    XCTAssertFalse([button pointInside:CGPointMake(2, 2) withEvent:nil], @"inside the drawn button, outside the shrunk area: falls through");

    ad.hasRegisteredClick = YES;
    XCTAssertTrue([button pointInside:CGPointMake(2, 2) withEvent:nil], @"after the first click the drawn size is the floor again");
}

- (void)test_skipControl_ignoresBothKeys {
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:[self adWithRemoteConfigs:@{@"close_button_touch_size": @60, @"close_button_initial_touch_size": @12}] skip:YES];
    XCTAssertTrue([button pointInside:CGPointMake(2, 2) withEvent:nil], @"drawn bounds, not shrunk");
    XCTAssertFalse([button pointInside:CGPointMake(-10, -10) withEvent:nil], @"not grown");
}

- (void)test_closeButton_adjacentControlAreaSitsTenPointsFromTheXAndIsTopAligned {
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:[self adWithRemoteConfigs:@{@"close_button_touch_size": @100}] skip:NO];
    XCTAssertTrue([button pointInside:CGPointMake(39.9, 0) withEvent:nil], @"just before the adjacent control area");
    XCTAssertFalse([button pointInside:CGPointMake(40, 0) withEvent:nil], @"top-left corner of the adjacent control area");
    XCTAssertFalse([button pointInside:CGPointMake(57.9, 17.9) withEvent:nil], @"bottom-right corner of the adjacent control area");
    XCTAssertTrue([button pointInside:CGPointMake(58, 0) withEvent:nil], @"just past the adjacent control area");
    XCTAssertTrue([button pointInside:CGPointMake(40, 18) withEvent:nil], @"just below the adjacent control area");
    XCTAssertTrue([button pointInside:CGPointMake(40, -1) withEvent:nil], @"just above the adjacent control area");
}

- (void)test_closeButton_leavesTheCreativeAdChoicesSpotOutOfTheGrownArea {
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:[self adWithRemoteConfigs:@{@"close_button_touch_size": @100}] skip:NO];
    XCTAssertFalse([button pointInside:CGPointMake(49, 15) withEvent:nil], @"QA tap at (49, 65) on screen, X at (0, 50)");
    XCTAssertFalse([button pointInside:CGPointMake(40, 0) withEvent:nil], @"adjacent control area, top-left corner");
    XCTAssertTrue([button pointInside:CGPointMake(49, 25) withEvent:nil], @"grown area below the adjacent control area");
    XCTAssertTrue([button pointInside:CGPointMake(35, 5) withEvent:nil], @"grown area in the gap next to the X");
    XCTAssertTrue([button pointInside:CGPointMake(-20, 5) withEvent:nil], @"the side facing the screen edge has no adjacent control area");
    XCTAssertTrue([button pointInside:CGPointMake(29, 0) withEvent:nil], @"the drawn X always closes");
}

- (void)test_closeButton_keepsTheAdjacentControlAreaDuringTheInitialPhaseToo {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"close_button_touch_size": @30, @"close_button_initial_touch_size": @100}];
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:ad skip:NO];
    XCTAssertFalse([button pointInside:CGPointMake(49, 15) withEvent:nil]);
    XCTAssertTrue([button pointInside:CGPointMake(49, 25) withEvent:nil]);
}

- (void)test_closeButton_mirrorsTheAdjacentControlAreaWhenTheXIsOnTheRight {
    UIView *screen = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIView *root = [[UIView alloc] initWithFrame:CGRectMake(290, 0, 30, 480)];
    [screen addSubview:root];
    HyBidCloseButton *button = [[HyBidCloseButton alloc] initWithRootView:root action:@selector(description) target:self showSkipButton:NO ad:[self adWithRemoteConfigs:@{@"close_button_touch_size": @100}]];
    [root layoutIfNeeded];
    XCTAssertFalse([button pointInside:CGPointMake(-19, 5) withEvent:nil], @"adjacent control area, left of the X");
    XCTAssertTrue([button pointInside:CGPointMake(49, 5) withEvent:nil], @"the side facing the screen edge has no adjacent control area");
}

- (void)test_closeButton_withNoConfigIsNotAffectedByTheAdjacentControlArea {
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:[self adWithRemoteConfigs:@{}] skip:NO];
    XCTAssertFalse([button pointInside:CGPointMake(49, 15) withEvent:nil]);
    XCTAssertTrue([button pointInside:CGPointMake(29, 0) withEvent:nil]);
}

- (void)test_skipOverlay_leavesTheCreativeAdChoicesSpotOutOfTheGrownArea {
    HyBidSkipOverlay *overlay = [self overlayShowingCloseForAd:[self adWithRemoteConfigs:@{@"close_button_touch_size": @100}]];
    XCTAssertFalse([overlay pointInside:CGPointMake(49, 15) withEvent:nil]);
    XCTAssertTrue([overlay pointInside:CGPointMake(49, 25) withEvent:nil]);
}

- (HyBidSkipOverlay *)overlayShowingCloseForAd:(HyBidAd *)ad {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSimple
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:NO
                                                                          ad:ad];
    [overlay skipTimerFinished];
    [overlay layoutIfNeeded];
    XCTAssertTrue(overlay.isCloseButtonShown);
    XCTAssertTrue(CGSizeEqualToSize(overlay.bounds.size, CGSizeMake(30, 30)), @"the overlay collapses to the drawn control");
    return overlay;
}

- (void)test_skipOverlay_claimsTheGrownRingForItsCloseVariant {
    HyBidSkipOverlay *overlay = [self overlayShowingCloseForAd:[self adWithRemoteConfigs:@{@"close_button_touch_size": @60}]];
    XCTAssertTrue([overlay pointInside:CGPointMake(15, 15) withEvent:nil], @"drawn bounds");
    XCTAssertTrue([overlay pointInside:CGPointMake(-10, -10) withEvent:nil], @"grown ring beyond the overlay's own bounds");
    XCTAssertFalse([overlay pointInside:CGPointMake(-20, -20) withEvent:nil], @"outside the configured area");
}

- (void)test_skipOverlay_letsAShrunkAwayPointFallThroughForItsCloseVariant {
    HyBidSkipOverlay *overlay = [self overlayShowingCloseForAd:[self adWithRemoteConfigs:@{@"close_button_initial_touch_size": @12}]];
    XCTAssertTrue([overlay pointInside:CGPointMake(15, 15) withEvent:nil]);
    XCTAssertFalse([overlay pointInside:CGPointMake(2, 2) withEvent:nil], @"inside the overlay, outside the shrunk area: must not be swallowed here");
}

- (void)test_skipOverlay_withNoConfigBehavesAsToday {
    HyBidSkipOverlay *overlay = [self overlayShowingCloseForAd:[self adWithRemoteConfigs:@{}]];
    XCTAssertTrue([overlay pointInside:CGPointMake(0, 0) withEvent:nil]);
    XCTAssertFalse([overlay pointInside:CGPointMake(-1, -1) withEvent:nil]);
}

- (void)test_skipOverlay_skipVariantIgnoresBothKeys {
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSimple
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:YES
                                                                          ad:[self adWithRemoteConfigs:@{@"close_button_touch_size": @60}]];
    [overlay skipTimerFinished];
    [overlay layoutIfNeeded];
    XCTAssertFalse(overlay.isCloseButtonShown);
    XCTAssertTrue([overlay pointInside:CGPointMake(15, 15) withEvent:nil]);
    XCTAssertFalse([overlay pointInside:CGPointMake(-10, -10) withEvent:nil], @"skip is not grown");
}

- (void)test_closeButton_touchSizeIgnoresBothKeys {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"close_button_touch_size": @100, @"close_button_initial_touch_size": @10}];
    HyBidCloseButton *button = [self laidOutCloseButtonForAd:ad skip:NO];
    button.touchSize = @50;
    XCTAssertTrue([button pointInside:CGPointMake(2, 2) withEvent:nil], @"would be shrunk away by the initial key");
    XCTAssertTrue([button pointInside:CGPointMake(39, 15) withEvent:nil], @"24pt right of the centre, inside 50x50");
    XCTAssertTrue([button pointInside:CGPointMake(-9.9, -9.9) withEvent:nil], @"50x50 is centred on the X");
    XCTAssertFalse([button pointInside:CGPointMake(41, 15) withEvent:nil], @"26pt right of the centre, would be grown in by the regular key");
    XCTAssertFalse([button pointInside:CGPointMake(15, 41) withEvent:nil]);

    ad.hasRegisteredClick = YES;
    XCTAssertFalse([button pointInside:CGPointMake(41, 15) withEvent:nil], @"still the set size after the first click");

    button.touchSize = nil;
    XCTAssertTrue([button pointInside:CGPointMake(41, 25) withEvent:nil], @"back to the served key");
}

- (void)test_skipOverlay_passesItsTouchSizeToTheCloseVariant {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"close_button_touch_size": @100}];
    HyBidSkipOverlay *overlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:5
                                                          withCountdownStyle:HyBidCountdownSimple
                                              withContentInfoPositionTopLeft:NO
                                                    withShouldShowSkipButton:NO
                                                                          ad:ad];
    overlay.touchSize = @50;
    [overlay skipTimerFinished];
    [overlay layoutIfNeeded];
    XCTAssertTrue([overlay pointInside:CGPointMake(39, 15) withEvent:nil]);
    XCTAssertFalse([overlay pointInside:CGPointMake(41, 15) withEvent:nil], @"the served 100 does not apply");
}

@end
