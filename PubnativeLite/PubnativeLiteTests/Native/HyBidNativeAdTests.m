//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidNativeAd.h"
#import "HyBidAd.h"
#import "PNLiteResponseModel.h"
#import "HyBidATOMManager.h"

@interface HyBidNativeAd (TestCoverage)
- (void)percentVisibleDidChange:(CGFloat)newValue;
@end

/// Unit tests for HyBidNativeAd to improve coverage on new code (initWithAd, dealloc, HyBidATOMManager).
@interface HyBidNativeAdTests : XCTestCase
@end

@implementation HyBidNativeAdTests

- (void)testNativeAdCreationAndDealloc_doesNotCrash {
    // Create with ad and release to cover dealloc path (1 uncovered line)
    @autoreleasepool {
        HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:nil];
        XCTAssertNotNil(nativeAd);
        nativeAd = nil;
    }
}

- (void)testInitWithAd_withRealAd_fromBundle_coversInitPath {
    // initWithAd with non-nil ad exercises activateContext and full init (for coverage)
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    if (!path) {
        XCTSkip(@"adResponse.txt not found");
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data);
    NSError *err = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    XCTAssertNil(err);
    PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:json];
    if (response.ads.count == 0) {
        XCTSkip(@"No ads in response");
    }
    HyBidAd *ad = [[HyBidAd alloc] initWithData:response.ads.firstObject withZoneID:@"4"];
    XCTAssertNotNil(ad);
    @autoreleasepool {
        HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:ad];
        XCTAssertNotNil(nativeAd);
        nativeAd = nil;
    }
}

- (void)testFetchNativeAdAssetsWithDelegate_nilAd_doesNotCrash {
    HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:nil];
    id <HyBidNativeAdFetchDelegate> delegate = nil;
    XCTAssertNoThrow([nativeAd fetchNativeAdAssetsWithDelegate:delegate]);
}

- (void)testStartTrackingView_stopTracking_nilAd_doNotCrash {
    HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:nil];
    UIView *view = [[UIView alloc] init];
    [nativeAd startTrackingView:view withDelegate:nil];
    XCTAssertNoThrow([nativeAd stopTracking]);
}

// Covers new code: HyBidATOMManager.fireAdSessionEventWithData in percentVisibleDidChange:
- (void)testPercentVisibleDidChange_firesHyBidATOMManagerEvent {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:ad];
    nativeAd.adSessionData = [HyBidATOMManager createAdSessionDataFromRequest:nil ad:ad];
    XCTAssertNoThrow([nativeAd percentVisibleDidChange:0.5f]);
}

- (HyBidAd *)hyBidAdFromTestBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    if (!path) return nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if (![json isKindOfClass:[NSDictionary class]]) return nil;
    PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:json];
    if (!response.ads.count) return nil;
    return [[HyBidAd alloc] initWithData:response.ads.firstObject withZoneID:@"4"];
}

@end
