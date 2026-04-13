//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidAdFeedbackMacroUtil.h"
#import "HyBidAdFeedbackParameters.h"
#import "HyBidAd.h"
#import "HyBidAdRequest.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidAdFeedbackMacroUtilTests : XCTestCase
@end

@implementation HyBidAdFeedbackMacroUtilTests

#pragma mark - formatUrl:withZoneID: tests

- (void)test_formatUrl_withSimpleUrl_shouldReturnNonNilResult {
    NSString *url = @"https://example.com/feedback";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone123"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withEmptyUrl_shouldReturnEmptyString {
    NSString *url = @"";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
    XCTAssertEqual(result.length, 0);
}

- (void)test_formatUrl_withNilUrl_shouldReturnNil {
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:nil withZoneID:@"zone"];

    // nil percent encoding returns nil
    XCTAssertNil(result);
}

- (void)test_formatUrl_withHasEndCardMacro_shouldReplaceMacro {
    NSString *url = @"https://example.com/feedback?endcard=${HASENDCARD}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${HASENDCARD}"]);
    // Should be replaced with "true" or "false"
    XCTAssertTrue([result containsString:@"true"] || [result containsString:@"false"]);
}

- (void)test_formatUrl_withZoneIdMacro_setsRequestedZoneID {
    NSString *url = @"https://example.com/feedback?zone=${ZONEID}";
    NSString *zoneID = @"testZone456";

    [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:zoneID];

    XCTAssertEqualObjects([HyBidAdFeedbackParameters sharedInstance].requestedZoneID, zoneID);
}

- (void)test_formatUrl_withAudioStateMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?audio=${AUDIOSTATE}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withSdkVersionMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?sdk=${SDKVERSION}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withMultipleMacros_shouldProcessAll {
    NSString *url = @"https://example.com/feedback?endcard=${HASENDCARD}&audio=${AUDIOSTATE}&sdk=${SDKVERSION}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${HASENDCARD}"]);
}

- (void)test_formatUrl_withUrlContainingSpecialCharacters_shouldReturnPercentEncoded {
    NSString *url = @"https://example.com/feedback?param=value with spaces";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withValidZoneId_shouldNotCrash {
    XCTAssertNoThrow([HyBidAdFeedbackMacroUtil formatUrl:@"https://example.com" withZoneID:@"12345"]);
}

- (void)test_formatUrl_withNilZoneId_shouldNotCrash {
    XCTAssertNoThrow([HyBidAdFeedbackMacroUtil formatUrl:@"https://example.com" withZoneID:nil]);
}

- (void)test_formatUrl_withAppVersionMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?version=${APPVERSION}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withDeviceInfoMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?device=${DEVICEINFO}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withCreativeIdMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?creative=${CREATIVEID}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withImpressionBeaconMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?beacon=${IMPRESSIONBEACON}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withIntegrationTypeMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?type=${INTEGRATIONTYPE}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withAdFormatMacro_shouldAttemptReplacement {
    NSString *url = @"https://example.com/feedback?format=${ADFORMAT}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
}

#pragma mark - Property-driven macro replacement tests (cover if-blocks in formatUrl:withZoneID:)

- (void)test_formatUrl_withAppTokenSet_shouldReplaceAppTokenMacro {
    // Lines 27-29: appToken block executes when HyBidSDKConfig.sharedConfig.appToken is non-nil
    [HyBidSDKConfig sharedConfig].appToken = @"testAppToken123";
    NSString *url = @"https://example.com/feedback?token=${APPTOKEN}";

    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"zone"];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${APPTOKEN}"], @"${APPTOKEN} should be replaced");
}

- (void)test_formatUrl_withCachedAdRequest_shouldReplaceIntegrationTypeMacro {
    // Lines 59-61: integrationType block executes when adRequest is cached with non-nil integrationType
    HyBidAdRequest *adRequest = [[HyBidAdRequest alloc] init];
    [adRequest setIntegrationType:HEADER_BIDDING withZoneID:@"cachedZone"];

    HyBidAd *ad = [[HyBidAd alloc] initWithAssetGroup:21 withAdContent:@"<ad/>" withAdType:kHyBidAdTypeHTML];
    [[HyBidAdFeedbackParameters sharedInstance] cacheAd:ad andAdRequest:adRequest withZoneID:@"cachedZone"];

    NSString *url = @"https://example.com/feedback?type=${INTEGRATIONTYPE}&format=${ADFORMAT}";
    NSString *result = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:@"cachedZone"];

    XCTAssertNotNil(result);
    // integrationType is now set from the cached adRequest → macro should be replaced
    XCTAssertFalse([result containsString:@"${INTEGRATIONTYPE}"], @"${INTEGRATIONTYPE} should be replaced");
    // adFormat is derived from adRequest.adSize → macro should be replaced
    XCTAssertFalse([result containsString:@"${ADFORMAT}"], @"${ADFORMAT} should be replaced");
}

@end
