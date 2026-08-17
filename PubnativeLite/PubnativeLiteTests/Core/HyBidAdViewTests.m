//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidAdView.h"
#import "HyBidAdSize.h"
#import "HyBid.h"
#import "HyBidAdRequest.h"
#import "PNLiteResponseModel.h"

/// Mock delegate to capture load failure (exercises load path and internal cleanUp).
@interface MockHyBidAdViewDelegate : NSObject <HyBidAdViewDelegate>
@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, assign) BOOL willRefreshCalled;
@property (nonatomic, copy) void (^onWillRefresh)(void);
@end
@implementation MockHyBidAdViewDelegate
- (void)adViewDidLoad:(HyBidAdView *)adView {}
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error { self.lastError = error; }
- (void)adViewDidTrackImpression:(HyBidAdView *)adView {}
- (void)adViewDidTrackClick:(HyBidAdView *)adView {}
- (void)adViewWillRefresh:(HyBidAdView *)adView {
    self.willRefreshCalled = YES;
    if (self.onWillRefresh) { self.onWillRefresh(); }
}
@end

@interface HyBidAdView (TestCoverage)
- (void)signalDataDidFinishWithAd:(HyBidAd *)ad;
- (void)setupAutoRefreshTimerIfNeeded;
- (void)scheduleAutoRefreshTimerWithInitialInterval:(NSTimeInterval)initialInterval
                             deferWhileBackgrounded:(BOOL)deferWhileBackgrounded;
- (BOOL)isApplicationBackgrounded;
@property (nonatomic, assign) BOOL shouldRunAutoRefresh;
@property (nonatomic, assign) BOOL isObservingAppLifecycle;
@end

@interface BackgroundedHyBidAdView : HyBidAdView
@property (nonatomic, assign) BOOL pretendBackgrounded;
@end

@implementation BackgroundedHyBidAdView
- (BOOL)isApplicationBackgrounded { return self.pretendBackgrounded; }
@end

/// Unit tests for HyBidAdView to improve coverage on new code (e.g. init, cleanUp, load, refresh).
@interface HyBidAdViewTests : XCTestCase
@end

@implementation HyBidAdViewTests

- (void)testInitWithFrame_setsDefaults {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    XCTAssertNotNil(view);
    XCTAssertNotNil(view.adRequest);
    // HyBidAdSize.SIZE_320x50 creates a new instance each time; compare by value
    XCTAssertTrue([view.adSize isEqualTo:HyBidAdSize.SIZE_320x50]);
    XCTAssertTrue(view.autoShowOnLoad);
}

- (void)testInitWithSize_setsAdSize {
    HyBidAdSize *size = HyBidAdSize.SIZE_300x250;
    HyBidAdView *view = [[HyBidAdView alloc] initWithSize:size];
    XCTAssertNotNil(view);
    XCTAssertEqualObjects(view.adSize, size);
}

- (void)testIsAutoCacheOnLoad_whenAdRequestNil_returnsYes {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    view.adRequest = nil;
    XCTAssertTrue([view isAutoCacheOnLoad]);
}

- (void)testInitWithFrame_adIsNilInitially {
    // After init, ad is nil (cleanUp is private; we only assert public initial state)
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNil(view.ad);
}

- (void)testLoadWithZoneID_emptyZone_invokesDidFailWithError {
    // loadWithZoneID calls cleanUp internally then invokes delegate on invalid zone
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadWithZoneID:@"" andWithDelegate:delegate];
    // Should eventually get error (async in real flow; may be sync for invalid zone)
    XCTAssertNotNil(delegate.lastError);
}

- (void)testRefresh_afterLoadWithZoneID_doesNotCrash {
    // Refresh calls cleanUp internally; exercise the path by loading then refreshing
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadWithZoneID:@"test-zone" andWithDelegate:delegate];
    XCTAssertNoThrow([view refresh]);
}

- (void)testLoadWithZoneID_withPosition_andWithDelegate_emptyZone_invokesDidFailWithError {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadWithZoneID:@"" withPosition:BANNER_POSITION_TOP andWithDelegate:delegate];
    XCTAssertNotNil(delegate.lastError);
}

- (void)testLoadExchangeAdWithZoneID_andWithDelegate_emptyZone_invokesDidFailWithError {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadExchangeAdWithZoneID:@"" andWithDelegate:delegate];
    XCTAssertNotNil(delegate.lastError);
}

- (void)testPrepare_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view prepare]);
}

- (void)testPrepareCustomMarkupFrom_emptyMarkup_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    XCTAssertNoThrow([view prepareCustomMarkupFrom:@"" withPlacement:HyBidDemoAppPlacementBanner]);
}

- (void)testStopAutoRefresh_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view stopAutoRefresh]);
}

