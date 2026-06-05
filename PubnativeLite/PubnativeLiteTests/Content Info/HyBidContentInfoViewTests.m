//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidContentInfoView.h"

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

@end
