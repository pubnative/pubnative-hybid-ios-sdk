// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import "HyBidAdTrackerRequest.h"
#import "HyBidAdTracker.h"
#import "PNLiteHttpRequest.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface HyBidAdTrackerRequest()

@property (nonatomic, weak) NSObject <HyBidAdTrackerRequestDelegate> *delegate;
- (void)invokeDidStart;
- (void)invokeDidLoad;
- (void)invokeDidFail:(NSError *)error;
- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error;
@end

@interface HyBidAdTracker ()
@property (nonatomic, assign) BOOL automaticClickTracked;
@property (nonatomic, assign) BOOL automaticCustomEndCardClickTracked;
@property (nonatomic, assign) BOOL automaticDefaultEndCardClickTracked;
- (instancetype)initWithAdTrackerRequest:(HyBidAdTrackerRequest *)adTrackerRequest
                      withImpressionURLs:(NSArray *)impressionURLs
         withCustomEndcardImpressionURLs:(NSArray *)customEndcardImpressionURLs
                           withClickURLs:(NSArray *)clickURLs
              withCustomEndcardClickURLs:(NSArray *)customEndcardClickURLs
                   withCustomCTATracking:(HyBidCustomCTATracking *)customCTATracking;
@end

@interface HyBidAdTrackerRequestTest : XCTestCase

@end

@implementation HyBidAdTrackerRequestTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_trackAdWithDelegate_withNilDelegateAndWithValidUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    [request trackAdWithDelegate:nil withURL:@"validURL" withTrackingType:request.trackingType];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithNilUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject <HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:nil withTrackingType:request.trackingType];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithEmptyUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject <HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:@"" withTrackingType:request.trackingType];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithValidUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject <HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:@"validURL" withTrackingType:request.trackingType];
}

- (void)test_invokeDidStart_withNilListener_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    request.delegate = nil;
    [request invokeDidStart];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidStart_withValidListener_shouldCallback
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    [request invokeDidStart];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) requestDidStart:request];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidLoad_withNilListener_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    request.delegate = nil;
    [request invokeDidStart];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidLoad_withValidListener_shouldCallback
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    [request invokeDidLoad];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) requestDidFinish:request];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidFail_withNilListener_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    request.delegate = nil;
    NSError *error = mock([NSError class]);
    [request invokeDidFail:error];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidFail_withValidListener_shouldCallback
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    NSError *error = mock([NSError class]);
    [request invokeDidFail:error];

    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) request:request didFailWithError:error];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

#pragma mark - HyBidAdTracker helpers

- (HyBidAdTracker *)makeTracker
{
    HyBidAdTrackerRequest *mockRequest = mock([HyBidAdTrackerRequest class]);
    return [[HyBidAdTracker alloc] initWithAdTrackerRequest:mockRequest
                                         withImpressionURLs:@[]
                                withCustomEndcardImpressionURLs:@[]
                                              withClickURLs:@[]
                                   withCustomEndcardClickURLs:@[]
                                        withCustomCTATracking:nil];
}

#pragma mark - trackStorekitAutomaticDefaultEndCardClickWithAdFormat (VMI-1534)

- (void)test_trackStorekitAutomaticDefaultEndCardClick_firstCall_setsFlag
{
    HyBidAdTracker *tracker = [self makeTracker];
    [tracker trackStorekitAutomaticDefaultEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticDefaultEndCardClickTracked);
}

- (void)test_trackStorekitAutomaticDefaultEndCardClick_secondCall_isIdempotent
{
    HyBidAdTracker *tracker = [self makeTracker];
    [tracker trackStorekitAutomaticDefaultEndCardClickWithAdFormat:@"fullscreen"];
    [tracker trackStorekitAutomaticDefaultEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticDefaultEndCardClickTracked);
}

- (void)test_trackStorekitAutomaticDefaultEndCardClick_afterAutomaticClickTracked_stillFiresEvent
{
    // VMI-1534: automaticClickTracked set by SKOverlay/video must not block the default endcard SDK event
    HyBidAdTracker *tracker = [self makeTracker];
    tracker.automaticClickTracked = YES;
    [tracker trackStorekitAutomaticDefaultEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticDefaultEndCardClickTracked);
}

