// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidSkAdNetworkModel.h"

@interface HyBidSkAdNetworkModelTests : XCTestCase

@property (nonatomic, strong) HyBidSkAdNetworkModel *skAdNetworkModel;

@end

@implementation HyBidSkAdNetworkModelTests

NSString * const RESPONSE_AD_NETWORK_ID_KEY = @"network";
NSString * const RESPONSE_SOURCE_APP_ID_KEY = @"sourceapp";
NSString * const RESPONSE_SKADNETWORK_VERSION_KEY = @"version";
NSString * const RESPONSE_TARGET_APP_ID_KEY = @"itunesitem";
NSString * const RESPONSE_SIGNATURE_KEY = @"signature";
NSString * const RESPONSE_CAMPAIGN_ID_KEY = @"campaign";
NSString * const RESPONSE_TIMESTAMP_KEY = @"timestamp";
NSString * const RESPONSE_NONCE_KEY = @"nonce";
NSString * const RESPONSE_FIDELITY_TYPE_KEY = @"fidelity-type";
NSString * const RESPONSE_SOURCE_IDENTIFIER_KEY = @"sourceidentifier";
NSString * const RESPONSE_PRODUCT_PAGE_ID_KEY = @"productpageid";

NSDictionary *dict;

- (void)setUp {
    [super setUp];
    self.skAdNetworkModel = [[HyBidSkAdNetworkModel alloc] init];
    
    // Populate the dictionary with basic mock data
    dict = @{
        RESPONSE_CAMPAIGN_ID_KEY: @"mockCampaignId",
        RESPONSE_TIMESTAMP_KEY: @"mockTimestamp",
        RESPONSE_NONCE_KEY: @"mockNonce",
        RESPONSE_TARGET_APP_ID_KEY: @"mockItunesitem",
        RESPONSE_AD_NETWORK_ID_KEY: @"mockAdNetworkId",
        RESPONSE_SIGNATURE_KEY: @"mockSignature"
    };
}

- (void)testAreBasicParametersValid {
    BOOL result = [self.skAdNetworkModel checkBasicParameters:dict supportMultipleFidelities:NO];
    XCTAssertTrue(result, @"Should return TRUE for valid basic parameters");
}

- (void)testCheckV2Parameters {
    NSMutableDictionary *tempDict = [dict mutableCopy];
    [tempDict addEntriesFromDictionary:@{
        RESPONSE_SKADNETWORK_VERSION_KEY: @"2.0",
        RESPONSE_SOURCE_APP_ID_KEY: @"mockSourceAppId"
    }];
    BOOL result = [self.skAdNetworkModel checkV2Parameters:tempDict];
    XCTAssertTrue(result, @"Should return TRUE for valid v2 parameters");
}

- (void)testCheckV2_2_Parameters {
    NSMutableDictionary *tempDict = [dict mutableCopy];
    [tempDict addEntriesFromDictionary:@{
        RESPONSE_SKADNETWORK_VERSION_KEY: @"2.2",
        RESPONSE_FIDELITY_TYPE_KEY: @"mockFidelityType"
    }];
    BOOL result = [self.skAdNetworkModel checkV2_2_Parameters:tempDict supportMultipleFidelities:NO];
    XCTAssertTrue(result, @"Should return TRUE for valid v2.2 parameters");
}

- (void)testCheckV4_0_Parameters {
    NSMutableDictionary *tempDict = [dict mutableCopy];
    [tempDict addEntriesFromDictionary:@{
        RESPONSE_SKADNETWORK_VERSION_KEY: @"4.0",
        RESPONSE_SOURCE_IDENTIFIER_KEY: @"mockSourceIdentifier",
        RESPONSE_PRODUCT_PAGE_ID_KEY: @"45812c9b-c296-43d3-c6a0-c5a02f74bf6e"
    }];
    BOOL result = [self.skAdNetworkModel checkV4_0_Parameters:tempDict];
    XCTAssertTrue(result, @"Should return TRUE for valid v4.0 parameters");
}

@end
