//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidOpenRTBPrivacyDataModel.h"
#import "HyBidUserDataManager.h"
#import "HyBidRequestParameter.h"

@interface HyBidOpenRTBPrivacyDataModelTests : XCTestCase
@end

@implementation HyBidOpenRTBPrivacyDataModelTests

- (void)tearDown {
    // Reset GPP SID after each test
    [[HyBidUserDataManager sharedInstance] setInternalGPPSID:@""];
    [super tearDown];
}

#pragma mark - init tests

- (void)test_init_shouldReturnNonNilObject {
    id model = [[HyBidOpenRTBPrivacyDataModel alloc] init];
    XCTAssertNotNil(model);
}

- (void)test_init_shouldReturnDictionaryStructure {
    id model = [[HyBidOpenRTBPrivacyDataModel alloc] init];
    // The init returns a NSDictionary copy (the class returns itself as a dict)
    XCTAssertTrue([model isKindOfClass:[NSDictionary class]]);
}

- (void)test_init_shouldContainRegsKey {
    NSDictionary *model = (NSDictionary *)[[HyBidOpenRTBPrivacyDataModel alloc] init];
    XCTAssertNotNil(model[@"regs"]);
}

- (void)test_init_regsValue_shouldContainExtKey {
    NSDictionary *model = (NSDictionary *)[[HyBidOpenRTBPrivacyDataModel alloc] init];
    NSDictionary *regs = model[@"regs"];
    XCTAssertNotNil(regs[@"ext"]);
}

- (void)test_init_shouldNotCrash {
    XCTAssertNoThrow([[HyBidOpenRTBPrivacyDataModel alloc] init]);
}

- (void)test_init_extValue_shouldBeDictionary {
    NSDictionary *model = (NSDictionary *)[[HyBidOpenRTBPrivacyDataModel alloc] init];
    NSDictionary *regs = model[@"regs"];
    id ext = regs[@"ext"];
    XCTAssertTrue([ext isKindOfClass:[NSDictionary class]]);
}

#pragma mark - GPP SID underscore replacement tests

- (void)test_init_withGPPSIDContainingUnderscores_shouldReplaceWithCommas {
    // Lines 31-34 in HyBidOpenRTBPrivacyDataModel.m: safeReplace '_' → ',' in gpp_sid
    [[HyBidUserDataManager sharedInstance] setInternalGPPSID:@"1_2_3"];

    NSDictionary *model = (NSDictionary *)[[HyBidOpenRTBPrivacyDataModel alloc] init];
    NSDictionary *ext = model[@"regs"][@"ext"];
    NSString *gppSid = ext[HyBidRequestParameter.openRTBgpp_sid];

    XCTAssertNotNil(gppSid);
    XCTAssertEqualObjects(gppSid, @"1,2,3");
    XCTAssertFalse([gppSid containsString:@"_"], @"Underscores should be replaced with commas");
}

- (void)test_init_withGPPSIDWithoutUnderscores_shouldKeepAsIs {
    [[HyBidUserDataManager sharedInstance] setInternalGPPSID:@"123"];

    NSDictionary *model = (NSDictionary *)[[HyBidOpenRTBPrivacyDataModel alloc] init];
    NSDictionary *ext = model[@"regs"][@"ext"];
    NSString *gppSid = ext[HyBidRequestParameter.openRTBgpp_sid];

    XCTAssertEqualObjects(gppSid, @"123");
}

@end
