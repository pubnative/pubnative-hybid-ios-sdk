//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidContentInfoView.h"
#import "HyBidAdFeedbackView.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

// Expose private methods for testing
@interface HyBidContentInfoView (Testing)
- (void)downloadCustomContentInfoViewIconWithCompletionBlock:(void (^)(BOOL isFinished))completionBlock;
- (void)handleDisplay;
@property (nonatomic, assign) BOOL adFeedbackViewRequested;
@end

@interface HyBidContentInfoViewTestsFocusDelegate : NSObject <HyBidInterruptionDelegate>
@property (nonatomic, assign) NSInteger adHasFocusCallCount;
@end

@implementation HyBidContentInfoViewTestsFocusDelegate
- (void)adHasFocus {
    self.adHasFocusCallCount++;
}
@end

@interface HyBidContentInfoViewTests : XCTestCase
@property (nonatomic, strong) HyBidContentInfoView *contentInfoView;
@end

@implementation HyBidContentInfoViewTests

- (void)setUp {
    [super setUp];
    self.contentInfoView = [[HyBidContentInfoView alloc] init];
}

- (void)tearDown {
    self.contentInfoView = nil;
    [super tearDown];
}

#pragma mark - init tests

- (void)test_init_shouldReturnNonNilInstance {
    XCTAssertNotNil(self.contentInfoView);
}

- (void)test_init_shouldBeHiddenInitially {
    XCTAssertTrue(self.contentInfoView.hidden);
}

- (void)test_init_shouldHaveDefaultClickActionExpand {
    XCTAssertEqual(self.contentInfoView.clickAction, HyBidContentInfoClickActionExpand);
}

- (void)test_init_shouldHaveDefaultDisplaySystem {
    XCTAssertEqual(self.contentInfoView.display, HyBidContentInfoDisplaySystem);
}

#pragma mark - getValidIconSizeWith tests

- (void)test_getValidIconSizeWith_normalSize_shouldReturnSameSize {
    CGSize input = CGSizeMake(50, 20);
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertEqual(result.width, 50);
    XCTAssertEqual(result.height, 20);
}

- (void)test_getValidIconSizeWith_zeroWidth_shouldReturnDefaultSize {
    CGSize input = CGSizeMake(0, 0);
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertGreaterThan(result.width, 0);
    XCTAssertGreaterThan(result.height, 0);
}

- (void)test_getValidIconSizeWith_negativeWidth_shouldReturnDefaultSize {
    CGSize input = CGSizeMake(-5, -5);
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertGreaterThan(result.width, 0);
    XCTAssertGreaterThan(result.height, 0);
}

- (void)test_getValidIconSizeWith_minusOneWidth_shouldReturnDefaultSize {
    // -1 is special sentinel value for "invalid" on Android
    CGSize input = CGSizeMake(-1, -1);
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertEqual(result.width, 15.0); // PNLiteContentViewIcontDefaultSize
    XCTAssertEqual(result.height, 15.0);
}

- (void)test_getValidIconSizeWith_maxInt32Width_shouldReturnDefaultSize {
    CGSize input = CGSizeMake(2147483647, 20);
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertEqual(result.width, 15.0);
    XCTAssertEqual(result.height, 15.0);
}

- (void)test_getValidIconSizeWith_oversizedWidth_shouldClampToMaxWidth {
    CGSize input = CGSizeMake(200, 20); // width > 120 (HyBidIconMaximumWidth)
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertLessThanOrEqual(result.width, 120.0); // HyBidIconMaximumWidth
}

- (void)test_getValidIconSizeWith_oversizedHeight_shouldClampToMaxHeight {
    CGSize input = CGSizeMake(20, 100); // height > 30 (HyBidIconMaximumHeight)
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertLessThanOrEqual(result.height, 30.0); // HyBidIconMaximumHeight
}

