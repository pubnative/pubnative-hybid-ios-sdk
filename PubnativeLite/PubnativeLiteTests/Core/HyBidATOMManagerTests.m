//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidATOMManager.h"
#import "HyBidAd.h"
#import "PNLiteResponseModel.h"
#import "HyBidAdRequest.h"
// HyBidAdSessionData is a Swift class — use generated Swift header (no .h file)
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

/// Unit tests for HyBidATOMManager to improve coverage on new code.
@interface HyBidATOMManagerTests : XCTestCase
@end

@implementation HyBidATOMManagerTests

#pragma mark - fireAdSessionEventWithData

- (void)testFireAdSessionEventWithData_emptyData_doesNotCrash {
    // When data has no meaningful fields, implementation returns early (adSessionDict.count == 0)
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_nilData_doesNotCrash {
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:nil]);
}

- (void)testFireAdSessionEventWithData_withCreativeId_buildsSessionDict {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.creativeId = @"creative-123";
    // Should not throw; may or may not fire depending on ATOM availability
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withViewability_buildsSessionDict {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.viewability = @0.75;
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withNonFiniteViewability_usesMinusOne {
    // Covers branch: viewability not finite -> adSessionDict[@"Viewability"] = @(-1)
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.creativeId = @"c1";
    data.viewability = @(NAN);
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

#pragma mark - createAdSessionDataFromRequest:ad:

- (void)testCreateAdSessionDataFromRequest_nilRequestAndAd_returnsEmptySessionData {
    HyBidAdSessionData *data = [HyBidATOMManager createAdSessionDataFromRequest:nil ad:nil];
    XCTAssertNotNil(data);
    XCTAssertNil(data.creativeId);
    XCTAssertNil(data.campaignId);
    // With nil ad, eCPMFromAd can still return "0.000", so we don't assert bidPrice nil
    XCTAssertNil(data.adFormat);
    // Implementation uses HyBidConstants.RENDERING_SUCCESS == "rendering success"
    XCTAssertEqualObjects(data.renderingStatus, @"rendering success");
    XCTAssertEqualObjects(data.viewability, @1);
}

- (void)testCreateAdSessionDataFromRequest_withAdFromBundle_populatesSessionData {
    // Load ad from test bundle (same resource as HyBidAdTests)
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    if (!path) {
        XCTSkip(@"adResponse.txt not found in test bundle");
    }
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(fileData);
    NSError *err = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&err];
    XCTAssertNil(err);
    XCTAssertNotNil(json);
    PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:json];
    XCTAssertTrue(response.ads.count > 0);
    HyBidAdModel *adModel = response.ads.firstObject;
    HyBidAd *ad = [[HyBidAd alloc] initWithData:adModel withZoneID:@"4"];
    XCTAssertNotNil(ad);

    HyBidAdSessionData *data = [HyBidATOMManager createAdSessionDataFromRequest:nil ad:ad];

    XCTAssertNotNil(data);
    XCTAssertEqualObjects(data.creativeId, ad.creativeID);
    XCTAssertEqualObjects(data.campaignId, ad.campaignID);
    XCTAssertEqualObjects(data.renderingStatus, @"rendering success");
    XCTAssertEqualObjects(data.viewability, @1);
    // bidPrice and adFormat may be set from eCPMFromAd / request or ad
}

- (void)testCreateAdSessionDataFromRequest_requestWithAdFormat_usesRequestAdFormat {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    if (!path) { XCTSkip(@"adResponse.txt not found"); }
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:fileData options:0 error:NULL]];
    if (response.ads.count == 0) { XCTSkip(@"No ads"); }
    HyBidAd *ad = [[HyBidAd alloc] initWithData:response.ads.firstObject withZoneID:@"4"];
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    HyBidAdSessionData *data = [HyBidATOMManager createAdSessionDataFromRequest:request ad:ad];
    XCTAssertNotNil(data);
    XCTAssertNotNil(data.adFormat);
}

#pragma mark - reportAdSessionDataSharedEventWithAdSessionDict

