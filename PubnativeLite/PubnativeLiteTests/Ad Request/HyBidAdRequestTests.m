//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>
#import "HyBid.h"
#import "HyBidAdCache.h"
#import "HyBidAdFeedbackParameters.h"
#import "HyBidAdRequest.h"
#import "HyBidError.h"
#import "HyBidVASTEventProcessor.h"
#import "PNLiteHttpRequest.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

static NSInteger const kResponseStatusOK = 200;
static NSString *const kPlainVASTErrorTagURL = @"http://adserver.com/noad.gif";
static NSString *const kPlainVASTWithoutAds = @"<VAST version=\"4.1\"><Error><![CDATA[http://adserver.com/noad.gif]]></Error></VAST>";

// Expose private methods for testing
@interface HyBidAdRequest (Testing)
- (NSTimeInterval)elapsedTimeSince:(NSTimeInterval)timestamp;
- (nullable NSDictionary *)createDictionaryFromData:(NSData *)data;
- (void)processVASTTagResponseFrom:(NSString *)vastAdContent;
- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode;
//- (HyBidCustomEndcardDisplayBehaviour)customEndcardDisplayBehaviourFromString:(NSString *)string;
@end

@interface HyBidAdRequestCaptureDelegate : NSObject <HyBidAdRequestDelegate>
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) NSError *error;
@end

@implementation HyBidAdRequestCaptureDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    self.ad = ad;
    [self.expectation fulfill];
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    self.error = error;
    [self.expectation fulfill];
}

@end

@interface HyBidAdRequestTests : XCTestCase
@property (nonatomic, strong) HyBidAdRequest *adRequest;
@end

@implementation HyBidAdRequestTests

