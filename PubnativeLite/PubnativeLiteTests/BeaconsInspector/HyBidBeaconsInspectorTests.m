//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidBeaconsInspectorHelper.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface HyBidBeaconsInspectorTests : XCTestCase
@end

@implementation HyBidBeaconsInspectorTests

// ============================================================================
#pragma mark - HyBidBeaconItem
// ============================================================================

- (void)testBeaconItem_initWithTypeUrlJs_storesValues {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"Impression" url:@"https://example.com" js:nil];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.type, @"Impression");
    XCTAssertEqualObjects(item.url, @"https://example.com");
    XCTAssertNil(item.js);
}

- (void)testBeaconItem_initWithJs_contentReturnsJsWhenUrlNil {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"custom" url:nil js:@"window.track();"];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.type, @"custom");
    XCTAssertNil(item.url);
    XCTAssertEqualObjects(item.js, @"window.track();");
    XCTAssertEqualObjects(item.content, @"window.track();");
}

- (void)testBeaconItem_contentReturnsUrlWhenPresent {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"click" url:@"https://click.com" js:nil];
    XCTAssertEqualObjects(item.content, @"https://click.com");
}

- (void)testBeaconItem_contentReturnsEmptyWhenUrlAndJsNil {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"type" url:nil js:nil];
    XCTAssertEqualObjects(item.content, @"");
}

- (void)testBeaconItem_contentPrefersUrlOverJs {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"t" url:@"https://u.com" js:@"js();"];
    XCTAssertEqualObjects(item.content, @"https://u.com");
}

- (void)testBeaconItem_initWithAllFields {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"click" url:@"https://click.url" js:@"clickJs();"];
    XCTAssertEqualObjects(item.type, @"click");
    XCTAssertEqualObjects(item.url, @"https://click.url");
    XCTAssertEqualObjects(item.js, @"clickJs();");
    XCTAssertEqualObjects(item.content, @"https://click.url");
}

- (void)testBeaconItem_initWithEmptyType {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"" url:@"https://u.com" js:nil];
    XCTAssertEqualObjects(item.type, @"");
    XCTAssertEqualObjects(item.url, @"https://u.com");
}

- (void)testBeaconItem_isNSObject {
    HyBidBeaconItem *item = [[HyBidBeaconItem alloc] initWithType:@"t" url:nil js:nil];
    XCTAssertTrue([item isKindOfClass:[NSObject class]]);
}

// ============================================================================
#pragma mark - HyBidBeaconsInspector singleton
// ============================================================================

- (void)testInspector_sharedIsNotNull {
    HyBidBeaconsInspector *inspector = [HyBidBeaconsInspector shared];
    XCTAssertNotNil(inspector);
}

- (void)testInspector_sharedReturnsSameInstance {
    HyBidBeaconsInspector *a = [HyBidBeaconsInspector shared];
    HyBidBeaconsInspector *b = [HyBidBeaconsInspector shared];
    XCTAssertEqual(a, b, @"shared should return the same singleton instance");
}

// ============================================================================
#pragma mark - HyBidBeaconsInspector firedBeacons
// ============================================================================

- (void)testInspector_firedBeaconsReturnsArray {
    HyBidBeaconsInspector *inspector = [HyBidBeaconsInspector shared];
    NSArray<HyBidBeaconItem *> *items = [inspector firedBeacons];
    XCTAssertNotNil(items);
    XCTAssertTrue([items isKindOfClass:[NSArray class]]);
}