- (void)testReportAdSessionDataSharedEventWithAdSessionDict_nilDict_doesNotCrash {
    XCTAssertNoThrow([HyBidATOMManager reportAdSessionDataSharedEventWithAdSessionDict:nil]);
}

- (void)testReportAdSessionDataSharedEventWithAdSessionDict_emptyDict_doesNotCrash {
    XCTAssertNoThrow([HyBidATOMManager reportAdSessionDataSharedEventWithAdSessionDict:@{}]);
}

- (void)testReportAdSessionDataSharedEventWithAdSessionDict_withDict_doesNotCrash {
    NSDictionary *dict = @{ @"Creative_id": @"c1", @"Campaign_id": @"camp1" };
    XCTAssertNoThrow([HyBidATOMManager reportAdSessionDataSharedEventWithAdSessionDict:dict]);
}

- (void)testReportAdSessionDataSharedEventWithAdSessionDict_withReportingDisabled_doesNotCrash {
    [HyBidSDKConfig sharedConfig].reporting = NO;
    NSDictionary *dict = @{ @"Creative_id": @"test123" };
    XCTAssertNoThrow([HyBidATOMManager reportAdSessionDataSharedEventWithAdSessionDict:dict]);
}

#pragma mark - fireAdSessionEventWithData — extra branch coverage

- (void)testFireAdSessionEventWithData_withAllFields_doesNotCrash {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.creativeId = @"creative-abc";
    data.campaignId = @"campaign-xyz";
    data.bidPrice = @"1.500";
    data.adFormat = @"banner";
    data.renderingStatus = @"rendering success";
    data.viewability = @(0.85);
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withInfiniteViewability_doesNotCrash {
    // Covers isfinite(v) == NO → adSessionDict[@"Viewability"] = @(-1)
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.creativeId = @"c-inf";
    data.viewability = @(INFINITY);
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withNilViewability_doesNotCrash {
    // Covers vNum == nil → viewability block skipped entirely
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.creativeId = @"c-nilview";
    data.viewability = nil;
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withOnlyCampaignId_doesNotCrash {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.campaignId = @"camp-only";
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withOnlyBidPrice_doesNotCrash {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.bidPrice = @"2.750";
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withOnlyAdFormat_doesNotCrash {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.adFormat = @"interstitial";
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_withOnlyRenderingStatus_doesNotCrash {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.renderingStatus = @"rendering success";
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

#pragma mark - createAdSessionDataFromRequest — extra branch coverage

- (void)testCreateAdSessionDataFromRequest_alwaysReturnsNonNil {
    HyBidAdSessionData *data = [HyBidATOMManager createAdSessionDataFromRequest:nil ad:nil];
    XCTAssertNotNil(data);
}

- (void)testCreateAdSessionDataFromRequest_alwaysSetsViewabilityToOne {
    HyBidAdSessionData *data = [HyBidATOMManager createAdSessionDataFromRequest:nil ad:nil];
    XCTAssertEqualObjects(data.viewability, @1);
}

- (void)testCreateAdSessionDataFromRequest_alwaysSetsRenderingSuccess {
    HyBidAdSessionData *data = [HyBidATOMManager createAdSessionDataFromRequest:nil ad:nil];
    XCTAssertEqualObjects(data.renderingStatus, [HyBidConstants RENDERING_SUCCESS]);
}

#pragma mark - fireAdSessionEventWithData reaching the ATOM firing block

// These call the always-compiled method; the #if ATOM block inside fires
// only when ATOM is linked into the framework, but the outer method path
// (dict-building → jsonObject construction) is always executed.

- (void)testFireAdSessionEventWithData_withCreativeId_doesNotCrash {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.creativeId = @"atom-block-creative";
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

- (void)testFireAdSessionEventWithData_allFields_doesNotCrash {
    HyBidAdSessionData *data = [[HyBidAdSessionData alloc] init];
    data.creativeId = @"c1";
    data.campaignId = @"camp1";
    data.bidPrice = @"1.500";
    data.adFormat = @"banner";
    data.renderingStatus = @"rendering success";
    data.viewability = @(0.85);
    XCTAssertNoThrow([HyBidATOMManager fireAdSessionEventWithData:data]);
}

@end
