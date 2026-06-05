//
//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "PNLiteVASTPlayerViewController.h"

// Expose private properties and methods needed for testing
@interface PNLiteVASTPlayerViewController (ProgressTesting)
- (void)setupProgressFillView;
- (void)startBottomProgressBarAnimationWithProgress:(double)progress;
- (void)onPlaybackProgressTick;
@property (weak, nonatomic) UIProgressView *viewProgress;
@property (nonatomic, strong) UIView *progressFillView;
@property (nonatomic, strong) NSLayoutConstraint *progressFillWidthConstraint;
@end

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a fully loaded view controller with its view hierarchy in a window
/// so layout passes (bounds, constraints) work correctly.
static PNLiteVASTPlayerViewController *makeLoadedController(void) {
    PNLiteVASTPlayerViewController *vc = [[PNLiteVASTPlayerViewController alloc] init];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 402, 874)];
    [window addSubview:vc.view];
    window.rootViewController = vc;
    [window makeKeyAndVisible];
    [vc viewDidLoad];
    // Force a layout pass so viewProgress.bounds is populated
    [vc.view layoutIfNeeded];
    return vc;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

@interface PNLiteVASTPlayerProgressViewTests : XCTestCase
@end

@implementation PNLiteVASTPlayerProgressViewTests

// MARK: - setupProgressFillView

- (void)test_setupProgressFillView_addsFillViewAsSubviewOfViewProgress {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    XCTAssertNotNil(vc.progressFillView,
                    @"progressFillView must be created by setupProgressFillView");
    XCTAssertTrue([vc.viewProgress.subviews containsObject:vc.progressFillView],
                  @"progressFillView must be a subview of viewProgress");
}

- (void)test_setupProgressFillView_fillViewHasWhiteBackground {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    XCTAssertEqualObjects(vc.progressFillView.backgroundColor, [UIColor whiteColor],
                          @"progressFillView background must be white to match original tintColor");
}

- (void)test_setupProgressFillView_fillViewUsesAutoLayout {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    XCTAssertFalse(vc.progressFillView.translatesAutoresizingMaskIntoConstraints,
                   @"progressFillView must use Auto Layout");
}

- (void)test_setupProgressFillView_widthConstraintStartsAtZero {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    XCTAssertNotNil(vc.progressFillWidthConstraint,
                    @"progressFillWidthConstraint must be created");
    XCTAssertEqual(vc.progressFillWidthConstraint.constant, 0.0,
                   @"Width constraint must start at 0 (no progress yet)");
}

- (void)test_setupProgressFillView_viewProgressTintColorIsCleared {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    XCTAssertEqualObjects(vc.viewProgress.tintColor, [UIColor clearColor],
                          @"viewProgress tintColor must be cleared so the native fill does not show");
}

- (void)test_setupProgressFillView_viewProgressTrackTintColorIsCleared {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    XCTAssertEqualObjects(vc.viewProgress.trackTintColor, [UIColor clearColor],
                          @"viewProgress trackTintColor must be cleared");
}

- (void)test_setupProgressFillView_calledTwice_doesNotDuplicateFillView {
    // viewDidLoad calls setupProgressFillView; calling it again on replay
    // must remove the old fill view and create exactly one new one.
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    UIView *firstFillView = vc.progressFillView;

    [vc setupProgressFillView];

    UIView *secondFillView = vc.progressFillView;

    // The old fill view must have been removed from the hierarchy.
    XCTAssertNil(firstFillView.superview,
                 @"The previous progressFillView must be removed from viewProgress on re-setup");

    // Exactly one fill view must be present — no stacking.
    NSArray *fillViews = [vc.viewProgress.subviews filteredArrayUsingPredicate:
                          [NSPredicate predicateWithBlock:^BOOL(UIView *v, NSDictionary *b) {
        return v.backgroundColor == [UIColor whiteColor];
    }]];
    XCTAssertEqual(fillViews.count, 1u,
                   @"Exactly one white fill view must exist after re-setup, not %lu", (unsigned long)fillViews.count);

    // The property must point to the newly created view, not the old one.
    XCTAssertNotEqual(firstFillView, secondFillView,
                      @"progressFillView must be replaced on re-setup");
}

- (void)test_setupProgressFillView_calledTwice_doesNotProduceConstraintConflicts {
    // Re-setup must deactivate the old constraints; the new set must be the
    // only active constraints driving the fill view's width.
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    NSLayoutConstraint *firstWidthConstraint = vc.progressFillWidthConstraint;

    [vc setupProgressFillView];

    // The old width constraint must be inactive (removed with the old view).
    XCTAssertFalse(firstWidthConstraint.isActive,
                   @"Old width constraint must be deactivated after re-setup to avoid Auto Layout conflicts");

    // The new constraint must be active.
    XCTAssertTrue(vc.progressFillWidthConstraint.isActive,
                  @"New width constraint must be active after re-setup");
    XCTAssertNotEqual(firstWidthConstraint, vc.progressFillWidthConstraint,
                      @"progressFillWidthConstraint must point to the new constraint after re-setup");
}

// MARK: - startBottomProgressBarAnimationWithProgress:

- (void)test_startBottomProgress_atZero_setsWidthConstraintToZero {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];

    [vc startBottomProgressBarAnimationWithProgress:0.0];
    [vc.view layoutIfNeeded];

    XCTAssertEqual(vc.progressFillWidthConstraint.constant, 0.0,
                   @"0%% progress must produce a zero-width fill");
}