- (void)testStartTracking_stopTracking_doNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view startTracking]);
    XCTAssertNoThrow([view stopTracking]);
}

- (void)testSetOpenRTBAdTypeWithAdFormat_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdBanner]);
}

// MARK: - Ad session data coverage
- (void)testRequest_didLoadWithAd_setsAdSessionData {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    [view request:request didLoadWithAd:ad];
    XCTAssertNotNil(view.ad);
}

- (void)testSignalDataDidFinishWithAd_setsAdSessionData {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    [view signalDataDidFinishWithAd:ad];
    XCTAssertNotNil(view.ad);
}

// MARK: - Auto-refresh app lifecycle (VMI-1661)

/// Starts a running auto-refresh timer with the given interval WITHOUT issuing a network ad request.
/// When the timer fires, -refresh calls -adViewWillRefresh: (our observable signal) and then re-loads
/// with a nil zoneID, which fails fast without touching the network.
- (HyBidAdView *)adViewWithAutoRefreshInterval:(NSInteger)seconds delegate:(MockHyBidAdViewDelegate *)delegate {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    view.delegate = delegate;
    view.shouldRunAutoRefresh = YES;
    view.autoRefreshTimeInSeconds = seconds;
    [view setupAutoRefreshTimerIfNeeded];
    return view;
}

- (void)testAutoRefresh_firesWhenAppIsActive {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    HyBidAdView *view = [self adViewWithAutoRefreshInterval:1 delegate:delegate];

    XCTestExpectation *refreshed = [self expectationWithDescription:@"auto-refresh fires while active"];
    delegate.onWillRefresh = ^{ [refreshed fulfill]; };
    [self waitForExpectations:@[refreshed] timeout:3.0];
    XCTAssertTrue(delegate.willRefreshCalled);

    [view stopAutoRefresh];
}

/// Core fix: backgrounding must pause the auto-refresh timer, and foregrounding must resume it,
/// so returning to the foreground never triggers a forced refresh that restarts an in-progress video.
- (void)testAutoRefresh_pausesInBackground_andResumesInForeground {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    HyBidAdView *view = [self adViewWithAutoRefreshInterval:1 delegate:delegate];

    // App enters background: the timer must be paused and must NOT fire, even after its interval elapses.
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];

    XCTestExpectation *noRefreshWhileBackgrounded = [self expectationWithDescription:@"no refresh while backgrounded"];
    noRefreshWhileBackgrounded.inverted = YES;
    delegate.onWillRefresh = ^{ [noRefreshWhileBackgrounded fulfill]; };
    [self waitForExpectations:@[noRefreshWhileBackgrounded] timeout:2.0];
    XCTAssertFalse(delegate.willRefreshCalled, @"Auto-refresh must not fire while the app is backgrounded");

    // App returns to the foreground: the timer resumes (from the time that was left) and fires again.
    XCTestExpectation *refreshAfterForeground = [self expectationWithDescription:@"refresh resumes after foreground"];
    delegate.onWillRefresh = ^{ [refreshAfterForeground fulfill]; };
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    [self waitForExpectations:@[refreshAfterForeground] timeout:3.0];
    XCTAssertTrue(delegate.willRefreshCalled, @"Auto-refresh must resume after returning to the foreground");

    [view stopAutoRefresh];
}

/// After stopAutoRefresh the lifecycle observers are removed, so backgrounding/foregrounding is a no-op.
- (void)testAutoRefresh_afterStop_removesLifecycleObserversAndDoesNotResumeRefresh {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    HyBidAdView *view = [self adViewWithAutoRefreshInterval:1 delegate:delegate];
    XCTAssertTrue(view.isObservingAppLifecycle, @"Scheduling the timer must start lifecycle observation");

    [view stopAutoRefresh];
    XCTAssertFalse(view.isObservingAppLifecycle, @"stopAutoRefresh must remove the lifecycle observers");

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];

    XCTestExpectation *noRefresh = [self expectationWithDescription:@"no refresh after stop"];
    noRefresh.inverted = YES;
    delegate.onWillRefresh = ^{ [noRefresh fulfill]; };
    [self waitForExpectations:@[noRefresh] timeout:2.0];
    XCTAssertFalse(delegate.willRefreshCalled, @"No refresh should occur after auto-refresh has been stopped");
}