- (NSData *)reencodedAPIv3VideoResponseData {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);
    NSData *sourceData = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(sourceData);

    NSError *error;
    id response = [NSJSONSerialization JSONObjectWithData:sourceData options:0 error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([response isKindOfClass:[NSDictionary class]]);
    XCTAssertGreaterThan([response[@"ads"] count], 0);

    NSData *reencodedData = [NSJSONSerialization dataWithJSONObject:response options:0 error:&error];
    XCTAssertNil(error);
    NSString *reencodedResponse = [[NSString alloc] initWithData:reencodedData encoding:NSUTF8StringEncoding];
    reencodedResponse = [reencodedResponse stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    XCTAssertTrue([reencodedResponse containsString:@"<VAST"]);
    XCTAssertTrue([reencodedResponse containsString:@"</VAST>"]);

    NSData *normalizedData = [reencodedResponse dataUsingEncoding:NSUTF8StringEncoding];
    id normalizedResponse = [NSJSONSerialization JSONObjectWithData:normalizedData options:0 error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(normalizedResponse, response);
    return normalizedData;
}

- (HyBidVASTEventProcessor *)primedNetworkResponseContextWithMockedEventProcessor {
    HyBidVASTEventProcessor *eventProcessor = mock([HyBidVASTEventProcessor class]);
    [self.adRequest setValue:eventProcessor forKey:@"vastEventProcessor"];
    [self.adRequest setValue:[NSDate date] forKey:@"startTime"];
    [self.adRequest setValue:[NSURL URLWithString:@"https://api.pubnative.net/api/v3/native"] forKey:@"requestURL"];
    return eventProcessor;
}

- (HyBidAdRequestCaptureDelegate *)attachedCaptureDelegateWithDescription:(NSString *)description {
    HyBidAdRequestCaptureDelegate *delegate = [[HyBidAdRequestCaptureDelegate alloc] init];
    delegate.expectation = [self expectationWithDescription:description];
    self.adRequest.delegate = delegate;
    return delegate;
}

- (void)waitForRequestDelegate:(HyBidAdRequestCaptureDelegate *)delegate {
    [self waitForExpectations:@[delegate.expectation] timeout:5.0];
}

- (void)setUp {
    [super setUp];
    self.adRequest = [[HyBidAdRequest alloc] init];
}

- (void)tearDown {
    for (NSString *zoneID in @[@"vmi-1706", @"legacy_api_tester"]) {
        [[HyBidAdCache sharedInstance].adCache removeObjectForKey:zoneID];
        [[[HyBidAdFeedbackParameters sharedInstance] valueForKey:@"adCache"] removeObjectForKey:zoneID];
        [[[HyBidAdFeedbackParameters sharedInstance] valueForKey:@"adRequestCache"] removeObjectForKey:zoneID];
    }
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

#pragma mark - response classification tests

// VMI-1706: a JSON ad response carrying literal VAST markup must not be sniffed as a plain-VAST document.
- (void)test_networkResponse_withReencodedAPIv3Response_shouldLoadWithoutVASTErrorBeacon {
    HyBidVASTEventProcessor *eventProcessor = [self primedNetworkResponseContextWithMockedEventProcessor];
    [self.adRequest setValue:@"vmi-1706" forKey:@"zoneID"];
    self.adRequest.isAutoCacheOnLoad = NO;

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"APIv3 response completes"];

    [self.adRequest request:nil
          didFinishWithData:[self reencodedAPIv3VideoResponseData]
                 statusCode:kResponseStatusOK];
    [self waitForRequestDelegate:delegate];

    XCTAssertNotNil(delegate.ad);
    XCTAssertNil(delegate.error);
    XCTAssertEqual(delegate.ad.assetGroupID.integerValue, VAST_INTERSTITIAL);
    XCTAssertTrue([delegate.ad.vast containsString:@"<VAST"]);
    XCTAssertGreaterThan(delegate.ad.customEndCardData.length, 0);
    [verifyCount(eventProcessor, never()) sendVASTUrls:anything() withType:HyBidVASTParserErrorURL];
}

- (void)test_networkResponse_withInvalidJSONContainingVASTMarkup_shouldReturnParseErrorWithoutVASTErrorBeacon {
    HyBidVASTEventProcessor *eventProcessor = [self primedNetworkResponseContextWithMockedEventProcessor];

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Invalid response fails"];

    NSData *data = [@"upstream proxy error: <VAST></VAST>" dataUsingEncoding:NSUTF8StringEncoding];
    [self.adRequest request:nil didFinishWithData:data statusCode:kResponseStatusOK];
    [self waitForRequestDelegate:delegate];

    XCTAssertNil(delegate.ad);
    XCTAssertEqual(delegate.error.code, HyBidErrorCodeParse);
    [verifyCount(eventProcessor, never()) sendVASTUrls:anything() withType:HyBidVASTParserErrorURL];
}

- (void)test_networkResponse_withNonUTF8Body_shouldReturnParseError {
    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Undecodable response fails"];

    uint8_t invalidUTF8[] = {0xC3, 0x28, 0xA0, 0xA1};
    NSData *data = [NSData dataWithBytes:invalidUTF8 length:sizeof(invalidUTF8)];
    XCTAssertNil([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    [self.adRequest request:nil didFinishWithData:data statusCode:kResponseStatusOK];
    [self waitForRequestDelegate:delegate];

    XCTAssertNil(delegate.ad);
    XCTAssertEqual(delegate.error.code, HyBidErrorCodeParse);
}

- (void)test_networkResponse_withPlainVASTContainingNoAds_shouldPreserveNullAdErrorAndBeacon {
    HyBidVASTEventProcessor *eventProcessor = [self primedNetworkResponseContextWithMockedEventProcessor];

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Plain VAST no-ad response fails"];

    [self.adRequest request:nil
          didFinishWithData:[kPlainVASTWithoutAds dataUsingEncoding:NSUTF8StringEncoding]
                 statusCode:kResponseStatusOK];
    [self waitForRequestDelegate:delegate];

    XCTAssertEqual(delegate.error.code, HyBidErrorCodeNullAd);
    [verifyCount(eventProcessor, times(1)) sendVASTUrls:@[kPlainVASTErrorTagURL]
                                             withType:HyBidVASTParserErrorURL];
}

#pragma mark - injected response classification tests

// VMI-1706: the injected path must classify the body the same way the network path does.
- (void)test_injectedResponse_withReencodedAPIv3Response_shouldLoadWithoutVASTErrorBeacon {
    HyBidVASTEventProcessor *eventProcessor = [self primedNetworkResponseContextWithMockedEventProcessor];
    self.adRequest.isAutoCacheOnLoad = NO;

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Injected APIv3 response completes"];

    NSString *response = [[NSString alloc] initWithData:[self reencodedAPIv3VideoResponseData]
                                               encoding:NSUTF8StringEncoding];
    [self.adRequest processResponseWithJSON:response];
    [self waitForRequestDelegate:delegate];

    XCTAssertNotNil(delegate.ad);
    XCTAssertNil(delegate.error);
    XCTAssertEqual(delegate.ad.assetGroupID.integerValue, VAST_INTERSTITIAL);
    [verifyCount(eventProcessor, never()) sendVASTUrls:anything() withType:HyBidVASTParserErrorURL];
}

- (void)test_injectedResponse_withPlainVASTContainingNoAds_shouldTakeTheVASTBranch {
    HyBidVASTEventProcessor *eventProcessor = [self primedNetworkResponseContextWithMockedEventProcessor];

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Injected plain VAST fails as VAST"];

    [self.adRequest processResponseWithJSON:kPlainVASTWithoutAds];
    [self waitForRequestDelegate:delegate];

    XCTAssertEqual(delegate.error.code, HyBidErrorCodeNullAd);
    [verifyCount(eventProcessor, times(1)) sendVASTUrls:@[kPlainVASTErrorTagURL]
                                             withType:HyBidVASTParserErrorURL];
}

// VMI-1706: a body starting with "<" but with no lossless UTF-8 form must not hand nil data to HyBidVASTModel.
- (void)test_injectedResponse_withUnencodableString_shouldReturnParseErrorWithoutCrashing {
    HyBidVASTEventProcessor *eventProcessor = [self primedNetworkResponseContextWithMockedEventProcessor];

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Unencodable response fails"];

    unichar unpairedSurrogate[] = {'<', 0xD800};
    NSString *unencodable = [NSString stringWithCharacters:unpairedSurrogate length:2];
    XCTAssertTrue([unencodable hasPrefix:@"<"]);
    XCTAssertNil([unencodable dataUsingEncoding:NSUTF8StringEncoding]);

    XCTAssertNoThrow([self.adRequest processResponseWithJSON:unencodable]);
    [self waitForRequestDelegate:delegate];

    XCTAssertNil(delegate.ad);
    XCTAssertEqual(delegate.error.code, HyBidErrorCodeParse);
    [verifyCount(eventProcessor, never()) sendVASTUrls:anything() withType:HyBidVASTParserErrorURL];
}

// VMI-1706: the OpenRTB branch must not hand the nil data of an unencodable body to NSJSONSerialization.
- (void)test_injectedResponse_withUnencodableStringOnOpenRTB_shouldReturnParseErrorWithoutCrashing {
    self.adRequest.isUsingOpenRTB = YES;
    self.adRequest.openRTBAdType = HyBidOpenRTBAdBanner;

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Unencodable OpenRTB response fails"];

    unichar unpairedSurrogate[] = {'<', 0xD800};
    NSString *unencodable = [NSString stringWithCharacters:unpairedSurrogate length:2];
    XCTAssertNil([unencodable dataUsingEncoding:NSUTF8StringEncoding]);

    XCTAssertNoThrow([self.adRequest processResponseWithJSON:unencodable]);
    [self waitForRequestDelegate:delegate];

    XCTAssertNil(delegate.ad);
    XCTAssertEqual(delegate.error.code, HyBidErrorCodeParse);
}

// VMI-1706: markup whose real XML root is not <VAST> is not a VAST document, even when it embeds one.
- (void)test_injectedResponse_withNonVASTXMLContainingNestedVAST_shouldReturnParseErrorWithoutVASTErrorBeacon {
    HyBidVASTEventProcessor *eventProcessor = [self primedNetworkResponseContextWithMockedEventProcessor];

    HyBidAdRequestCaptureDelegate *delegate = [self attachedCaptureDelegateWithDescription:@"Nested VAST fails as parse error"];

    [self.adRequest processResponseWithJSON:@"<html><VAST></VAST></html>"];
    [self waitForRequestDelegate:delegate];

    XCTAssertNil(delegate.ad);
    XCTAssertEqual(delegate.error.code, HyBidErrorCodeParse);
    [verifyCount(eventProcessor, never()) sendVASTUrls:anything() withType:HyBidVASTParserErrorURL];
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
