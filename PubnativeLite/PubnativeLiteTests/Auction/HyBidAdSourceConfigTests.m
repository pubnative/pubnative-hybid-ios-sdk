//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidAdSourceConfig.h"
#import "HyBidAdSourceConfigParameter.h"

/// Unit tests for HyBidAdSourceConfig to improve coverage on new code.
@interface HyBidAdSourceConfigTests : XCTestCase
@end

@implementation HyBidAdSourceConfigTests

#pragma mark - initWithDictionary

- (void)testInitWithDictionary_validDictionary_setsProperties {
    // Given: dictionary with string values
    NSDictionary *dict = @{
        HyBidAdSourceConfigParameter.eCPM: @2.5,
        HyBidAdSourceConfigParameter.enabled: @YES,
        HyBidAdSourceConfigParameter.name: @"test-source",
        HyBidAdSourceConfigParameter.vastTagUrl: @"https://example.com/vast",
        HyBidAdSourceConfigParameter.type: @"video"
    };

    // When: initializing config
    HyBidAdSourceConfig *config = [[HyBidAdSourceConfig alloc] initWithDictionary:dict];

    // Then: all properties are set correctly
    XCTAssertNotNil(config);
    XCTAssertEqual(config.eCPM, 2.5);
    XCTAssertTrue(config.enabled);
    XCTAssertEqualObjects(config.name, @"test-source");
    XCTAssertEqualObjects(config.vastTagUrl, @"https://example.com/vast");
    XCTAssertEqualObjects(config.type, @"video");
}

- (void)testInitWithDictionary_numberValuesForStrings_usesStringValue {
    // Given: name/vastTagUrl/type as NSNumber (responds to stringValue)
    NSDictionary *dict = @{
        HyBidAdSourceConfigParameter.eCPM: @1.0,
        HyBidAdSourceConfigParameter.enabled: @NO,
        HyBidAdSourceConfigParameter.name: @12345,
        HyBidAdSourceConfigParameter.vastTagUrl: @67890,
        HyBidAdSourceConfigParameter.type: @99
    };

    HyBidAdSourceConfig *config = [[HyBidAdSourceConfig alloc] initWithDictionary:dict];

    XCTAssertNotNil(config);
    XCTAssertEqualObjects(config.name, @"12345");
    XCTAssertEqualObjects(config.vastTagUrl, @"67890");
    XCTAssertEqualObjects(config.type, @"99");
}

- (void)testInitWithDictionary_emptyDictionary_initializesWithDefaults {
    NSDictionary *dict = @{};

    HyBidAdSourceConfig *config = [[HyBidAdSourceConfig alloc] initWithDictionary:dict];

    XCTAssertNotNil(config);
    XCTAssertEqual(config.eCPM, 0.0);
    XCTAssertFalse(config.enabled);
    XCTAssertNil(config.name);
    XCTAssertNil(config.vastTagUrl);
    XCTAssertNil(config.type);
}

- (void)testInitWithDictionary_nilDictionary_doesNotCrash {
    HyBidAdSourceConfig *config = [[HyBidAdSourceConfig alloc] initWithDictionary:nil];
    XCTAssertNotNil(config);
}

- (void)testInitWithDictionary_partialDictionary_setsOnlyProvidedKeys {
    NSDictionary *dict = @{
        HyBidAdSourceConfigParameter.eCPM: @10.0,
        HyBidAdSourceConfigParameter.enabled: @YES
    };

    HyBidAdSourceConfig *config = [[HyBidAdSourceConfig alloc] initWithDictionary:dict];

    XCTAssertEqual(config.eCPM, 10.0);
    XCTAssertTrue(config.enabled);
    XCTAssertNil(config.name);
    XCTAssertNil(config.vastTagUrl);
    XCTAssertNil(config.type);
}

@end
