//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidAdSourceConfigParameter.h"

/// Unit tests for HyBidAdSourceConfigParameter (parameter key constants).
@interface HyBidAdSourceConfigParameterTests : XCTestCase
@end

@implementation HyBidAdSourceConfigParameterTests

- (void)test_eCPM_returnsExpectedKey {
    XCTAssertEqualObjects([HyBidAdSourceConfigParameter eCPM], @"eCPM");
}

- (void)test_enabled_returnsExpectedKey {
    XCTAssertEqualObjects([HyBidAdSourceConfigParameter enabled], @"enabled");
}

- (void)test_name_returnsExpectedKey {
    XCTAssertEqualObjects([HyBidAdSourceConfigParameter name], @"name");
}

- (void)test_vastTagUrl_returnsExpectedKey {
    XCTAssertEqualObjects([HyBidAdSourceConfigParameter vastTagUrl], @"vastTagUrl");
}

- (void)test_type_returnsExpectedKey {
    XCTAssertEqualObjects([HyBidAdSourceConfigParameter type], @"type");
}

@end
