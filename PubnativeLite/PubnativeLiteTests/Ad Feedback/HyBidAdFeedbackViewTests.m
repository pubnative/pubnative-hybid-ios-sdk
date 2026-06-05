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
@end

@interface HyBidAdFeedbackViewTests : XCTestCase
@end

@implementation HyBidAdFeedbackViewTests

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
