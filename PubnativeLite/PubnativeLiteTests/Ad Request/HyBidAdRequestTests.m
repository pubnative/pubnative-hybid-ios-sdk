//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidAdRequest.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

// Expose private methods for testing
@interface HyBidAdRequest (Testing)
- (NSTimeInterval)elapsedTimeSince:(NSTimeInterval)timestamp;
- (nullable NSDictionary *)createDictionaryFromData:(NSData *)data;
- (void)processVASTTagResponseFrom:(NSString *)vastAdContent;
//- (HyBidCustomEndcardDisplayBehaviour)customEndcardDisplayBehaviourFromString:(NSString *)string;
@end

@interface HyBidAdRequestTests : XCTestCase
@property (nonatomic, strong) HyBidAdRequest *adRequest;
@end

@implementation HyBidAdRequestTests

- (void)setUp {
    [super setUp];
    self.adRequest = [[HyBidAdRequest alloc] init];
}

- (void)tearDown {
    self.adRequest = nil;
    [super tearDown];
}

#pragma mark - init tests

- (void)test_init_shouldReturnNonNilInstance {
    XCTAssertNotNil(self.adRequest);
}

- (void)test_init_shouldHaveDefaultAdSize {
    XCTAssertNotNil(self.adRequest.adSize);
}

- (void)test_init_shouldHaveDefaultAutoCacheOnLoad {
    XCTAssertTrue(self.adRequest.isAutoCacheOnLoad);
}

- (void)test_init_shouldHaveIsRewardedAsFalse {
    XCTAssertFalse(self.adRequest.isRewarded);
}

- (void)test_init_shouldHaveIsUsingOpenRTBAsFalse {
    XCTAssertFalse(self.adRequest.isUsingOpenRTB);
}

#pragma mark - supportedAPIFrameworks tests

- (void)test_supportedAPIFrameworks_shouldReturnNonNilArray {
    NSArray<NSString *> *frameworks = self.adRequest.supportedAPIFrameworks;
    XCTAssertNotNil(frameworks);
}

- (void)test_supportedAPIFrameworks_shouldContainMRAIDAndOMSDK {
    NSArray<NSString *> *frameworks = self.adRequest.supportedAPIFrameworks;
    XCTAssertTrue([frameworks containsObject:@"5"]); // MRAID
    XCTAssertTrue([frameworks containsObject:@"7"]); // OMID
}

- (void)test_supportedAPIFrameworks_shouldHaveTwoElements {
    NSArray<NSString *> *frameworks = self.adRequest.supportedAPIFrameworks;
    XCTAssertEqual(frameworks.count, 2);
}

#pragma mark - setIntegrationType tests

- (void)test_setIntegrationType_withValidZoneId_shouldSetIntegrationType {
    [self.adRequest setIntegrationType:HEADER_BIDDING withZoneID:@"zone123"];
    XCTAssertEqual(self.adRequest.integrationType, HEADER_BIDDING);
}

- (void)test_setIntegrationType_shouldNotCrash {
    XCTAssertNoThrow([self.adRequest setIntegrationType:IN_APP_BIDDING withZoneID:@"zone123"]);
}

#pragma mark - getAdFormat tests

- (void)test_getAdFormat_withDefaultAdSize_shouldReturnBanner {
    // Default ad size is SIZE_320x50 which is banner
    NSString *format = [self.adRequest getAdFormat];
    XCTAssertNotNil(format);
    XCTAssertEqualObjects(format, HyBidReportingAdFormat.BANNER);
}

- (void)test_getAdFormat_withInterstitialSize_shouldReturnFullscreen {
    self.adRequest.adSize = HyBidAdSize.SIZE_INTERSTITIAL;
    NSString *format = [self.adRequest getAdFormat];
    XCTAssertEqualObjects(format, HyBidReportingAdFormat.FULLSCREEN);
}

- (void)test_getAdFormat_withNativeSize_shouldReturnNative {
    self.adRequest.adSize = HyBidAdSize.SIZE_NATIVE;
    NSString *format = [self.adRequest getAdFormat];
    XCTAssertEqualObjects(format, HyBidReportingAdFormat.NATIVE);
}

- (void)test_getAdFormat_withRewardedTrue_shouldReturnRewarded {
    self.adRequest.isRewarded = YES;
    NSString *format = [self.adRequest getAdFormat];
    XCTAssertEqualObjects(format, HyBidReportingAdFormat.REWARDED);
}

#pragma mark - createDictionaryFromData tests

- (void)test_createDictionaryFromData_withValidJson_shouldReturnDictionary {
    NSString *jsonString = @"{\"status\":\"ok\",\"ads\":[]}";
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *result = [self.adRequest createDictionaryFromData:data];

    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result[@"status"], @"ok");
}

