//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidOMIDVerificationScriptResourceWrapper.h"

/// Unit tests for HyBidOMIDVerificationScriptResourceWrapper (init with URL/vendorKey/parameters).
@interface HyBidOMIDVerificationScriptResourceWrapperTests : XCTestCase
@end

@implementation HyBidOMIDVerificationScriptResourceWrapperTests

- (void)testInitWithURL_vendorKey_parameters_doesNotCrash {
    NSURL *url = [NSURL URLWithString:@"https://example.com/omid.js"];
    NSString *vendorKey = @"test-vendor";
    NSString *parameters = @"";
    HyBidOMIDVerificationScriptResourceWrapper *wrapper = [[HyBidOMIDVerificationScriptResourceWrapper alloc] initWithURL:url vendorKey:vendorKey parameters:parameters];
    XCTAssertNotNil(wrapper);
}

- (void)testInitWithURL_nilVendorKey_doesNotCrash {
    NSURL *url = [NSURL URLWithString:@"https://example.com/omid.js"];
    HyBidOMIDVerificationScriptResourceWrapper *wrapper = [[HyBidOMIDVerificationScriptResourceWrapper alloc] initWithURL:url vendorKey:nil parameters:nil];
    XCTAssertNotNil(wrapper);
}

@end
