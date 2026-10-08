//
//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>
#import "HyBidVGIManager.h"
#import "HyBidVGIUser.h"
#import "HyBidVGILocation.h"
#import "PNLiteLocationManager.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface HyBidVGIManager (Testing)
+(NSArray<HyBidVGIUser *> *)getHyBidVGIUsers;
@end

@interface PNLiteLocationManager (Testing)
+ (instancetype)sharedInstance;
@end

@interface HyBidVGIManagerTests : XCTestCase
@end

@implementation HyBidVGIManagerTests {
    CLLocation *_originalLastKnownLocation;
    BOOL _originalLocationTrackingEnabled;
    BOOL _originalCoppa;
}

- (void)setUp {
    [super setUp];
    _originalLastKnownLocation = [[PNLiteLocationManager sharedInstance] valueForKey:@"lastKnownLocation"];
    _originalLocationTrackingEnabled = HyBidLocationConfig.sharedConfig.locationTrackingEnabled;
    _originalCoppa = HyBidConsentConfig.sharedConfig.coppa;
    HyBidConsentConfig.sharedConfig.coppa = NO;
    HyBidLocationConfig.sharedConfig.locationTrackingEnabled = YES;
}

- (void)tearDown {
    [[PNLiteLocationManager sharedInstance] setValue:_originalLastKnownLocation forKey:@"lastKnownLocation"];
    HyBidLocationConfig.sharedConfig.locationTrackingEnabled = _originalLocationTrackingEnabled;
    HyBidConsentConfig.sharedConfig.coppa = _originalCoppa;
    [super tearDown];
}

// VMI-1734: VGI lat/lon must be the shared 2-decimal format.
- (void)test_getHyBidVGIUsers_withKnownLocation_setsFormattedRoundedLatAndLon {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:52.345678 longitude:-73.935242];
    [[PNLiteLocationManager sharedInstance] setValue:location forKey:@"lastKnownLocation"];

    NSArray<HyBidVGIUser *> *users = [HyBidVGIManager getHyBidVGIUsers];

    XCTAssertEqual(users.count, 1);
    HyBidVGIUser *user = users.firstObject;
    XCTAssertEqual(user.locations.count, 1);

    HyBidVGILocation *vgiLocation = user.locations.firstObject;
    XCTAssertEqualObjects(vgiLocation.lat, @"52.35");
    XCTAssertEqualObjects(vgiLocation.lon, @"-73.94");
}

@end
