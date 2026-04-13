//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import "HyBidSkAdNetworkModel.h"

// Expose the private method for testing
@interface HyBidSkAdNetworkModel (Testing)
- (NSNumber *)getNSNumberFromString:(NSString *)string;
@end

@interface HyBidSkAdNetworkModelGetNSNumberTests : XCTestCase
@property (nonatomic, strong) HyBidSkAdNetworkModel *model;
@end

@implementation HyBidSkAdNetworkModelGetNSNumberTests

- (void)setUp {
    [super setUp];
    self.model = [[HyBidSkAdNetworkModel alloc] init];
}

// --- Valid inputs ---

- (void)testValidInteger {
    NSNumber *result = [self.model getNSNumberFromString:@"12345"];
    XCTAssertEqualObjects(result, @(12345LL));
}

- (void)testValidLargeTimestamp {
    // Typical SKAdNetwork timestamp value
    NSNumber *result = [self.model getNSNumberFromString:@"1709123456000"];
    XCTAssertEqualObjects(result, @(1709123456000LL));
}

- (void)testValidZero {
    NSNumber *result = [self.model getNSNumberFromString:@"0"];
    XCTAssertEqualObjects(result, @(0LL));
}

- (void)testValidSingleDigit {
    NSNumber *result = [self.model getNSNumberFromString:@"1"];
    XCTAssertEqualObjects(result, @(1LL));
}

// --- Nil / empty ---

- (void)testNilReturnsNil {
    NSNumber *result = [self.model getNSNumberFromString:nil];
    XCTAssertNil(result);
}

- (void)testEmptyStringReturnsNil {
    NSNumber *result = [self.model getNSNumberFromString:@""];
    XCTAssertNil(result);
}

// --- Non-numeric strings ---

- (void)testAlphaStringReturnsNil {
    NSNumber *result = [self.model getNSNumberFromString:@"abc"];
    XCTAssertNil(result);
}

- (void)testMixedStringReturnsNil {
    // Partial match ("123abc") should return nil because scanner is not atEnd
    NSNumber *result = [self.model getNSNumberFromString:@"123abc"];
    XCTAssertNil(result);
}

- (void)testWhitespaceOnlyReturnsNil {
    NSNumber *result = [self.model getNSNumberFromString:@"   "];
    XCTAssertNil(result);
}

// --- Locale robustness ---

- (void)testDecimalPointReturnsNil {
    // Float strings should not be parsed as valid integers
    NSNumber *result = [self.model getNSNumberFromString:@"1.5"];
    XCTAssertNil(result);
}

- (void)testCommaDecimalReturnsNil {
    // European locale format — should not be accepted
    NSNumber *result = [self.model getNSNumberFromString:@"1,5"];
    XCTAssertNil(result);
}

- (void)testNumberWithThousandsSeparatorReturnsNil {
    // "1,234" looks like a number in en_US but should not be accepted
    NSNumber *result = [self.model getNSNumberFromString:@"1,234"];
    XCTAssertNil(result);
}

// --- Thread safety (regression for the crash) ---

- (void)testConcurrentCallsDoNotCrash {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Concurrent calls complete"];
    expectation.expectedFulfillmentCount = 100;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 100; i++) {
        dispatch_async(queue, ^{
            [self.model getNSNumberFromString:@"1709123456000"];
            [expectation fulfill];
        });
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