- (void)test_trackStorekitAutomaticDefaultEndCardClick_doesNotOverrideAutomaticClickTracked
{
    // automaticClickTracked already YES — URL tracking skipped, flag stays YES
    HyBidAdTracker *tracker = [self makeTracker];
    tracker.automaticClickTracked = YES;
    [tracker trackStorekitAutomaticDefaultEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticClickTracked);
}

#pragma mark - trackSKOverlayAutomaticCustomEndCardClickWithAdFormat

- (void)test_trackSKOverlayAutomaticCustomEndCardClick_firstCall_setsBothFlags
{
    HyBidAdTracker *tracker = [self makeTracker];
    [tracker trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticClickTracked);
    XCTAssertTrue(tracker.automaticCustomEndCardClickTracked);
}

- (void)test_trackSKOverlayAutomaticCustomEndCardClick_secondCall_isIdempotent
{
    HyBidAdTracker *tracker = [self makeTracker];
    [tracker trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    [tracker trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticClickTracked);
    XCTAssertTrue(tracker.automaticCustomEndCardClickTracked);
}

- (void)test_trackSKOverlayAutomaticCustomEndCardClick_whenBothFlagsSet_returnsEarly
{
    HyBidAdTracker *tracker = [self makeTracker];
    tracker.automaticCustomEndCardClickTracked = YES;
    tracker.automaticClickTracked = YES;
    [tracker trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    // automaticDefaultEndCardClickTracked must remain unaffected
    XCTAssertFalse(tracker.automaticDefaultEndCardClickTracked);
}

#pragma mark - trackStorekitAutomaticCustomEndCardClickWithAdFormat

- (void)test_trackStorekitAutomaticCustomEndCardClick_firstCall_setsBothFlags
{
    HyBidAdTracker *tracker = [self makeTracker];
    [tracker trackStorekitAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticClickTracked);
    XCTAssertTrue(tracker.automaticCustomEndCardClickTracked);
}

- (void)test_trackStorekitAutomaticCustomEndCardClick_secondCall_isIdempotent
{
    HyBidAdTracker *tracker = [self makeTracker];
    [tracker trackStorekitAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    [tracker trackStorekitAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    XCTAssertTrue(tracker.automaticClickTracked);
    XCTAssertTrue(tracker.automaticCustomEndCardClickTracked);
}

- (void)test_trackStorekitAutomaticCustomEndCardClick_whenBothFlagsSet_returnsEarly
{
    HyBidAdTracker *tracker = [self makeTracker];
    tracker.automaticCustomEndCardClickTracked = YES;
    tracker.automaticClickTracked = YES;
    [tracker trackStorekitAutomaticCustomEndCardClickWithAdFormat:@"fullscreen"];
    // automaticDefaultEndCardClickTracked must remain unaffected
    XCTAssertFalse(tracker.automaticDefaultEndCardClickTracked);
}

#pragma mark - VMI-1548: invokeDidLoad URL capture

- (void)test_invokeDidLoad_preservesURLCapturedAtCallTime
{
    // invokeDidLoad must capture urlString before the async dispatch so that concurrent
    // requests using the same adTrackerRequest don't overwrite each other's URL.
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    request.urlString = @"url_original";
    request.trackingType = @"click";

    [request invokeDidLoad];
    // Overwrite synchronously — the dispatched block has not run yet (tests run on main thread)
    request.urlString = @"url_overwritten";
    request.trackingType = @"impression";

    XCTestExpectation *expectation = [self expectationWithDescription:@"url preserved in invokeDidLoad"];
    dispatch_async(dispatch_get_main_queue(), ^{
        // invokeDidLoad's block ran first (FIFO) and restored urlString to the captured value
        XCTAssertEqualObjects(request.urlString, @"url_original");
        XCTAssertEqualObjects(request.trackingType, @"click");
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidLoad_callsDelegateAfterRestoringURL
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    request.urlString = @"https://example.com/click";
    request.trackingType = @"click";

    [request invokeDidLoad];
    request.urlString = @"https://example.com/other";

    XCTestExpectation *expectation = [self expectationWithDescription:@"delegate called with captured url"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) requestDidFinish:request];
        XCTAssertEqualObjects(request.urlString, @"https://example.com/click");
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

#pragma mark - VMI-1548: invokeDidFail URL capture

- (void)test_invokeDidFail_preservesURLCapturedAtCallTime
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    request.urlString = @"url_original";
    request.trackingType = @"click";
    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"test error"}];

    [request invokeDidFail:error];
    // Overwrite synchronously before the dispatched block runs
    request.urlString = @"url_overwritten";
    request.trackingType = @"impression";

    XCTestExpectation *expectation = [self expectationWithDescription:@"url preserved in invokeDidFail"];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqualObjects(request.urlString, @"url_original");
        XCTAssertEqualObjects(request.trackingType, @"click");
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidFail_callsDelegateAfterRestoringURL
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    request.urlString = @"https://example.com/click";
    request.trackingType = @"click";
    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"test error"}];

    [request invokeDidFail:error];
    request.urlString = @"https://example.com/other";

    XCTestExpectation *expectation = [self expectationWithDescription:@"delegate called with captured url on fail"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) request:request didFailWithError:error];
        XCTAssertEqualObjects(request.urlString, @"https://example.com/click");
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

#pragma mark - VMI-1548: PNLiteHttpRequestDelegate request:didFailWithError: URL capture

- (void)test_httpRequestDidFail_capturesURLFromRequestArgumentNotSelf
{
    // The fix captures urlString/trackingType from the PNLiteHttpRequest argument, not from
    // self, so that a shared adTrackerRequest picks up the correct per-request URL.
    HyBidAdTrackerRequest *adTrackerRequest = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    adTrackerRequest.delegate = delegate;
    adTrackerRequest.urlString = @"self_url_should_not_be_used";
    adTrackerRequest.trackingType = @"impression";

    PNLiteHttpRequest *httpRequest = mock([PNLiteHttpRequest class]);
    [given([httpRequest urlString]) willReturn:@"request_url"];
    [given([httpRequest trackingType]) willReturn:@"click"];

    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"network fail"}];
    [adTrackerRequest request:httpRequest didFailWithError:error];

    XCTestExpectation *expectation = [self expectationWithDescription:@"url from http request"];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqualObjects(adTrackerRequest.urlString, @"request_url");
        XCTAssertEqualObjects(adTrackerRequest.trackingType, @"click");
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_httpRequestDidFail_callsDelegateWithURLFromRequest
{
    HyBidAdTrackerRequest *adTrackerRequest = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    adTrackerRequest.delegate = delegate;

    PNLiteHttpRequest *httpRequest = mock([PNLiteHttpRequest class]);
    [given([httpRequest urlString]) willReturn:@"https://example.com/click"];
    [given([httpRequest trackingType]) willReturn:@"click"];

    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"network fail"}];
    [adTrackerRequest request:httpRequest didFailWithError:error];

    XCTestExpectation *expectation = [self expectationWithDescription:@"delegate notified"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) request:adTrackerRequest didFailWithError:error];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_httpRequestDidFail_calledFromBackgroundThread_stillCallsDelegateOnMainThread
{
    HyBidAdTrackerRequest *adTrackerRequest = [[HyBidAdTrackerRequest alloc] init];

    __block BOOL calledOnMainThread = NO;
    XCTestExpectation *expectation = [self expectationWithDescription:@"delegate on main thread"];

    // Use a real delegate to capture the thread at callback time
    id<HyBidAdTrackerRequestDelegate> capturingDelegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    adTrackerRequest.delegate = capturingDelegate;

    PNLiteHttpRequest *httpRequest = mock([PNLiteHttpRequest class]);
    [given([httpRequest urlString]) willReturn:@"https://example.com/click"];
    [given([httpRequest trackingType]) willReturn:@"click"];

    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"network fail"}];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [adTrackerRequest request:httpRequest didFailWithError:error];
        // After the method dispatches to main, wait for that block then check
        dispatch_async(dispatch_get_main_queue(), ^{
            calledOnMainThread = [NSThread isMainThread];
            [verify(capturingDelegate) request:adTrackerRequest didFailWithError:error];
            XCTAssertTrue(calledOnMainThread);
            [expectation fulfill];
        });
    });

    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

