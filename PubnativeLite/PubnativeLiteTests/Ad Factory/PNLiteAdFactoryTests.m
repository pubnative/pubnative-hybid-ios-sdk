//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "PNLiteAdFactory.h"
#import "HyBidAdSize.h"
#import "HyBidUserDataManager.h"
#import "HyBidRequestParameter.h"
#import "PNLiteLocationManager.h"
#import <CoreLocation/CoreLocation.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

// Expose private methods for testing
@interface PNLiteAdFactory (Testing)
- (NSString *)formatUTCTime;
- (void)setDefaultAssetFields:(PNLiteAdRequestModel *)adRequestModel;
- (void)setDefaultMetaFields:(PNLiteAdRequestModel *)adRequestModel;
@end

@interface PNLiteLocationManager (Testing)
+ (instancetype)sharedInstance;
@end

@interface PNLiteAdFactoryTests : XCTestCase
@property (nonatomic, strong) PNLiteAdFactory *adFactory;
@end

@implementation PNLiteAdFactoryTests {
    CLLocation *_originalLastKnownLocation;
    BOOL _originalLocationTrackingEnabled;
    BOOL _originalCoppa;
}

- (void)setUp {
    [super setUp];
    self.adFactory = [[PNLiteAdFactory alloc] init];

    _originalLastKnownLocation = [[PNLiteLocationManager sharedInstance] valueForKey:@"lastKnownLocation"];
    _originalLocationTrackingEnabled = HyBidLocationConfig.sharedConfig.locationTrackingEnabled;
    _originalCoppa = HyBidConsentConfig.sharedConfig.coppa;
    HyBidConsentConfig.sharedConfig.coppa = NO;
}

- (void)tearDown {
    // Reset GPP SID after each test
    [[HyBidUserDataManager sharedInstance] setInternalGPPSID:@""];

    [[PNLiteLocationManager sharedInstance] setValue:_originalLastKnownLocation forKey:@"lastKnownLocation"];
    HyBidLocationConfig.sharedConfig.locationTrackingEnabled = _originalLocationTrackingEnabled;
    HyBidConsentConfig.sharedConfig.coppa = _originalCoppa;

    self.adFactory = nil;
    [super tearDown];
}

#pragma mark - init tests

- (void)test_init_shouldReturnNonNilInstance {
    XCTAssertNotNil(self.adFactory);
}

#pragma mark - createAdRequest tests

- (void)test_createAdRequest_withValidParams_shouldReturnNonNilModel {
    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone123"
                                                               withAppToken:@"token123"
                                                                 withAdSize:HyBidAdSize.SIZE_320x50
                                                 withSupportedAPIFrameworks:@[@"5", @"7"]
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];
    XCTAssertNotNil(model);
}

- (void)test_createAdRequest_shouldContainZoneIdInParameters {
    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone999"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_320x50
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    XCTAssertNotNil(model.requestParameters);
    XCTAssertEqualObjects(model.requestParameters[@"zoneid"], @"zone999");
}

- (void)test_createAdRequest_withInterstitialSize_shouldSetInterstitialParam {
    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_INTERSTITIAL
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    XCTAssertEqualObjects(model.requestParameters[HyBidRequestParameter.interstitial], @"1");
}

- (void)test_createAdRequest_withBannerSize_shouldSetInterstitialParamToZero {
    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_320x50
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    XCTAssertEqualObjects(model.requestParameters[HyBidRequestParameter.interstitial], @"0");
}

- (void)test_createAdRequest_withRewardedTrue_shouldSetRewardedParam {
    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_INTERSTITIAL
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:YES
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    XCTAssertEqualObjects(model.requestParameters[@"rv"], @"1");
}

- (void)test_createAdRequest_withRewardedFalse_shouldSetRewardedParamToZero {
    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_320x50
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    XCTAssertEqualObjects(model.requestParameters[@"rv"], @"0");
}

- (void)test_createAdRequest_withMediationVendorName_shouldSetMediationVendor {
    [self.adFactory createAdRequestWithZoneID:@"zone"
                                 withAppToken:@"token"
                                   withAdSize:HyBidAdSize.SIZE_320x50
                   withSupportedAPIFrameworks:nil
                          withIntegrationType:HEADER_BIDDING
                                   isRewarded:NO
                               isUsingOpenRTB:NO
                          mediationVendorName:@"MyMediation"];

    XCTAssertEqualObjects(self.adFactory.mediationVendor, @"MyMediation");
}

#pragma mark - GPP SID underscore replacement tests

- (void)test_createAdRequest_withGPPSIDContainingUnderscores_shouldReplaceWithCommas {
    // Lines 170-173 in PNLiteAdFactory.m: safeReplace '_' → ',' in gppSID before storing in params
    [[HyBidUserDataManager sharedInstance] setInternalGPPSID:@"1_2_3"];

    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_320x50
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    NSString *gppsid = model.requestParameters[HyBidRequestParameter.gppsid];
    XCTAssertNotNil(gppsid);
    XCTAssertEqualObjects(gppsid, @"1,2,3");
    XCTAssertFalse([gppsid containsString:@"_"], @"Underscores should be replaced with commas");
}

- (void)test_createAdRequest_withGPPSIDWithoutUnderscores_shouldKeepAsIs {
    [[HyBidUserDataManager sharedInstance] setInternalGPPSID:@"123"];

    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_320x50
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    NSString *gppsid = model.requestParameters[HyBidRequestParameter.gppsid];
    XCTAssertEqualObjects(gppsid, @"123");
}

#pragma mark - createAdRequest: location tests (VMI-1734)

// VMI-1734: ad-request lat/lon must be the shared 2-decimal format.
- (void)test_createAdRequest_locationTrackingEnabled_withValidCoordinates_setsFormattedLatLon {
    HyBidLocationConfig.sharedConfig.locationTrackingEnabled = YES;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:52.345678 longitude:-73.935242];
    [[PNLiteLocationManager sharedInstance] setValue:location forKey:@"lastKnownLocation"];

    PNLiteAdRequestModel *model = [self.adFactory createAdRequestWithZoneID:@"zone"
                                                               withAppToken:@"token"
                                                                 withAdSize:HyBidAdSize.SIZE_320x50
                                                 withSupportedAPIFrameworks:nil
                                                        withIntegrationType:HEADER_BIDDING
                                                                 isRewarded:NO
                                                             isUsingOpenRTB:NO
                                                        mediationVendorName:nil];

    XCTAssertEqualObjects(model.requestParameters[HyBidRequestParameter.lat], @"52.35");
    XCTAssertEqualObjects(model.requestParameters[HyBidRequestParameter.lon], @"-73.94");
}

#pragma mark - formatUTCTime tests

- (void)test_formatUTCTime_shouldReturnNonNilString {
    NSString *utcTime = [self.adFactory formatUTCTime];
    XCTAssertNotNil(utcTime);
}

- (void)test_formatUTCTime_shouldReturnNumericString {
    NSString *utcTime = [self.adFactory formatUTCTime];
    NSInteger value = [utcTime integerValue];
    // UTC offset in minutes is typically between -720 and 840
    XCTAssertGreaterThanOrEqual(value, -720);
    XCTAssertLessThanOrEqual(value, 840);
}

@end
