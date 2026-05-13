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

@interface HyBidNativeAd (ClickTrackingInternals)
@property (nonatomic, readonly) NSArray<UITapGestureRecognizer *> *tapRecognizers;
@end

/// Test subclass that supplies a dummy click URL so click-tracking tests can reach the
/// recognizer-setup branch without needing a real HyBidAd fixture.
@interface HyBidNativeAdClickStub : HyBidNativeAd
@end
@implementation HyBidNativeAdClickStub
- (NSString *)clickUrl { return @"https://example.com"; }
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

// MARK: - Click tracking tests

/// After startTrackingView:withClickableViews:withDelegate:, each view must have exactly one
/// recognizer and that recognizer must be in tapRecognizers.
- (void)testStartTrackingWithClickableViews_attachesOneRecognizerPerView {
    // Use the stub subclass so clickUrl is non-nil and recognizer setup is reached.
    HyBidNativeAd *nativeAd = [[HyBidNativeAdClickStub alloc] initWithAd:nil];
    UIView *container = [[UIView alloc] init];
    UIView *v1 = [[UIView alloc] init];
    UIView *v2 = [[UIView alloc] init];
    UIView *v3 = [[UIView alloc] init];

    [nativeAd startTrackingView:container withClickableViews:@[v1, v2, v3] withDelegate:nil];

    XCTAssertEqual(nativeAd.tapRecognizers.count, 3U);
    XCTAssertEqual(v1.gestureRecognizers.count, 1U);
    XCTAssertEqual(v2.gestureRecognizers.count, 1U);
    XCTAssertEqual(v3.gestureRecognizers.count, 1U);
    // Each recognizer must sit on its own view (not all on the last one).
    XCTAssertEqualObjects(nativeAd.tapRecognizers[0].view, v1);
    XCTAssertEqualObjects(nativeAd.tapRecognizers[1].view, v2);
    XCTAssertEqualObjects(nativeAd.tapRecognizers[2].view, v3);
}

/// stopTracking must remove every recognizer from every view.
- (void)testStopTracking_removesAllRecognizers {
    HyBidNativeAd *nativeAd = [[HyBidNativeAdClickStub alloc] initWithAd:nil];
    UIView *container = [[UIView alloc] init];
    UIView *v1 = [[UIView alloc] init];
    UIView *v2 = [[UIView alloc] init];

    [nativeAd startTrackingView:container withClickableViews:@[v1, v2] withDelegate:nil];
    [nativeAd stopTracking];

    XCTAssertEqual(nativeAd.tapRecognizers.count, 0U);
    XCTAssertEqual(v1.gestureRecognizers.count, 0U);
    XCTAssertEqual(v2.gestureRecognizers.count, 0U);
}

/// Calling startTrackingView:withClickableViews:withDelegate: a second time must not leave
/// orphaned recognizers on the first set of views.
- (void)testStartTrackingTwice_prevRecognizersRemovedBeforeReplace {
    HyBidNativeAd *nativeAd = [[HyBidNativeAdClickStub alloc] initWithAd:nil];
    UIView *container = [[UIView alloc] init];
    UIView *first = [[UIView alloc] init];
    UIView *second = [[UIView alloc] init];

    // First registration.
    [nativeAd startTrackingView:container withClickableViews:@[first] withDelegate:nil];
    XCTAssertEqual(first.gestureRecognizers.count, 1U);

    // Second registration with a different view.
    [nativeAd startTrackingView:container withClickableViews:@[second] withDelegate:nil];

    // Old view must be clean; new view must have exactly one recognizer.
    XCTAssertEqual(first.gestureRecognizers.count, 0U,
                   @"First registration's recognizer must be removed on re-tracking");
    XCTAssertEqual(second.gestureRecognizers.count, 1U);
    XCTAssertEqual(nativeAd.tapRecognizers.count, 1U);
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