- (void)test_createDictionaryFromData_withInvalidData_shouldReturnNil {
    NSData *data = [@"not valid json {{{" dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *result = [self.adRequest createDictionaryFromData:data];

    XCTAssertNil(result);
}

- (void)test_createDictionaryFromData_withNilData_shouldReturnNil {
    NSDictionary *result = [self.adRequest createDictionaryFromData:nil];
    XCTAssertNil(result);
}

- (void)test_createDictionaryFromData_withEmptyJson_shouldReturnNil {
    NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *result = [self.adRequest createDictionaryFromData:data];
    XCTAssertNil(result);
}

#pragma mark - elapsedTimeSince tests

- (void)test_elapsedTimeSince_withPastTimestamp_shouldReturnPositiveValue {
    NSTimeInterval past = [[NSDate date] timeIntervalSince1970] - 5.0; // 5 seconds ago
    NSTimeInterval elapsed = [self.adRequest elapsedTimeSince:past];

    XCTAssertGreaterThan(elapsed, 0);
    XCTAssertGreaterThanOrEqual(elapsed, 5.0);
}

- (void)test_elapsedTimeSince_withCurrentTimestamp_shouldReturnSmallValue {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval elapsed = [self.adRequest elapsedTimeSince:now];

    XCTAssertGreaterThanOrEqual(elapsed, 0);
    XCTAssertLessThan(elapsed, 1.0);
}

#pragma mark - customEndcardDisplayBehaviourFromString tests

//- (void)test_customEndcardDisplayBehaviourFromString_withFallbackValue_shouldReturnFallback {
//    HyBidCustomEndcardDisplayBehaviour behaviour = [self.adRequest customEndcardDisplayBehaviourFromString:@"fallback"];
//    XCTAssertEqual(behaviour, HyBidCustomEndcardDisplayFallback);
//}
//
//- (void)test_customEndcardDisplayBehaviourFromString_withExtensionValue_shouldReturnExtension {
//    HyBidCustomEndcardDisplayBehaviour behaviour = [self.adRequest customEndcardDisplayBehaviourFromString:@"extension"];
//    XCTAssertEqual(behaviour, HyBidCustomEndcardDisplayExtention);
//}
//
//- (void)test_customEndcardDisplayBehaviourFromString_withUnknownValue_shouldReturnFallback {
//    HyBidCustomEndcardDisplayBehaviour behaviour = [self.adRequest customEndcardDisplayBehaviourFromString:@"unknownValue"];
//    XCTAssertEqual(behaviour, HyBidCustomEndcardDisplayFallback);
//}
//
//- (void)test_customEndcardDisplayBehaviourFromString_withNilValue_shouldReturnFallback {
//    HyBidCustomEndcardDisplayBehaviour behaviour = [self.adRequest customEndcardDisplayBehaviourFromString:nil];
//    XCTAssertEqual(behaviour, HyBidCustomEndcardDisplayFallback);
//}
//
//- (void)test_customEndcardDisplayBehaviourFromString_withNonStringValue_shouldReturnFallback {
//    HyBidCustomEndcardDisplayBehaviour behaviour = [self.adRequest customEndcardDisplayBehaviourFromString:(NSString *)@(42)];
//    XCTAssertEqual(behaviour, HyBidCustomEndcardDisplayFallback);
//}

#pragma mark - processVASTTagResponseFrom (OpenRTB XML escaping) tests

- (void)test_processVASTTagResponseFrom_withOpenRTBEnabled_withXMLChars_shouldNotCrash {
    // With isUsingOpenRTB=YES, lines 325-327 execute to escape <, >, & before JSON parsing
    self.adRequest.isUsingOpenRTB = YES;
    NSString *content = @"<html>test & value</html>";
    XCTAssertNoThrow([self.adRequest processVASTTagResponseFrom:content]);
}

- (void)test_processVASTTagResponseFrom_withOpenRTBEnabled_withNilContent_shouldNotCrash {
    self.adRequest.isUsingOpenRTB = YES;
    XCTAssertNoThrow([self.adRequest processVASTTagResponseFrom:nil]);
}

- (void)test_processVASTTagResponseFrom_withOpenRTBEnabled_withValidJSON_shouldNotCrash {
    self.adRequest.isUsingOpenRTB = YES;
    // Valid JSON with no seatbid → adContent becomes nil → method exits cleanly
    NSString *content = @"{\"id\":\"test\",\"seatbid\":[]}";
    XCTAssertNoThrow([self.adRequest processVASTTagResponseFrom:content]);
}

#pragma mark - setMediationVendor tests

- (void)test_setMediationVendor_withValidVendor_shouldNotCrash {
    XCTAssertNoThrow([self.adRequest setMediationVendor:@"TestVendor"]);
}

- (void)test_setMediationVendor_withNilVendor_shouldNotCrash {
    XCTAssertNoThrow([self.adRequest setMediationVendor:nil]);
}

- (void)test_setMediationVendor_withEmptyVendor_shouldNotCrash {
    XCTAssertNoThrow([self.adRequest setMediationVendor:@""]);
}

@end
