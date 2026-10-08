//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidAdFeedbackView.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

// Expose private method for testing
@interface HyBidAdFeedbackView (Testing)
- (BOOL)isAppTokenQueryPresentInURLComponents:(NSURLComponents *)components;
- (void)showFromViewController:(UIViewController *)presenter;
@end

@interface HyBidAdFeedbackViewTestsFocusDelegate : NSObject <HyBidInterruptionDelegate>
@property (nonatomic, assign) NSInteger adHasNoFocusCallCount;
@property (nonatomic, assign) NSInteger adHasFocusCallCount;
@end

@implementation HyBidAdFeedbackViewTestsFocusDelegate
- (void)adHasNoFocus {
    self.adHasNoFocusCallCount++;
}
- (void)adHasFocus {
    self.adHasFocusCallCount++;
}
@end

@interface HyBidAdFeedbackViewTests : XCTestCase
@end

@implementation HyBidAdFeedbackViewTests

#pragma mark - show guard (VMI-1694)

- (void)test_show_afterClose_doesNotRecordFeedbackInterruption {
    HyBidAdFeedbackViewTestsFocusDelegate *mockDelegate = [HyBidAdFeedbackViewTestsFocusDelegate new];
    [HyBidInterruptionHandler.shared activateContext:HyBidAdContextVastPlayer with:mockDelegate];

    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:@"https://example.com/feedback" withZoneID:@"zone123"];
    [view setValue:@YES forKey:@"isClosed"];
    [view show];

    XCTAssertEqual(mockDelegate.adHasNoFocusCallCount, 0, @"A closed feedback view presents nothing, so it must not pause the ad");
    XCTAssertFalse(view.isShown);
    [HyBidInterruptionHandler.shared deactivateContext:HyBidAdContextVastPlayer];
}

- (void)test_show_whileShown_doesNotRecordSecondInterruption {
    HyBidAdFeedbackViewTestsFocusDelegate *mockDelegate = [HyBidAdFeedbackViewTestsFocusDelegate new];
    [HyBidInterruptionHandler.shared activateContext:HyBidAdContextVastPlayer with:mockDelegate];

    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:@"https://example.com/feedback" withZoneID:@"zone123"];
    [view setValue:@YES forKey:@"isShown"];
    [view show];

    XCTAssertEqual(mockDelegate.adHasNoFocusCallCount, 0);
    [HyBidInterruptionHandler.shared deactivateContext:HyBidAdContextVastPlayer];
}

- (void)test_showFromViewController_whenPresentationFails_removesFeedbackInterruption {
    // e.g. the presenter is already presenting the expanded ad, or is not in a window: nothing appears on screen
    HyBidAdFeedbackViewTestsFocusDelegate *mockDelegate = [HyBidAdFeedbackViewTestsFocusDelegate new];
    [HyBidInterruptionHandler.shared activateContext:HyBidAdContextVastPlayer with:mockDelegate];

    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:@"https://example.com/feedback" withZoneID:@"zone123"];
    UIViewController *presenterNotInWindow = [[UIViewController alloc] init];
    [view showFromViewController:presenterNotInWindow];
    XCTAssertEqual(mockDelegate.adHasNoFocusCallCount, 1, @"The ad pauses while the feedback view is being presented");

    XCTestExpectation *mainQueueDrained = [self expectationWithDescription:@"main queue drained"];
    dispatch_async(dispatch_get_main_queue(), ^{ [mainQueueDrained fulfill]; });
    [self waitForExpectationsWithTimeout:2 handler:nil];

    XCTAssertEqual(mockDelegate.adHasFocusCallCount, 1, @"Nothing was presented, so the .feedbackView entry must be removed and the ad resumed");
    XCTAssertFalse(view.isShown);
    [HyBidInterruptionHandler.shared deactivateContext:HyBidAdContextVastPlayer];
}

#pragma mark - initWithURL tests

- (void)test_initWithURL_withNilUrl_shouldReturnNonNilInstance {
    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:nil withZoneID:@"zone123"];
    XCTAssertNotNil(view);
}

- (void)test_initWithURL_withEmptyUrl_shouldReturnNonNilInstance {
    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:@"" withZoneID:@"zone123"];
    XCTAssertNotNil(view);
}

- (void)test_initWithURL_withValidUrl_shouldReturnNonNilInstance {
    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:@"https://example.com/feedback" withZoneID:@"zone123"];
    XCTAssertNotNil(view);
}

- (void)test_initWithURL_withNilZoneId_shouldNotCrash {
    XCTAssertNoThrow([[HyBidAdFeedbackView alloc] initWithURL:@"https://example.com" withZoneID:nil]);
}

#pragma mark - isAppTokenQueryPresentInURLComponents tests

- (void)test_isAppTokenQueryPresent_withAppTokenPresent_shouldReturnTrue {
    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:nil withZoneID:@"zone"];

    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://example.com/feedback"];
    NSURLQueryItem *appTokenItem = [[NSURLQueryItem alloc] initWithName:@"apptoken" value:@"someToken"];
    components.queryItems = @[appTokenItem];

    BOOL result = [view isAppTokenQueryPresentInURLComponents:components];
    XCTAssertTrue(result);
}

- (void)test_isAppTokenQueryPresent_withNoQueryItems_shouldReturnFalse {
    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:nil withZoneID:@"zone"];

    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://example.com/feedback"];
    components.queryItems = nil;

    BOOL result = [view isAppTokenQueryPresentInURLComponents:components];
    XCTAssertFalse(result);
}

- (void)test_isAppTokenQueryPresent_withOtherQueryItems_shouldReturnFalse {
    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:nil withZoneID:@"zone"];

    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://example.com/feedback?other=value"];
    NSURLQueryItem *otherItem = [[NSURLQueryItem alloc] initWithName:@"other" value:@"value"];
    components.queryItems = @[otherItem];

    BOOL result = [view isAppTokenQueryPresentInURLComponents:components];
    XCTAssertFalse(result);
}

- (void)test_isAppTokenQueryPresent_withEmptyQueryItems_shouldReturnFalse {
    HyBidAdFeedbackView *view = [[HyBidAdFeedbackView alloc] initWithURL:nil withZoneID:@"zone"];

    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://example.com/feedback"];
    components.queryItems = @[];

    BOOL result = [view isAppTokenQueryPresentInURLComponents:components];
    XCTAssertFalse(result);
}

@end
