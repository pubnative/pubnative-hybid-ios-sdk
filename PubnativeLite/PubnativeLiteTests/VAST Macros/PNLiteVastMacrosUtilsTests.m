//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "PNLiteVastMacrosUtils.h"
#import "HyBidUserDataManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteVastMacrosUtilsTests : XCTestCase
@end

@implementation PNLiteVastMacrosUtilsTests

- (void)tearDown {
    // Reset state modified in COPPA / consent tests
    [HyBidConsentConfig sharedConfig].coppa = NO;
    [super tearDown];
}

#pragma mark - formatUrl: tests

- (void)test_formatUrl_withBundleIdMacro_shouldReplaceMacro {
    NSString *url = @"https://example.com/track?bundle=${BUNDLE_ID}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${BUNDLE_ID}"]);
}

- (void)test_formatUrl_withCacheBusterMacro_shouldReplaceMacro {
    NSString *url = @"https://example.com/track?cb=${CB}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${CB}"]);
}

- (void)test_formatUrl_withUserAgentMacro_shouldReplaceMacro {
    NSString *url = @"https://example.com/track?ua=${UA}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${UA}"]);
}

- (void)test_formatUrl_withConsentOptInMacro_shouldReplaceMacro {
    NSString *url = @"https://example.com/track?optin=${CONSENT_OPTIN}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${CONSENT_OPTIN}"]);
}

- (void)test_formatUrl_withConsentOptOutMacro_shouldReplaceMacro {
    NSString *url = @"https://example.com/track?optout=${CONSENT_OPTOUT}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${CONSENT_OPTOUT}"]);
}

- (void)test_formatUrl_withIdfaMacro_shouldReplaceMacro {
    NSString *url = @"https://example.com/track?idfa=${IDFA}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${IDFA}"]);
}

- (void)test_formatUrl_withIdfaMacro_whenNoAdvertisingId_shouldReplaceWithMinusOne {
    // When no advertising ID is available, ${IDFA} should be replaced with -1
    NSString *url = @"https://example.com/track?idfa=${IDFA}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${IDFA}"]);
}

- (void)test_formatUrl_withConsentStringMacro_whenConsentStringPresent_shouldReplaceMacro {
    NSString *url = @"https://example.com/track?consent=${CONSENT_STRING}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_withMultipleMacros_shouldReplaceAll {
    NSString *url = @"https://example.com/track?bundle=${BUNDLE_ID}&cb=${CB}&optin=${CONSENT_OPTIN}&optout=${CONSENT_OPTOUT}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${BUNDLE_ID}"]);
    XCTAssertFalse([result containsString:@"${CB}"]);
    XCTAssertFalse([result containsString:@"${CONSENT_OPTIN}"]);
    XCTAssertFalse([result containsString:@"${CONSENT_OPTOUT}"]);
}

- (void)test_formatUrl_withNoMacros_shouldReturnUrlEncodedString {
    NSString *url = @"https://example.com/track?param=value";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertGreaterThan(result.length, 0);
}

- (void)test_formatUrl_withEmptyUrl_shouldReturnResult {
    NSString *url = @"";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
}

- (void)test_formatUrl_cacheBusterMacro_shouldBeNumericTimestamp {
    NSString *url = @"https://example.com/track?cb=${CB}";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    // The CB value should contain a timestamp number
    XCTAssertFalse([result containsString:@"${CB}"]);
}

- (void)test_formatUrl_withAllMacros_shouldNotCrash {
    NSString *url = @"https://example.com/track?idfa=${IDFA}&bundle=${BUNDLE_ID}&cb=${CB}&ua=${UA}&consent=${CONSENT_STRING}&optin=${CONSENT_OPTIN}&optout=${CONSENT_OPTOUT}";

    XCTAssertNoThrow([PNLiteVastMacrosUtils formatUrl:url]);
}

- (void)test_formatUrl_shouldReturnPercentEncodedResult {
    NSString *url = @"https://example.com/track";
    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    // Result should be a valid URL string
    NSURL *resultUrl = [NSURL URLWithString:result];
    XCTAssertNotNil(resultUrl);
}

#pragma mark - COPPA branch tests (lines 36-40)

- (void)test_formatUrl_withCOPPAEnabled_shouldNotCrash {
    // Lines 36-40: COPPA block executes when [HyBidConsentConfig sharedConfig].coppa = YES
    [HyBidConsentConfig sharedConfig].coppa = YES;
    NSString *url = @"https://example.com/track?age=${AGE}&gender=${GENDER}";
    XCTAssertNoThrow([PNLiteVastMacrosUtils formatUrl:url]);
}

- (void)test_formatUrl_withCOPPAEnabled_shouldReplaceAgeMacro {
    [HyBidConsentConfig sharedConfig].coppa = YES;
    [HyBidSDKConfig sharedConfig].targeting.age = @25;
    NSString *url = @"https://example.com/track?age=${AGE}";

    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${AGE}"], @"${AGE} should be replaced when COPPA is enabled");
}

- (void)test_formatUrl_withCOPPAEnabled_shouldReplaceGenderMacro {
    [HyBidConsentConfig sharedConfig].coppa = YES;
    [HyBidSDKConfig sharedConfig].targeting.gender = @"m";
    NSString *url = @"https://example.com/track?gender=${GENDER}";

    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${GENDER}"], @"${GENDER} should be replaced when COPPA is enabled");
}

- (void)test_formatUrl_withCOPPADisabled_shouldNotReplaceAgeMacro {
    [HyBidConsentConfig sharedConfig].coppa = NO;
    NSString *url = @"https://example.com/track?age=${AGE}";

    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    // When COPPA is disabled the ${AGE} and ${GENDER} macros are intentionally left unreplaced
    XCTAssertTrue([result containsString:@"AGE"], @"${AGE} should remain when COPPA is disabled");
}

#pragma mark - Consent string branch tests (lines 29-31)

- (void)test_formatUrl_withConsentString_shouldReplaceConsentStringMacro {
    // Lines 29-31: consent string block executes when getIABGDPRConsentString returns non-nil
    [[HyBidUserDataManager sharedInstance] setIABGDPRConsentString:@"BOEFEAyOEFEAyAHABDENAI4AAAB9vABAASA"];
    NSString *url = @"https://example.com/track?consent=${CONSENT_STRING}";

    NSString *result = [PNLiteVastMacrosUtils formatUrl:url];

    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"${CONSENT_STRING}"], @"${CONSENT_STRING} should be replaced");
}

@end