#pragma mark - VMI-1548: HyBidAdTracker request:didFailWithError: beacon reporting

- (void)test_adTrackerRequestDidFail_withValidURLAndReportingEnabled_reportsBeacon
{
    // App Store-redirecting click URLs cause NSURLSession errors; the fix reports their
    // beacons in the didFail path so they appear in BeaconsController.
    [[HyBidReportingManager sharedInstance] clearBeacons];
    [HyBidSDKConfig sharedConfig].reporting = YES;

    HyBidAdTracker *tracker = [self makeTracker];
    HyBidAdTrackerRequest *mockRequest = mock([HyBidAdTrackerRequest class]);
    [given([mockRequest urlString]) willReturn:@"https://example.com/click"];
    [given([mockRequest trackingType]) willReturn:PNLiteAdTrackerClick];
    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"redirect error"}];

    [(id<HyBidAdTrackerRequestDelegate>)tracker request:mockRequest didFailWithError:error];

    NSPredicate *beaconAdded = [NSPredicate predicateWithBlock:^BOOL(id _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [HyBidReportingManager sharedInstance].beacons.count == 1;
    }];
    [self expectationForPredicate:beaconAdded evaluatedWithObject:nil handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];

    [[HyBidReportingManager sharedInstance] clearBeacons];
}

