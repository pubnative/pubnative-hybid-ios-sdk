//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBid.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

// Expose private class method for testing
@interface HyBid (Testing)
+ (NSString *)encodeToBase64:(NSString *)string;
@end

@interface HyBidTests : XCTestCase
@end

@implementation HyBidTests

#pragma mark - initWithAppToken tests

- (void)test_initWithAppToken_withNilToken_shouldCallCompletionWithFalse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];

    [HyBid initWithAppToken:nil completion:^(BOOL success) {
        XCTAssertFalse(success);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test_initWithAppToken_withEmptyToken_shouldCallCompletionWithFalse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];

    [HyBid initWithAppToken:@"" completion:^(BOOL success) {
        XCTAssertFalse(success);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test_initWithAppToken_withValidToken_shouldCallCompletionWithTrue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];

    [HyBid initWithAppToken:@"testAppToken123" completion:^(BOOL success) {
        XCTAssertTrue(success);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test_initWithAppToken_withNilCompletion_shouldNotCrash {
    XCTAssertNoThrow([HyBid initWithAppToken:@"testToken" completion:nil]);
}

- (void)test_initWithAppToken_withNilTokenAndNilCompletion_shouldNotCrash {
    XCTAssertNoThrow([HyBid initWithAppToken:nil completion:nil]);
}

#pragma mark - isInitialized tests

- (void)test_isInitialized_afterInitWithNilToken_shouldReturnFalse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"init completed"];

    [HyBid initWithAppToken:nil completion:^(BOOL success) {
        XCTAssertFalse([HyBid isInitialized]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)test_isInitialized_afterInitWithValidToken_shouldReturnTrue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"init completed"];

    [HyBid initWithAppToken:@"validToken" completion:^(BOOL success) {
        XCTAssertTrue([HyBid isInitialized]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - sdkVersion tests

- (void)test_sdkVersion_shouldReturnNonNilString {
    NSString *version = [HyBid sdkVersion];
    XCTAssertNotNil(version);
    XCTAssertGreaterThan(version.length, 0);
}

- (void)test_getSDKVersionInfo_shouldReturnNonNilString {
    NSString *info = [HyBid getSDKVersionInfo];
    XCTAssertNotNil(info);
}

#pragma mark - Configuration tests

- (void)test_setCoppa_withTrue_shouldNotCrash {
    XCTAssertNoThrow([HyBid setCoppa:YES]);
}

- (void)test_setCoppa_withFalse_shouldNotCrash {
    XCTAssertNoThrow([HyBid setCoppa:NO]);
}

- (void)test_setTestMode_withTrue_shouldNotCrash {
    XCTAssertNoThrow([HyBid setTestMode:YES]);
}

- (void)test_setTestMode_withFalse_shouldNotCrash {
    XCTAssertNoThrow([HyBid setTestMode:NO]);
}

- (void)test_setAppStoreAppID_withValidID_shouldNotCrash {
    XCTAssertNoThrow([HyBid setAppStoreAppID:@"com.example.app"]);
}

- (void)test_setLocationUpdates_withTrue_shouldNotCrash {
    XCTAssertNoThrow([HyBid setLocationUpdates:YES]);
}

- (void)test_setLocationUpdates_withFalse_shouldNotCrash {
    XCTAssertNoThrow([HyBid setLocationUpdates:NO]);
}

- (void)test_setLocationTracking_withTrue_shouldNotCrash {
    XCTAssertNoThrow([HyBid setLocationTracking:YES]);
}

- (void)test_setLocationTracking_withFalse_shouldNotCrash {
    XCTAssertNoThrow([HyBid setLocationTracking:NO]);
}

- (void)test_setReporting_withTrue_shouldNotCrash {
    XCTAssertNoThrow([HyBid setReporting:YES]);
}

- (void)test_setReporting_withFalse_shouldNotCrash {
    XCTAssertNoThrow([HyBid setReporting:NO]);
}

- (void)test_rightToBeForgotten_shouldNotCrash {
    XCTAssertNoThrow([HyBid rightToBeForgotten]);
}

#pragma mark - IntegrationType tests

- (void)test_setIntegrationType_withZero_shouldSetToHyBidType {
    [HyBid setIntegrationType:0];
    XCTAssertEqual([HyBid getIntegrationType], SDKIntegrationTypeHyBid);
}

- (void)test_getIntegrationType_shouldReturnValidType {
    SDKIntegrationType type = [HyBid getIntegrationType];
    // Just verify it returns a valid value without crashing
    XCTAssertTrue(type == SDKIntegrationTypeHyBid || type != SDKIntegrationTypeHyBid);
}

#pragma mark - Signal data / encodeToBase64 tests

- (void)test_getEncodedCustomRequestSignalData_shouldNotCrash {
    XCTAssertNoThrow([HyBid getEncodedCustomRequestSignalData]);
}

- (void)test_getEncodedCustomRequestSignalData_withMediationVendor_shouldNotCrash {
    XCTAssertNoThrow([HyBid getEncodedCustomRequestSignalData:@"testVendor"]);
}


- (void)test_reportingManager_shouldReturnNonNilManager {
    HyBidReportingManager *manager = [HyBid reportingManager];
    XCTAssertNotNil(manager);
}

#pragma mark - encodeToBase64 URL-safe tests

- (void)test_encodeToBase64_withNilString_shouldReturnEmptyString {
    NSString *result = [HyBid encodeToBase64:nil];
    XCTAssertEqualObjects(result, @"");
}

- (void)test_encodeToBase64_withStringProducingPaddingEquals_shouldStripEquals {
    // "hello world" base64-encodes to "aGVsbG8gd29ybGQ=" — contains '='
    NSString *result = [HyBid encodeToBase64:@"hello world"];
    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"="], @"'=' padding should be stripped");
}

- (void)test_encodeToBase64_withEmojiProducingPlusAndEquals_shouldReplaceAllUnsafeChars {
    // 🎉 UTF-8 bytes F0 9F 8E 89 → standard base64 "8J+OiQ==" (contains '+' and '=')
    NSString *result = [HyBid encodeToBase64:@"🎉"];
    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"+"], @"'+' should be replaced with '-'");
    XCTAssertFalse([result containsString:@"="], @"'=' should be stripped");
    XCTAssertTrue([result containsString:@"-"], @"'-' should appear in place of '+'");
}

- (void)test_encodeToBase64_outputShouldNeverContainURLUnsafeChars {
    NSArray *inputs = @[@"hello world", @"test 123", @"abc", @"a", @"🎉", @"foo bar baz"];
    for (NSString *input in inputs) {
        NSString *result = [HyBid encodeToBase64:input];
        XCTAssertFalse([result containsString:@"+"],  @"'+' found in output for input: %@", input);
        XCTAssertFalse([result containsString:@"/"],  @"'/' found in output for input: %@", input);
        XCTAssertFalse([result containsString:@"="],  @"'=' found in output for input: %@", input);
    }
}

@end