- (void)test_startBottomProgress_atFiftyPercent_setsWidthToHalfOfViewProgressWidth {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];

    CGFloat totalWidth = vc.viewProgress.bounds.size.width;
    [vc startBottomProgressBarAnimationWithProgress:0.5];
    [vc.view layoutIfNeeded];

    XCTAssertEqualWithAccuracy(vc.progressFillWidthConstraint.constant, totalWidth * 0.5, 0.5,
                               @"50%% progress must set width to half of viewProgress width");
}

- (void)test_startBottomProgress_atFullProgress_setsWidthToFullViewProgressWidth {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];

    CGFloat totalWidth = vc.viewProgress.bounds.size.width;
    [vc startBottomProgressBarAnimationWithProgress:1.0];
    [vc.view layoutIfNeeded];

    XCTAssertEqualWithAccuracy(vc.progressFillWidthConstraint.constant, totalWidth, 0.5,
                               @"100%% progress must set width equal to total viewProgress width");
}

- (void)test_startBottomProgress_withNaN_doesNotUpdateWidthConstraint {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];
    CGFloat initialConstant = vc.progressFillWidthConstraint.constant;

    [vc startBottomProgressBarAnimationWithProgress:NAN];

    XCTAssertEqual(vc.progressFillWidthConstraint.constant, initialConstant,
                   @"NaN progress must be ignored and must not change the width constraint");
}

- (void)test_startBottomProgress_withPositiveInfinity_doesNotUpdateWidthConstraint {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];
    CGFloat initialConstant = vc.progressFillWidthConstraint.constant;

    [vc startBottomProgressBarAnimationWithProgress:INFINITY];

    XCTAssertEqual(vc.progressFillWidthConstraint.constant, initialConstant,
                   @"Infinite progress must be ignored");
}

- (void)test_startBottomProgress_withNegativeValue_clampsToZero {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];

    [vc startBottomProgressBarAnimationWithProgress:-0.1];

    XCTAssertEqual(vc.progressFillWidthConstraint.constant, 0.0,
                   @"Negative progress must be clamped to 0, not left at a negative width");
}

- (void)test_startBottomProgress_withValueAboveOne_clampsToFullWidth {
    // Timing imprecision can produce values slightly above 1.0; the fill must
    // never exceed the bounds of viewProgress.
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];

    CGFloat totalWidth = vc.viewProgress.bounds.size.width;
    [vc startBottomProgressBarAnimationWithProgress:1.05];
    [vc.view layoutIfNeeded];

    XCTAssertEqualWithAccuracy(vc.progressFillWidthConstraint.constant, totalWidth, 0.5,
                               @"Progress > 1.0 must be clamped to full width, not overflow the bar");
}

- (void)test_startBottomProgress_withValueJustAboveOne_doesNotExceedTotalWidth {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];

    CGFloat totalWidth = vc.viewProgress.bounds.size.width;
    [vc startBottomProgressBarAnimationWithProgress:1.001];
    [vc.view layoutIfNeeded];

    XCTAssertLessThanOrEqual(vc.progressFillWidthConstraint.constant, totalWidth,
                             @"Fill width must never exceed viewProgress width regardless of floating-point overshoot");
}

- (void)test_startBottomProgress_updatesAreMonotonicallyIncreasing {
    // Simulate several consecutive ticks and confirm the width only grows.
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];

    double percents[] = { 0.0, 0.05, 0.10, 0.25, 0.50, 0.75, 1.0 };
    CGFloat lastConstant = -1.0;
    for (NSUInteger i = 0; i < sizeof(percents) / sizeof(percents[0]); i++) {
        [vc startBottomProgressBarAnimationWithProgress:percents[i]];
        [vc.view layoutIfNeeded];
        XCTAssertGreaterThanOrEqual(vc.progressFillWidthConstraint.constant, lastConstant,
                                    @"Width must not decrease between sequential progress values");
        lastConstant = vc.progressFillWidthConstraint.constant;
    }
}

// MARK: - viewProgress visibility passthrough

- (void)test_viewProgressHidden_propagatesToFillView_becauseItIsSubview {
    // The fill view is a subview of viewProgress, so hiding viewProgress
    // automatically hides the fill too — no extra wiring needed.
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    vc.viewProgress.hidden = YES;

    // The fill view itself is not independently hidden; its parent is.
    XCTAssertFalse(vc.progressFillView.hidden,
                   @"progressFillView.hidden must stay NO — visibility is inherited from the parent");
    XCTAssertTrue(vc.viewProgress.hidden,
                  @"Hiding viewProgress must hide the whole bar including the fill");
}

- (void)test_viewProgressShown_fillViewRemainsVisible {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    vc.viewProgress.hidden = NO;

    XCTAssertFalse(vc.progressFillView.hidden,
                   @"progressFillView must remain visible when viewProgress is shown");
}

// MARK: - onPlaybackProgressTick guard against invalid duration

- (void)test_onPlaybackProgressTick_withNoPlayer_doesNotCrash {
    // When no AVPlayer is attached (e.g. before loadWithVideoAdCacheItem:),
    // duration returns NaN and the guard must prevent any crash.
    PNLiteVASTPlayerViewController *vc = makeLoadedController();

    XCTAssertNoThrow([vc onPlaybackProgressTick],
                     @"onPlaybackProgressTick must not crash when no player is present");
}

- (void)test_onPlaybackProgressTick_withNoPlayer_doesNotChangeWidthConstraint {
    PNLiteVASTPlayerViewController *vc = makeLoadedController();
    [vc.view layoutIfNeeded];
    CGFloat initialConstant = vc.progressFillWidthConstraint.constant;

    [vc onPlaybackProgressTick];

    XCTAssertEqual(vc.progressFillWidthConstraint.constant, initialConstant,
                   @"Width constraint must be unchanged when duration is invalid (NaN/0)");
}

@end