- (void)test_getValidIconSizeWith_squareOversize_shouldReturnSquareWithinBounds {
    CGSize input = CGSizeMake(200, 200); // aspect ratio = 1.0, both oversized
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertLessThanOrEqual(result.width, 120.0);
    XCTAssertLessThanOrEqual(result.height, 30.0);
    XCTAssertEqual(result.width, result.height);
}

- (void)test_getValidIconSizeWith_widthLargerThanHeight_oversized_shouldScaleDownProportionally {
    CGSize input = CGSizeMake(200, 10); // wide and oversized in width
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertLessThanOrEqual(result.width, 120.0);
}

- (void)test_getValidIconSizeWith_heightLargerThanWidth_oversized_shouldScaleDown {
    CGSize input = CGSizeMake(10, 100); // tall image, height > max
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertLessThanOrEqual(result.height, 30.0);
}

- (void)test_getValidIconSizeWith_validSize_shouldNotExceedMaxWidth {
    CGSize input = CGSizeMake(120, 30); // exactly at max
    CGSize result = [self.contentInfoView getValidIconSizeWith:input];

    XCTAssertLessThanOrEqual(result.width, 120.0);
    XCTAssertLessThanOrEqual(result.height, 30.0);
}

#pragma mark - Properties tests

- (void)test_setLink_shouldStoreLink {
    self.contentInfoView.link = @"https://example.com";
    XCTAssertEqualObjects(self.contentInfoView.link, @"https://example.com");
}

- (void)test_setText_shouldStoreText {
    self.contentInfoView.text = @"Learn more";
    XCTAssertEqualObjects(self.contentInfoView.text, @"Learn more");
}

- (void)test_setZoneId_shouldStoreZoneId {
    self.contentInfoView.zoneID = @"zone123";
    XCTAssertEqualObjects(self.contentInfoView.zoneID, @"zone123");
}

- (void)test_setIsCustom_shouldStoreValue {
    self.contentInfoView.isCustom = YES;
    XCTAssertTrue(self.contentInfoView.isCustom);
}

#pragma mark - downloadCustomContentInfoViewIcon (icon URL trim) tests

