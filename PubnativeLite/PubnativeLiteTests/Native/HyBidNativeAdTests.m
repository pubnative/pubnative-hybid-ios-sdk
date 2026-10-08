//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <OCMockito/OCMockito.h>
#import "HyBidNativeAd.h"
#import "HyBidAd.h"
#import "HyBidDataModel.h"
#import "HyBidJSBeaconLoader+Testing.h"
#import "PNLiteData.h"
#import "PNLiteResponseModel.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif
extern NSString * const PNLiteNativeAdBeaconImpression;

@interface HyBidNativeAd (TestCoverage)
- (void)percentVisibleDidChange:(CGFloat)newValue;
- (void)confirmBeaconsWithType:(NSString *)type;
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

/// Unit tests for HyBidNativeAd to improve coverage on new code (initWithAd, dealloc).
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

- (void)testPercentVisibleDidChange_updatesViewabilityAndDoesNotCrash {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:ad];
    nativeAd.adSessionData = [[HyBidAdSessionData alloc] init];
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

// MARK: - VMI-1750: JS-type beacons are loaded as HTML, not evaluated as JS expressions

- (HyBidDataModel *)jsBeaconWithType:(NSString *)type js:(NSString *)js {
    return [[HyBidDataModel alloc] initWithDictionary:@{@"type": type, @"data": @{@"js": js}}];
}

- (void)testConfirmBeaconsWithType_jsScriptTagBeacon_reportsBeacon {
    [HyBidJSBeaconLoader hybid_stubLoadWithError:nil];
    [HyBidReportingManager sharedInstance].beacons = @[];
    [HyBidSDKConfig sharedConfig].reporting = YES;

    NSString *scriptTag = @"<script>var x = 1;</script>";
    HyBidAd *mockAd = mock([HyBidAd class]);
    [given([mockAd beacons]) willReturn:@[[self jsBeaconWithType:PNLiteNativeAdBeaconImpression js:scriptTag]]];

    HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:mockAd];
    [nativeAd confirmBeaconsWithType:PNLiteNativeAdBeaconImpression];

    NSPredicate *beaconAdded = [NSPredicate predicateWithBlock:^BOOL(id _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [HyBidReportingManager sharedInstance].beacons.count == 1;
    }];
    [self expectationForPredicate:beaconAdded evaluatedWithObject:nil handler:nil];
    // The completion still hops through a dispatch_async(main queue) in production code before
    // hitting the synchronous test stub, so give a busy CI run loop more slack than 5s.
    [self waitForExpectationsWithTimeout:15 handler:nil];

    HyBidReportingBeacon *beacon = [HyBidReportingManager sharedInstance].beacons.firstObject;
    NSDictionary *data = beacon.properties[@"data"];
    XCTAssertEqualObjects(data[PNLiteData.js], scriptTag);

    [HyBidReportingManager sharedInstance].beacons = @[];
    [HyBidJSBeaconLoader hybid_removeLoadStub];
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