- (void)test_adTrackerRequestDidFail_withNilURL_doesNotReportBeacon
{
    [[HyBidReportingManager sharedInstance] clearBeacons];
    [HyBidSDKConfig sharedConfig].reporting = YES;

    HyBidAdTracker *tracker = [self makeTracker];
    HyBidAdTrackerRequest *mockRequest = mock([HyBidAdTrackerRequest class]);
    [given([mockRequest urlString]) willReturn:nil];
    [given([mockRequest trackingType]) willReturn:PNLiteAdTrackerClick];
    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"fail"}];

    [(id<HyBidAdTrackerRequestDelegate>)tracker request:mockRequest didFailWithError:error];

    XCTestExpectation *expectation = [self expectationWithDescription:@"no beacon for nil url"];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqual([HyBidReportingManager sharedInstance].beacons.count, 0U);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

    [[HyBidReportingManager sharedInstance] clearBeacons];
}

- (void)test_adTrackerRequestDidFail_withUnknownTrackingType_doesNotReportBeacon
{
    // beaconReportObjectWith: returns nil for unrecognised tracking types — no beacon should fire.
    [[HyBidReportingManager sharedInstance] clearBeacons];
    [HyBidSDKConfig sharedConfig].reporting = YES;

    HyBidAdTracker *tracker = [self makeTracker];
    HyBidAdTrackerRequest *mockRequest = mock([HyBidAdTrackerRequest class]);
    [given([mockRequest urlString]) willReturn:@"https://example.com/click"];
    [given([mockRequest trackingType]) willReturn:@"unknown_tracking_type"];
    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"fail"}];

    [(id<HyBidAdTrackerRequestDelegate>)tracker request:mockRequest didFailWithError:error];

    XCTestExpectation *expectation = [self expectationWithDescription:@"no beacon for unknown type"];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqual([HyBidReportingManager sharedInstance].beacons.count, 0U);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

    [[HyBidReportingManager sharedInstance] clearBeacons];
}

- (void)test_adTrackerRequestDidFail_withReportingDisabled_doesNotReportBeacon
{
    [[HyBidReportingManager sharedInstance] clearBeacons];
    [HyBidSDKConfig sharedConfig].reporting = NO;

    HyBidAdTracker *tracker = [self makeTracker];
    HyBidAdTrackerRequest *mockRequest = mock([HyBidAdTrackerRequest class]);
    [given([mockRequest urlString]) willReturn:@"https://example.com/click"];
    [given([mockRequest trackingType]) willReturn:PNLiteAdTrackerClick];
    NSError *error = [NSError errorWithDomain:@"test" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"fail"}];

    [(id<HyBidAdTrackerRequestDelegate>)tracker request:mockRequest didFailWithError:error];

    XCTestExpectation *expectation = [self expectationWithDescription:@"no beacon when reporting disabled"];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqual([HyBidReportingManager sharedInstance].beacons.count, 0U);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

    [[HyBidReportingManager sharedInstance] clearBeacons];
}

@end