- (void)test_downloadCustomContentInfoViewIcon_withNewlineSuffix_shouldNotCrash {
    // The icon URL has " \n..." appended — lines 139-141 in HyBidContentInfoView.m trim it before use
    self.contentInfoView.icon = @"https://cdn.verve.com/icon.png \n...";
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
    [self.contentInfoView downloadCustomContentInfoViewIconWithCompletionBlock:^(BOOL isFinished) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test_downloadCustomContentInfoViewIcon_withCleanURL_shouldNotCrash {
    // Baseline: no " \n..." suffix → takes the else branch (line 143)
    self.contentInfoView.icon = @"https://cdn.verve.com/icon.png";
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
    [self.contentInfoView downloadCustomContentInfoViewIconWithCompletionBlock:^(BOOL isFinished) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - handleDisplay (link URL trim) tests

- (void)test_handleDisplay_withInAppDisplayAndNewlineSuffix_shouldNotCrash {
    // display = HyBidContentInfoDisplayInApp → else branch in handleDisplay (lines 278-287)
    // The link has " \n..." → lines 280-282 trim it before creating HyBidAdFeedbackView
    self.contentInfoView.display = HyBidContentInfoDisplayInApp;
    self.contentInfoView.link = @"https://verve.com/feedback \n...";
    self.contentInfoView.zoneID = @"testZone";
    XCTAssertNoThrow([self.contentInfoView handleDisplay]);
}

- (void)test_handleDisplay_withInAppDisplayAndCleanLink_shouldNotCrash {
    // Baseline: no " \n..." suffix → takes the else branch inside (line 284)
    self.contentInfoView.display = HyBidContentInfoDisplayInApp;
    self.contentInfoView.link = @"https://verve.com/feedback";
    self.contentInfoView.zoneID = @"testZone";
    XCTAssertNoThrow([self.contentInfoView handleDisplay]);
}

#pragma mark - Feedback callback routing (VMI-1694)

- (void)test_init_shouldNotTakeOverFeedbackViewDelegate {
    HyBidInterruptionHandler.shared.feedbackViewDelegate = nil;
    HyBidContentInfoView *other = [[HyBidContentInfoView alloc] init];
    XCTAssertNil(HyBidInterruptionHandler.shared.feedbackViewDelegate, @"Creating a content info view must not claim the feedback callbacks");
    (void)other;
}

- (void)test_handleDisplay_thenAnotherViewCreated_callbacksStillReachTappedView {
    self.contentInfoView.display = HyBidContentInfoDisplayInApp;
    self.contentInfoView.link = @"https://verve.com/feedback";
    self.contentInfoView.zoneID = @"testZone";
    [self.contentInfoView handleDisplay];
    XCTAssertTrue(self.contentInfoView.adFeedbackViewRequested);

    // e.g. HyBidAd.contentInfo minting a fresh view after the tap
    HyBidContentInfoView *other = [[HyBidContentInfoView alloc] init];
    XCTAssertEqual(HyBidInterruptionHandler.shared.feedbackViewDelegate, self.contentInfoView);

    [HyBidInterruptionHandler.shared adFeedbackViewDidFailWithError:[NSError errorWithDomain:@"test" code:0 userInfo:nil]];
    XCTAssertFalse(self.contentInfoView.adFeedbackViewRequested, @"Tapped view must receive the failure and accept further taps");
    XCTAssertFalse(other.adFeedbackViewRequested);
}

- (void)test_dealloc_whileFeedbackViewShown_removesFeedbackInterruption_deliversAdHasFocus {
    HyBidContentInfoViewTestsFocusDelegate *mockDelegate = [HyBidContentInfoViewTestsFocusDelegate new];
    [HyBidInterruptionHandler.shared activateContext:HyBidAdContextVastPlayer with:mockDelegate];

    @autoreleasepool {
        HyBidContentInfoView *view = [[HyBidContentInfoView alloc] init];
        HyBidAdFeedbackView *feedbackView = [[HyBidAdFeedbackView alloc] initWithURL:@"https://verve.com/feedback" withZoneID:@"testZone"];
        [feedbackView setValue:@YES forKey:@"isShown"];
        [view setValue:feedbackView forKey:@"adFeedbackView"];
        [HyBidInterruptionHandler.shared adFeedbackViewDidShow];
        view = nil;
    }

    XCTAssertEqual(mockDelegate.adHasFocusCallCount, 1, @"Tearing down the ad while its feedback view is shown must remove the .feedbackView entry");
    [HyBidInterruptionHandler.shared deactivateContext:HyBidAdContextVastPlayer];
}

- (void)test_dealloc_whenFeedbackViewNotShown_doesNotTouchInterruptions {
    HyBidContentInfoViewTestsFocusDelegate *mockDelegate = [HyBidContentInfoViewTestsFocusDelegate new];
    [HyBidInterruptionHandler.shared activateContext:HyBidAdContextVastPlayer with:mockDelegate];
    // Another content info view's feedback view is on screen; releasing one that never showed must not clear it
    [HyBidInterruptionHandler.shared adFeedbackViewDidShow];

    @autoreleasepool {
        HyBidContentInfoView *view = [[HyBidContentInfoView alloc] init];
        [view setValue:[[HyBidAdFeedbackView alloc] initWithURL:@"https://verve.com/feedback" withZoneID:@"testZone"] forKey:@"adFeedbackView"];
        view = nil;
    }

    XCTAssertEqual(mockDelegate.adHasFocusCallCount, 0);
    [HyBidInterruptionHandler.shared adFeedbackViewDidDismiss];
    XCTAssertEqual(mockDelegate.adHasFocusCallCount, 1);
    [HyBidInterruptionHandler.shared deactivateContext:HyBidAdContextVastPlayer];
}

@end
