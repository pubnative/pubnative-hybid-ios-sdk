//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
        RESPONSE_SOURCE_IDENTIFIER_KEY: @"mockSourceIdentifier"
    }];
    BOOL result = [self.skAdNetworkModel checkV4_0_Parameters:tempDict];
    XCTAssertTrue(result, @"Should return TRUE for valid v4.0 parameters");
}

@end