- (void)testInspector_firedBeacons_withBeaconsInReportingManager_returnsBeaconItems {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    // Inject test beacons (HyBidDataModel expects "type" and "data" with url/js inside)
    HyBidReportingBeacon *b1 = [[HyBidReportingBeacon alloc] initWith:@"Impression" properties:@{@"type": @"Impression", @"data": @{@"url": @"https://beacon1.com"}}];
    HyBidReportingBeacon *b2 = [[HyBidReportingBeacon alloc] initWith:@"Click" properties:@{@"type": @"Click", @"data": @{@"url": @"https://beacon2.com", @"js": @"track();"}}];
    mgr.beacons = [@[b1, b2] mutableCopy];
    mgr.vastTrackers = [@[] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertEqual(items.count, 2);

    // Items should be sorted by type: Click < Impression
    XCTAssertEqualObjects(items[0].type, @"Click");
    XCTAssertEqualObjects(items[1].type, @"Impression");

    // Restore
    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

- (void)testInspector_firedBeacons_withVASTTrackersInReportingManager_returnsTrackerItems {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    mgr.beacons = [@[] mutableCopy];
    HyBidReportingVASTTracker *t1 = [[HyBidReportingVASTTracker alloc] initWith:@"start" properties:@{@"type": @"start", @"data": @{@"url": @"https://tracker1.com"}}];
    HyBidReportingVASTTracker *t2 = [[HyBidReportingVASTTracker alloc] initWith:@"complete" properties:@{@"type": @"complete", @"data": @{@"url": @"https://tracker2.com"}}];
    mgr.vastTrackers = [@[t1, t2] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertEqual(items.count, 2);
    // VAST trackers should have nil js
    for (HyBidBeaconItem *item in items) {
        XCTAssertNil(item.js);
    }
    // Sorted: Complete < Start (inspector capitalizes type via firstCapitalized)
    XCTAssertEqualObjects(items[0].type, @"Complete");
    XCTAssertEqualObjects(items[1].type, @"Start");

    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

- (void)testInspector_firedBeacons_withMixedBeaconsAndTrackers_sortedTogether {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    HyBidReportingBeacon *b = [[HyBidReportingBeacon alloc] initWith:@"Impression" properties:@{@"type": @"Impression", @"data": @{@"url": @"https://b.com"}}];
    mgr.beacons = [@[b] mutableCopy];
    HyBidReportingVASTTracker *t = [[HyBidReportingVASTTracker alloc] initWith:@"Click" properties:@{@"type": @"Click", @"data": @{@"url": @"https://t.com"}}];
    mgr.vastTrackers = [@[t] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertEqual(items.count, 2);
    // Click < Impression alphabetically
    XCTAssertEqualObjects(items[0].type, @"Click");
    XCTAssertEqualObjects(items[1].type, @"Impression");

    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

- (void)testInspector_firedBeacons_urlAndJs_fromNestedDataDict {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    HyBidReportingBeacon *beacon = [[HyBidReportingBeacon alloc] initWith:@"Impression"
                                                               properties:@{@"type": @"Impression", @"data": @{@"url": @"https://nested.com", @"js": @"nestedJs();"}}];
    mgr.beacons = [@[beacon] mutableCopy];
    mgr.vastTrackers = [@[] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertEqual(items.count, 1);
    XCTAssertEqualObjects(items[0].url, @"https://nested.com");
    XCTAssertEqualObjects(items[0].js, @"nestedJs();");

    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

- (void)testInspector_firedBeacons_urlAndJs_fromTopLevelProperties {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    HyBidReportingBeacon *beacon = [[HyBidReportingBeacon alloc] initWith:@"Click"
                                                               properties:@{@"type": @"Click", @"data": @{@"url": @"https://top.com", @"js": @"topJs();"}}];
    mgr.beacons = [@[beacon] mutableCopy];
    mgr.vastTrackers = [@[] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertEqual(items.count, 1);
    XCTAssertEqualObjects(items[0].url, @"https://top.com");
    XCTAssertEqualObjects(items[0].js, @"topJs();");

    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

- (void)testInspector_firedBeacons_nilProperties_returnsNilUrlAndJs {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    HyBidReportingBeacon *beacon = [[HyBidReportingBeacon alloc] initWith:@"Test" properties:@{@"type": @"Test"}];
    mgr.beacons = [@[beacon] mutableCopy];
    mgr.vastTrackers = [@[] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertEqual(items.count, 1);
    XCTAssertEqualObjects(items[0].type, @"Test");
    // With no "data", url and js are nil

    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

- (void)testInspector_firedBeacons_sameType_sortedByContent {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    HyBidReportingBeacon *b1 = [[HyBidReportingBeacon alloc] initWith:@"Impression" properties:@{@"type": @"Impression", @"data": @{@"url": @"https://zzz.com"}}];
    HyBidReportingBeacon *b2 = [[HyBidReportingBeacon alloc] initWith:@"Impression" properties:@{@"type": @"Impression", @"data": @{@"url": @"https://aaa.com"}}];
    mgr.beacons = [@[b1, b2] mutableCopy];
    mgr.vastTrackers = [@[] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertEqual(items.count, 2);
    // Same type, sorted by content: aaa < zzz
    XCTAssertEqualObjects(items[0].url, @"https://aaa.com");
    XCTAssertEqualObjects(items[1].url, @"https://zzz.com");

    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

- (void)testInspector_firedBeacons_emptyBeaconsAndTrackers_returnsEmptyArray {
    HyBidReportingManager *mgr = [HyBidReportingManager sharedInstance];
    NSArray *originalBeacons = [mgr.beacons copy];
    NSArray *originalTrackers = [mgr.vastTrackers copy];

    mgr.beacons = [@[] mutableCopy];
    mgr.vastTrackers = [@[] mutableCopy];

    NSArray<HyBidBeaconItem *> *items = [[HyBidBeaconsInspector shared] firedBeacons];
    XCTAssertNotNil(items);
    XCTAssertEqual(items.count, 0);

    mgr.beacons = [originalBeacons mutableCopy];
    mgr.vastTrackers = [originalTrackers mutableCopy];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspector adBeaconsFromLastResponse
// ============================================================================

- (void)testInspector_adBeaconsFromLastResponse_callsCompletionWithArray {
    XCTestExpectation *exp = [self expectationWithDescription:@"completion called"];
    [[HyBidBeaconsInspector shared] adBeaconsFromLastResponseWithCompletion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertNotNil(items);
        XCTAssertTrue([items isKindOfClass:[NSArray class]]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testInspector_adBeaconsFromLastResponse_completionCalledOnMainThread {
    XCTestExpectation *exp = [self expectationWithDescription:@"completion on main"];
    [[HyBidBeaconsInspector shared] adBeaconsFromLastResponseWithCompletion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertTrue([NSThread isMainThread], @"Completion should be called on main thread");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testInspector_adBeaconsFromLastResponse_mapsDictionaryToBeaconItems {
    XCTestExpectation *exp = [self expectationWithDescription:@"mapping"];
    [[HyBidBeaconsInspector shared] adBeaconsFromLastResponseWithCompletion:^(NSArray<HyBidBeaconItem *> *items) {
        for (HyBidBeaconItem *item in items) {
            XCTAssertTrue([item isKindOfClass:[HyBidBeaconItem class]]);
            XCTAssertNotNil(item.type);
        }
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspector adBeaconsFromResponse
// ============================================================================

- (void)testInspector_adBeaconsFromResponse_withNil_returnsEmptyArray {
    XCTestExpectation *exp = [self expectationWithDescription:@"empty from nil"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:nil completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertNotNil(items);
        XCTAssertEqual(items.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testInspector_adBeaconsFromResponse_withEmptyString_returnsEmptyArray {
    XCTestExpectation *exp = [self expectationWithDescription:@"empty from empty"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:@"" completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertNotNil(items);
        XCTAssertEqual(items.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testInspector_adBeaconsFromResponse_withAdResponseTxt_returnsMappedItems {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);
    NSString *responseString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(responseString);
    XCTestExpectation *exp = [self expectationWithDescription:@"items from adResponse.txt"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:responseString completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertNotNil(items);
        XCTAssertGreaterThanOrEqual(items.count, 2, @"Should have ad beacons plus VAST trackers (sorted by type)");
        BOOL hasImpression = NO;
        for (HyBidBeaconItem *item in items) {
            if ([item.type isEqualToString:@"Impression"]) { hasImpression = YES; }
        }
        XCTAssertTrue(hasImpression, @"Should contain at least one Impression beacon from adResponse.txt");
        HyBidBeaconItem *first = items.firstObject;
        XCTAssertNotNil(first.type, @"Each mapped item should have a type");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testInspector_adBeaconsFromResponse_completionOnMainThread {
    XCTestExpectation *exp = [self expectationWithDescription:@"main thread"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:@"{}" completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertTrue([NSThread isMainThread]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testInspector_adBeaconsFromResponse_withJSONBeaconsOnly_mapsCorrectly {
    // JSON with beacons but no VAST data
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"impression\",\"data\":{\"url\":\"https://imp.test\"}},{\"type\":\"click\",\"data\":{\"js\":\"clickJs();\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"beacons only"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:json completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertNotNil(items);
        XCTAssertEqual(items.count, 2);
        // Sorted: Click < Impression
        XCTAssertEqualObjects(items[0].type, @"Click");
        XCTAssertEqualObjects(items[1].type, @"Impression");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (nil completion guard)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromLastResponseWithCompletion_callsCompletion {
    XCTestExpectation *exp = [self expectationWithDescription:@"helper completion"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromLastResponseWithCompletion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertTrue([dicts isKindOfClass:[NSArray class]]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromLastResponseWithNilCompletion_doesNotCrash {
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromLastResponseWithCompletion:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (nil / empty responses)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withNil_returnsEmptyArray {
    XCTestExpectation *exp = [self expectationWithDescription:@"completion with empty"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:nil completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withEmptyString_returnsEmptyArray {
    XCTestExpectation *exp = [self expectationWithDescription:@"completion with empty"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:@"" completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withNilCompletion_doesNotCrash {
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:@"{}" completion:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withNil_completionOnMainThread {
    XCTestExpectation *exp = [self expectationWithDescription:@"main thread"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:nil completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertTrue([NSThread isMainThread]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (JSON dict path: beacons extraction)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withEmptyAds_returnsEmptyArray {
    NSString *json = @"{\"ads\":[]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"empty ads"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withEmptyDictJSON_returnsEmptyArray {
    NSString *json = @"{}";
    XCTestExpectation *exp = [self expectationWithDescription:@"empty dict"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withBeaconsNoVAST_returnsBeacons {
    // JSON with beacons but no VAST asset
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"impression\",\"data\":{\"url\":\"https://imp.test\"}},{\"type\":\"click\",\"data\":{\"js\":\"clickJs();\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"beacons no VAST"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 2);
        // Types should be capitalized first letter: impression -> Impression, click -> Click
        BOOL hasImpression = NO, hasClick = NO;
        for (NSDictionary *d in dicts) {
            if ([d[@"type"] isEqualToString:@"Impression"]) hasImpression = YES;
            if ([d[@"type"] isEqualToString:@"Click"]) hasClick = YES;
        }
        XCTAssertTrue(hasImpression);
        XCTAssertTrue(hasClick);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_beaconTypeCapitalization {
    // Verify the first letter capitalization logic
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"customEvent\",\"data\":{\"url\":\"https://test.com\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"capitalization"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertEqual(dicts.count, 1);
        XCTAssertEqualObjects(dicts[0][@"type"], @"CustomEvent");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_beaconWithEmptyType_returnsEmptyTypeString {
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"\",\"data\":{\"url\":\"https://t.com\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"empty type"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertEqual(dicts.count, 1);
        XCTAssertEqualObjects(dicts[0][@"type"], @"");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_beaconWithNullUrl_hasNSNull {
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"impression\",\"data\":{}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"null url"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertEqual(dicts.count, 1);
        XCTAssertEqualObjects(dicts[0][@"url"], [NSNull null]);
        XCTAssertEqualObjects(dicts[0][@"js"], [NSNull null]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_beaconWithNoBeacons_returnsEmpty {
    NSString *json = @"{\"ads\":[{\"beacons\":[],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"no beacons"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_sortsByTypeThenContent {
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"impression\",\"data\":{\"url\":\"https://zzz.com\"}},{\"type\":\"click\",\"data\":{\"url\":\"https://aaa.com\"}},{\"type\":\"impression\",\"data\":{\"url\":\"https://aaa.com\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"sorted"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertEqual(dicts.count, 3);
        // Sorted: Click (aaa) < Impression (aaa) < Impression (zzz)
        XCTAssertEqualObjects(dicts[0][@"type"], @"Click");
        XCTAssertEqualObjects(dicts[1][@"type"], @"Impression");
        XCTAssertEqualObjects(dicts[1][@"url"], @"https://aaa.com");
        XCTAssertEqualObjects(dicts[2][@"type"], @"Impression");
        XCTAssertEqualObjects(dicts[2][@"url"], @"https://zzz.com");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_beaconWithJsOnly {
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"custom\",\"data\":{\"js\":\"track();\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"js only"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertEqual(dicts.count, 1);
        XCTAssertEqualObjects(dicts[0][@"js"], @"track();");
        XCTAssertEqualObjects(dicts[0][@"url"], [NSNull null]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (JSON non-dict → VAST fallback)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withJSONArray_treatedAsVAST {
    // A JSON array is valid JSON but not a dict → goes to VAST path
    NSString *json = @"[1, 2, 3]";
    XCTestExpectation *exp = [self expectationWithDescription:@"json array"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        // Not valid VAST, should return empty
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withInvalidJSON_returnsEmptyArray {
    XCTestExpectation *exp = [self expectationWithDescription:@"invalid JSON"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:@"not json" completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (VAST string path)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withVASTInlineXML_extractsTrackingEvents {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *vastPath = [bundle pathForResource:@"vast_linear" ofType:@"xml" inDirectory:@"VAST Parser"];
    if (!vastPath) {
        // Try without subdirectory (depends on how resources are bundled)
        vastPath = [bundle pathForResource:@"vast_linear" ofType:@"xml"];
    }
    if (!vastPath) { return; } // Skip if resource not found
    NSString *vastString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:vastPath] encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(vastString);

    XCTestExpectation *exp = [self expectationWithDescription:@"VAST inline"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:vastString completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        // vast_linear.xml has Impression, tracking events (start, firstQuartile, midpoint, thirdQuartile, complete), ClickTracking, and CompanionClickThrough
        XCTAssertGreaterThan(dicts.count, 0, @"Should extract beacons from VAST inline XML");
        BOOL hasImpression = NO;
        BOOL hasClickTracking = NO;
        for (NSDictionary *d in dicts) {
            XCTAssertNotNil(d[@"type"]);
            if ([d[@"type"] isEqualToString:@"Impression"]) hasImpression = YES;
            if ([d[@"type"] isEqualToString:@"ClickTracking"]) hasClickTracking = YES;
        }
        XCTAssertTrue(hasImpression, @"VAST inline should have Impression");
        XCTAssertTrue(hasClickTracking, @"VAST inline should have ClickTracking");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withVASTWrapperXML_extractsTrackingEvents {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *vastPath = [bundle pathForResource:@"vast_wrapper" ofType:@"xml" inDirectory:@"VAST Parser"];
    if (!vastPath) {
        vastPath = [bundle pathForResource:@"vast_wrapper" ofType:@"xml"];
    }
    if (!vastPath) { return; }
    NSString *vastString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:vastPath] encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(vastString);

    // Replace the external VASTAdTagURI with the local bundle fixture so this
    // test is network-independent and reliable on CI.
    NSString *inlinePath = [bundle pathForResource:@"vast_wrapper_inline" ofType:@"xml"];
    if (!inlinePath) {
        inlinePath = [bundle pathForResource:@"vast_wrapper_inline" ofType:@"xml" inDirectory:@"VAST Parser"];
    }
    if (inlinePath) {
        NSURL *inlineFileURL = [NSURL fileURLWithPath:inlinePath];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<VASTAdTagURI><!\\[CDATA\\[).*?(?=\\]\\]></VASTAdTagURI>)"
                                                                               options:NSRegularExpressionDotMatchesLineSeparators
                                                                                 error:nil];
        vastString = [regex stringByReplacingMatchesInString:vastString
                                                     options:0
                                                       range:NSMakeRange(0, vastString.length)
                                                withTemplate:inlineFileURL.absoluteString];
    }

    XCTestExpectation *exp = [self expectationWithDescription:@"VAST wrapper"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:vastString completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertGreaterThan(dicts.count, 0, @"Should extract beacons from VAST wrapper XML");
        BOOL hasStart = NO;
        BOOL hasClickTracking = NO;
        for (NSDictionary *d in dicts) {
            if ([d[@"type"] isEqualToString:@"Start"]) hasStart = YES;
            if ([d[@"type"] isEqualToString:@"ClickTracking"]) hasClickTracking = YES;
        }
        XCTAssertTrue(hasStart, @"VAST wrapper should have start tracking event");
        XCTAssertTrue(hasClickTracking, @"VAST wrapper should have ClickTracking");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withMinimalVAST_extractsImpression {
    NSString *vast = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                     @"<VAST version=\"2.0\">"
                     @"  <Ad id=\"test\">"
                     @"    <InLine>"
                     @"      <AdSystem>Test</AdSystem>"
                     @"      <Impression><![CDATA[https://impression.test]]></Impression>"
                     @"      <Creatives>"
                     @"        <Creative>"
                     @"          <Linear>"
                     @"            <Duration>00:00:15</Duration>"
                     @"            <MediaFiles></MediaFiles>"
                     @"            <TrackingEvents>"
                     @"              <Tracking event=\"start\"><![CDATA[https://start.test]]></Tracking>"
                     @"              <Tracking event=\"complete\"><![CDATA[https://complete.test]]></Tracking>"
                     @"            </TrackingEvents>"
                     @"            <VideoClicks>"
                     @"              <ClickTracking><![CDATA[https://click.test]]></ClickTracking>"
                     @"            </VideoClicks>"
                     @"          </Linear>"
                     @"        </Creative>"
                     @"      </Creatives>"
                     @"    </InLine>"
                     @"  </Ad>"
                     @"</VAST>";

    XCTestExpectation *exp = [self expectationWithDescription:@"minimal VAST"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:vast completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertGreaterThan(dicts.count, 0);
        BOOL hasImpression = NO, hasStart = NO, hasComplete = NO, hasClick = NO;
        for (NSDictionary *d in dicts) {
            NSString *type = d[@"type"];
            if ([type isEqualToString:@"Impression"]) hasImpression = YES;
            if ([type isEqualToString:@"Start"]) hasStart = YES;
            if ([type isEqualToString:@"Complete"]) hasComplete = YES;
            if ([type isEqualToString:@"ClickTracking"]) hasClick = YES;
        }
        XCTAssertTrue(hasImpression, @"Should have Impression");
        XCTAssertTrue(hasStart, @"Should have start");
        XCTAssertTrue(hasComplete, @"Should have complete");
        XCTAssertTrue(hasClick, @"Should have ClickTracking");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withVASTWrapper_extractsWrapperImpressions {
    NSString *vast = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                     @"<VAST version=\"3.0\">"
                     @"  <Ad id=\"wrapper-test\">"
                     @"    <Wrapper>"
                     @"      <AdSystem>TestWrapper</AdSystem>"
                     @"      <VASTAdTagURI><![CDATA[https://example.com/vast.xml]]></VASTAdTagURI>"
                     @"      <Impression><![CDATA[https://wrapper-impression.test]]></Impression>"
                     @"      <Creatives>"
                     @"        <Creative>"
                     @"          <Linear>"
                     @"            <TrackingEvents>"
                     @"              <Tracking event=\"start\"><![CDATA[https://wrapper-start.test]]></Tracking>"
                     @"            </TrackingEvents>"
                     @"            <VideoClicks>"
                     @"              <ClickTracking><![CDATA[https://wrapper-click.test]]></ClickTracking>"
                     @"            </VideoClicks>"
                     @"          </Linear>"
                     @"        </Creative>"
                     @"      </Creatives>"
                     @"    </Wrapper>"
                     @"  </Ad>"
                     @"</VAST>";

    XCTestExpectation *exp = [self expectationWithDescription:@"VAST wrapper impressions"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:vast completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertGreaterThan(dicts.count, 0);
        BOOL hasImpression = NO, hasStart = NO, hasClick = NO;
        for (NSDictionary *d in dicts) {
            NSString *type = d[@"type"];
            if ([type isEqualToString:@"Impression"]) hasImpression = YES;
            if ([type isEqualToString:@"Start"]) hasStart = YES;
            if ([type isEqualToString:@"ClickTracking"]) hasClick = YES;
        }
        XCTAssertTrue(hasImpression, @"Should have wrapper Impression");
        XCTAssertTrue(hasStart, @"Should have wrapper start tracking");
        XCTAssertTrue(hasClick, @"Should have wrapper ClickTracking");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withVASTCompanionClickThrough {
    NSString *vast = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                     @"<VAST version=\"2.0\">"
                     @"  <Ad id=\"comp-test\">"
                     @"    <InLine>"
                     @"      <AdSystem>Test</AdSystem>"
                     @"      <Impression><![CDATA[https://imp.test]]></Impression>"
                     @"      <Creatives>"
                     @"        <Creative>"
                     @"          <Linear>"
                     @"            <Duration>00:00:10</Duration>"
                     @"            <MediaFiles></MediaFiles>"
                     @"            <TrackingEvents></TrackingEvents>"
                     @"          </Linear>"
                     @"          <CompanionAds>"
                     @"            <Companion width=\"320\" height=\"480\">"
                     @"              <CompanionClickThrough><![CDATA[https://companion-click.test]]></CompanionClickThrough>"
                     @"              <TrackingEvents>"
                     @"                <Tracking event=\"creativeView\"><![CDATA[https://companion-view.test]]></Tracking>"
                     @"              </TrackingEvents>"
                     @"            </Companion>"
                     @"          </CompanionAds>"
                     @"        </Creative>"
                     @"      </Creatives>"
                     @"    </InLine>"
                     @"  </Ad>"
                     @"</VAST>";

    XCTestExpectation *exp = [self expectationWithDescription:@"companion click through"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:vast completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        BOOL hasCompanionClickThrough = NO;
        for (NSDictionary *d in dicts) {
            if ([d[@"type"] isEqualToString:@"CompanionClickThrough"]) {
                hasCompanionClickThrough = YES;
                XCTAssertEqualObjects(d[@"url"], @"https://companion-click.test");
            }
        }
        XCTAssertTrue(hasCompanionClickThrough, @"Should have CompanionClickThrough");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withEmptyVASTTag_returnsEmpty {
    NSString *vast = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><VAST version=\"2.0\"></VAST>";
    XCTestExpectation *exp = [self expectationWithDescription:@"empty VAST"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:vast completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (JSON with embedded VAST)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withAdResponseTxt_returnsSortedBeaconDictionaries {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);
    NSString *responseString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(responseString);
    XCTestExpectation *exp = [self expectationWithDescription:@"beacons from adResponse.txt"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:responseString completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertGreaterThanOrEqual(dicts.count, 2, @"Should have at least the 2 beacons from first ad plus VAST trackers");
        BOOL hasImpression = NO;
        for (NSDictionary *d in dicts) {
            XCTAssertNotNil(d[@"type"]);
            if ([d[@"type"] isEqualToString:@"Impression"]) { hasImpression = YES; }
            id url = d[@"url"];
            XCTAssertTrue(url == [NSNull null] || ([url isKindOfClass:[NSString class]] && [(NSString *)url length] > 0) || ([d[@"js"] isKindOfClass:[NSString class]] && [(NSString *)d[@"js"] length] > 0));
        }
        XCTAssertTrue(hasImpression, @"Should contain at least one Impression beacon from adResponse.txt");

        // Verify sorting: types should be in alphabetical order
        for (NSUInteger i = 1; i < dicts.count; i++) {
            NSString *prevType = dicts[i-1][@"type"];
            NSString *currType = dicts[i][@"type"];
            NSComparisonResult cmp = [prevType compare:currType];
            XCTAssertTrue(cmp == NSOrderedAscending || cmp == NSOrderedSame,
                          @"Beacons should be sorted by type: %@ should come before or equal %@", prevType, currType);
        }

        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withAdResponseTxt_completionCalledOnMainThread {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);
    NSString *responseString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];

    XCTestExpectation *exp = [self expectationWithDescription:@"main thread"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:responseString completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertTrue([NSThread isMainThread], @"Completion should be called on main thread");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withAdResponseTxt_containsVASTTrackers {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);
    NSString *responseString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];

    XCTestExpectation *exp = [self expectationWithDescription:@"VAST trackers"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:responseString completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        // adResponse.txt has embedded VAST, so we should see VAST tracking events too
        BOOL hasVASTEvent = NO;
        for (NSDictionary *d in dicts) {
            NSString *type = d[@"type"];
            if ([type isEqualToString:@"Start"] ||
                [type isEqualToString:@"FirstQuartile"] ||
                [type isEqualToString:@"Midpoint"] ||
                [type isEqualToString:@"ThirdQuartile"] ||
                [type isEqualToString:@"Complete"] ||
                [type isEqualToString:@"ClickTracking"]) {
                hasVASTEvent = YES;
                break;
            }
        }
        XCTAssertTrue(hasVASTEvent, @"Should contain VAST tracking events from embedded VAST XML");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (JSON with beacons + embedded VAST with companion)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withJSONContainingVASTAndCompanion {
    // Build a JSON with an embedded VAST that has companion ads
    NSString *vastContent = @"<VAST version=\\\"2.0\\\"><Ad id=\\\"t\\\"><InLine><AdSystem>T</AdSystem>"
                            @"<Impression><![CDATA[https://imp.vast]]></Impression>"
                            @"<Creatives><Creative><Linear><Duration>00:00:10</Duration><MediaFiles></MediaFiles>"
                            @"<TrackingEvents><Tracking event=\\\"start\\\"><![CDATA[https://start.vast]]></Tracking></TrackingEvents>"
                            @"<VideoClicks><ClickTracking><![CDATA[https://click.vast]]></ClickTracking></VideoClicks>"
                            @"</Linear><CompanionAds><Companion width=\\\"320\\\" height=\\\"480\\\">"
                            @"<CompanionClickThrough><![CDATA[https://comp-click.vast]]></CompanionClickThrough>"
                            @"<TrackingEvents><Tracking event=\\\"creativeView\\\"><![CDATA[https://comp-view.vast]]></Tracking></TrackingEvents>"
                            @"</Companion></CompanionAds></Creative></Creatives></InLine></Ad></VAST>";

    NSString *json = [NSString stringWithFormat:
        @"{\"ads\":[{\"assetgroupid\":15,\"beacons\":[{\"type\":\"impression\",\"data\":{\"url\":\"https://json-beacon.test\"}}],"
        @"\"assets\":[{\"type\":\"vast2\",\"data\":{\"vast2\":\"%@\"}}]}]}", vastContent];

    XCTestExpectation *exp = [self expectationWithDescription:@"JSON+VAST+companion"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertGreaterThan(dicts.count, 1, @"Should have JSON beacons + VAST beacons");

        BOOL hasJsonBeacon = NO, hasVASTImpression = NO, hasVASTStart = NO, hasVASTClick = NO;
        for (NSDictionary *d in dicts) {
            NSString *type = d[@"type"];
            NSString *url = [d[@"url"] isKindOfClass:[NSString class]] ? d[@"url"] : nil;
            if ([type isEqualToString:@"Impression"] && [url isEqualToString:@"https://json-beacon.test"]) hasJsonBeacon = YES;
            if ([type isEqualToString:@"Impression"] && [url isEqualToString:@"https://imp.vast"]) hasVASTImpression = YES;
            if ([type isEqualToString:@"Start"]) hasVASTStart = YES;
            if ([type isEqualToString:@"ClickTracking"]) hasVASTClick = YES;
        }
        XCTAssertTrue(hasJsonBeacon, @"Should have JSON beacon");
        XCTAssertTrue(hasVASTStart, @"Should have VAST start event");
        XCTAssertTrue(hasVASTClick, @"Should have VAST ClickTracking");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (VAST with multiple impressions)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withMultipleImpressions {
    NSString *vast = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                     @"<VAST version=\"2.0\">"
                     @"  <Ad id=\"multi-imp\">"
                     @"    <InLine>"
                     @"      <AdSystem>Test</AdSystem>"
                     @"      <Impression><![CDATA[https://imp1.test]]></Impression>"
                     @"      <Impression><![CDATA[https://imp2.test]]></Impression>"
                     @"      <Creatives></Creatives>"
                     @"    </InLine>"
                     @"  </Ad>"
                     @"</VAST>";

    XCTestExpectation *exp = [self expectationWithDescription:@"multiple impressions"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:vast completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        NSUInteger impressionCount = 0;
        for (NSDictionary *d in dicts) {
            if ([d[@"type"] isEqualToString:@"Impression"]) impressionCount++;
        }
        XCTAssertEqual(impressionCount, 2, @"Should have 2 Impression entries");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

// ============================================================================
#pragma mark - HyBidBeaconsInspectorHelper (edge cases)
// ============================================================================

- (void)testHelper_adBeaconDictionariesFromResponse_withMalformedXML_doesNotCrash {
    NSString *malformed = @"<VAST version=\"2.0\"><Ad><InLine><broken>";
    XCTestExpectation *exp = [self expectationWithDescription:@"malformed XML"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:malformed completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withEmptyDictCompletion_onMainThread {
    XCTestExpectation *exp = [self expectationWithDescription:@"empty dict main thread"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:@"{}" completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertNotNil(dicts);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withSingleCharType_capitalizes {
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"a\",\"data\":{\"url\":\"https://t.com\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"single char"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertEqual(dicts.count, 1);
        XCTAssertEqualObjects(dicts[0][@"type"], @"A");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withAdModelNoBeaconsNoAssets {
    // Ad with empty beacons and assets → goes through adModel path but produces nothing
    NSString *json = @"{\"ads\":[{}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"no beacons no assets"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 0);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withAssetButNoVast2Key {
    // Ad has asset but no vast2 key → should skip VAST parsing
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"impression\",\"data\":{\"url\":\"https://b.com\"}}],\"assets\":[{\"type\":\"htmlData\",\"data\":{\"html\":\"<div>ad</div>\"}}]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"no vast2 key"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertNotNil(dicts);
        XCTAssertEqual(dicts.count, 1);
        XCTAssertEqualObjects(dicts[0][@"type"], @"Impression");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHelper_adBeaconDictionariesFromResponse_withMultipleBeaconsAndUrlJs_handlesNSNull {
    NSString *json = @"{\"ads\":[{\"beacons\":["
                     @"{\"type\":\"impression\",\"data\":{\"url\":\"https://u.com\"}},"
                     @"{\"type\":\"click\",\"data\":{\"js\":\"c();\"}},"
                     @"{\"type\":\"custom\",\"data\":{}}"
                     @"],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"multiple with NSNull"];
    [HyBidBeaconsInspectorHelper adBeaconDictionariesFromResponse:json completion:^(NSArray<NSDictionary<NSString *, id> *> *dicts) {
        XCTAssertEqual(dicts.count, 3);
        // Check that all entries have type, url, and js keys
        for (NSDictionary *d in dicts) {
            XCTAssertNotNil(d[@"type"]);
            XCTAssertNotNil(d[@"url"]);  // Should be NSNull or String
            XCTAssertNotNil(d[@"js"]);   // Should be NSNull or String
        }
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// ============================================================================
#pragma mark - adResponse.txt (test bundle mock data)
// ============================================================================

- (void)testAdResponseTxt_containsBeaconsStructureForInspector {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path, @"adResponse.txt should be in test bundle");
    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data);
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([json isKindOfClass:[NSDictionary class]]);
    NSArray *ads = [(NSDictionary *)json objectForKey:@"ads"];
    XCTAssertNotNil(ads);
    XCTAssertTrue(ads.count > 0);
    NSDictionary *firstAd = ads.firstObject;
    NSArray *beacons = firstAd[@"beacons"];
    XCTAssertNotNil(beacons, @"First ad in adResponse.txt should have beacons array for beacon inspector tests");
    if (beacons.count > 0) {
        NSDictionary *firstBeacon = beacons.firstObject;
        XCTAssertNotNil(firstBeacon[@"type"]);
        id dataObj = firstBeacon[@"data"];
        XCTAssertTrue(dataObj == nil || [dataObj isKindOfClass:[NSDictionary class]], @"Beacon data should be a dictionary with url/js");
    }
}

- (void)testAdResponseTxt_containsVAST2Asset {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);
    NSData *data = [NSData dataWithContentsOfFile:path];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *ads = [(NSDictionary *)json objectForKey:@"ads"];
    NSDictionary *firstAd = ads.firstObject;
    NSArray *assets = firstAd[@"assets"];
    XCTAssertNotNil(assets);
    XCTAssertTrue(assets.count > 0);
    NSDictionary *firstAsset = assets.firstObject;
    XCTAssertEqualObjects(firstAsset[@"type"], @"vast2");
    NSDictionary *assetData = firstAsset[@"data"];
    XCTAssertNotNil(assetData[@"vast2"], @"Should have vast2 key in asset data");
}

// ============================================================================
#pragma mark - HyBidBeaconsInspector (VAST content tracking)
// ============================================================================

- (void)testInspector_adBeaconsFromResponse_withVAST_allItemsAreBeaconItems {
    NSString *vast = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                     @"<VAST version=\"2.0\">"
                     @"  <Ad id=\"test\">"
                     @"    <InLine>"
                     @"      <AdSystem>Test</AdSystem>"
                     @"      <Impression><![CDATA[https://imp.test]]></Impression>"
                     @"      <Creatives>"
                     @"        <Creative>"
                     @"          <Linear>"
                     @"            <Duration>00:00:10</Duration>"
                     @"            <MediaFiles></MediaFiles>"
                     @"            <TrackingEvents>"
                     @"              <Tracking event=\"start\"><![CDATA[https://start.test]]></Tracking>"
                     @"            </TrackingEvents>"
                     @"          </Linear>"
                     @"        </Creative>"
                     @"      </Creatives>"
                     @"    </InLine>"
                     @"  </Ad>"
                     @"</VAST>";

    XCTestExpectation *exp = [self expectationWithDescription:@"all beacon items"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:vast completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertNotNil(items);
        for (HyBidBeaconItem *item in items) {
            XCTAssertTrue([item isKindOfClass:[HyBidBeaconItem class]]);
            XCTAssertNotNil(item.type);
            XCTAssertTrue(item.type.length > 0);
        }
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testInspector_adBeaconsFromResponse_withInvalidJSON_doesNotCrash {
    XCTestExpectation *exp = [self expectationWithDescription:@"invalid json"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:@"{{invalid}}" completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertNotNil(items);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testInspector_adBeaconsFromResponse_withJSONBeacons_itemsHaveCorrectProperties {
    NSString *json = @"{\"ads\":[{\"beacons\":[{\"type\":\"impression\",\"data\":{\"url\":\"https://test.imp\"}}],\"assets\":[]}]}";
    XCTestExpectation *exp = [self expectationWithDescription:@"correct properties"];
    [[HyBidBeaconsInspector shared] adBeaconsFromResponse:json completion:^(NSArray<HyBidBeaconItem *> *items) {
        XCTAssertEqual(items.count, 1);
        HyBidBeaconItem *item = items.firstObject;
        XCTAssertEqualObjects(item.type, @"Impression");
        XCTAssertEqualObjects(item.url, @"https://test.imp");
        XCTAssertEqualObjects(item.content, @"https://test.imp");
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