- (void)testAutoRefresh_startedWhileBackgrounded_defersUntilForeground {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    BackgroundedHyBidAdView *view = [[BackgroundedHyBidAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    view.pretendBackgrounded = YES;
    view.delegate = delegate;
    view.shouldRunAutoRefresh = YES;
    view.autoRefreshTimeInSeconds = 1;
    [view setupAutoRefreshTimerIfNeeded];

    XCTAssertTrue(view.isObservingAppLifecycle, @"Deferring must still observe lifecycle so it can resume");

    XCTestExpectation *noRefreshWhileBackgrounded = [self expectationWithDescription:@"no refresh while backgrounded"];
    noRefreshWhileBackgrounded.inverted = YES;
    delegate.onWillRefresh = ^{ [noRefreshWhileBackgrounded fulfill]; };
    [self waitForExpectations:@[noRefreshWhileBackgrounded] timeout:2.0];
    XCTAssertFalse(delegate.willRefreshCalled, @"A timer started while backgrounded must not fire");

    XCTestExpectation *refreshAfterForeground = [self expectationWithDescription:@"refresh once foregrounded"];
    delegate.onWillRefresh = ^{ [refreshAfterForeground fulfill]; };
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    [self waitForExpectations:@[refreshAfterForeground] timeout:3.0];
    XCTAssertTrue(delegate.willRefreshCalled, @"Auto-refresh must start once the app reaches the foreground");

    [view stopAutoRefresh];
}

- (void)testAutoRefresh_resumeSchedulesEvenWhileStateIsStillBackground {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    BackgroundedHyBidAdView *view = [[BackgroundedHyBidAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    view.delegate = delegate;
    view.shouldRunAutoRefresh = YES;
    view.autoRefreshTimeInSeconds = 1;
    [view setupAutoRefreshTimerIfNeeded];

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    view.pretendBackgrounded = YES;

    XCTestExpectation *refreshAfterForeground = [self expectationWithDescription:@"resume schedules from background state"];
    delegate.onWillRefresh = ^{ [refreshAfterForeground fulfill]; };
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    [self waitForExpectations:@[refreshAfterForeground] timeout:3.0];
    XCTAssertTrue(delegate.willRefreshCalled, @"Resume must not defer just because the state is still background");

    [view stopAutoRefresh];
}

- (void)testAutoRefresh_scheduleArrivingAfterStop_doesNotArmTimer {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    HyBidAdView *view = [self adViewWithAutoRefreshInterval:1 delegate:delegate];
    [view stopAutoRefresh];
    XCTAssertFalse(view.isObservingAppLifecycle);

    [view scheduleAutoRefreshTimerWithInitialInterval:1 deferWhileBackgrounded:YES];

    XCTAssertFalse(view.isObservingAppLifecycle, @"A schedule arriving after stop must not arm a timer");

    XCTestExpectation *noRefresh = [self expectationWithDescription:@"no refresh after stop wins the race"];
    noRefresh.inverted = YES;
    delegate.onWillRefresh = ^{ [noRefresh fulfill]; };
    [self waitForExpectations:@[noRefresh] timeout:2.0];
    XCTAssertFalse(delegate.willRefreshCalled, @"A stop before the schedule lands must cancel it");
}

- (void)testAutoRefresh_stopFromBackgroundThread_tearsDownWithoutRefreshing {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    HyBidAdView *view = [self adViewWithAutoRefreshInterval:1 delegate:delegate];

    XCTestExpectation *stopped = [self expectationWithDescription:@"stopAutoRefresh ran off the main thread"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        XCTAssertFalse([NSThread isMainThread]);
        [view stopAutoRefresh];
        [stopped fulfill];
    });
    [self waitForExpectations:@[stopped] timeout:2.0];

    XCTestExpectation *noRefresh = [self expectationWithDescription:@"no refresh after an off-main stop"];
    noRefresh.inverted = YES;
    delegate.onWillRefresh = ^{ [noRefresh fulfill]; };
    [self waitForExpectations:@[noRefresh] timeout:2.5];

    XCTAssertFalse(delegate.willRefreshCalled, @"An off-main stop must prevent any further refresh");
    XCTAssertFalse(view.isObservingAppLifecycle, @"An off-main stop must still remove the lifecycle observers");
}

- (void)testAutoRefresh_resumesWithRemainingTime_notFullInterval {
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    HyBidAdView *view = [self adViewWithAutoRefreshInterval:3 delegate:delegate];

    XCTestExpectation *partialElapse = [self expectationWithDescription:@"interval partially elapses, no refresh yet"];
    partialElapse.inverted = YES;
    delegate.onWillRefresh = ^{ [partialElapse fulfill]; };
    [self waitForExpectations:@[partialElapse] timeout:2.0];
    XCTAssertFalse(delegate.willRefreshCalled, @"3s interval should not have fired after only 2s");

    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];

    XCTestExpectation *firesWithinRemaining = [self expectationWithDescription:@"refresh fires within the remaining ~1s"];
    delegate.onWillRefresh = ^{ [firesWithinRemaining fulfill]; };
    [self waitForExpectations:@[firesWithinRemaining] timeout:2.0];
    XCTAssertTrue(delegate.willRefreshCalled, @"Resume should fire after the remaining ~1s, not restart a full 3s interval");

    [view stopAutoRefresh];
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
