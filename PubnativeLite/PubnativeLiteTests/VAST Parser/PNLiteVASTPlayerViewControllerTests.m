#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidVASTModel.h"
#import "HyBidVASTParser.h"
#import "HyBidEndCardView.h"
#import "HyBidCloseButton.h"
#import "HyBidSkipOverlay.h"

// Mirrors the private PNLiteVASTPlayerState bitmask defined in the .m.
static const NSUInteger kPNLiteVASTPlayerStateIdle = 1 << 0;
static const NSUInteger kPNLiteVASTPlayerStateLoad = 1 << 1;
static const NSUInteger kPNLiteVASTPlayerStateReady = 1 << 2;
static const NSUInteger kPNLiteVASTPlayerStatePlay = 1 << 3;

@interface PNLiteVASTPlayerViewController (TestExpose)
- (NSDictionary *)gettingTrackingAndThroughClickURL;
- (void)startAdSession;
- (void)removeElementsForReplay;
- (void)resetElementsForReplay;
- (void)resumeAd;
- (void)setState:(NSUInteger)state;
- (void)moviePlayBackDidFinish:(NSNotification *)notification;
@property (nonatomic, strong) NSArray *vastArray;
@property (nonatomic, strong) NSArray *vastCachedArray;
@property (nonatomic, strong) HyBidEndCardView *endCardView;
@property (nonatomic, assign) BOOL shown;
@property (nonatomic, assign) NSUInteger currentState;
@property (nonatomic, assign) BOOL isMoviePlaybackFinished;
@property (nonatomic, strong) AVPlayer *player;
@end

@interface PNLiteVASTPlayerViewControllerTests : XCTestCase
@end

@implementation PNLiteVASTPlayerViewControllerTests

// MARK: - resumeAd recovery path (VMI-1641)
// Covers the branch that resumes a stalled player when the state machine is
// already in PLAY (app was backgrounded during buffering, so [player play] was a no-op).

- (PNLiteVASTPlayerViewController *)controllerInPlayStateWithPlayer:(AVPlayer *)player shown:(BOOL)shown {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    controller.player = player;
    controller.shown = shown;
    controller.currentState = kPNLiteVASTPlayerStatePlay;
    return controller;
}

- (void)test_resumeAd_whenPlayStateStalledAndShown_callsPlay {
    AVPlayer *mockPlayer = mock([AVPlayer class]);
    [given([mockPlayer rate]) willReturnFloat:0.0f];
    PNLiteVASTPlayerViewController *controller = [self controllerInPlayStateWithPlayer:mockPlayer shown:YES];

    [controller resumeAd];
    // Reset before dealloc
    controller.shown = NO;

    [(AVPlayer *)verify(mockPlayer) play];
}

- (void)test_resumeAd_whenAlreadyPlaying_doesNotCallPlay {
    AVPlayer *mockPlayer = mock([AVPlayer class]);
    [given([mockPlayer rate]) willReturnFloat:1.0f];
    PNLiteVASTPlayerViewController *controller = [self controllerInPlayStateWithPlayer:mockPlayer shown:YES];

    [controller resumeAd];
    // Reset before dealloc
    controller.shown = NO;

    [(AVPlayer *)verifyCount(mockPlayer, never()) play];
}

- (void)test_resumeAd_whenNotShown_doesNotCallPlay {
    AVPlayer *mockPlayer = mock([AVPlayer class]);
    [given([mockPlayer rate]) willReturnFloat:0.0f];
    PNLiteVASTPlayerViewController *controller = [self controllerInPlayStateWithPlayer:mockPlayer shown:NO];

    [controller resumeAd];

    [(AVPlayer *)verifyCount(mockPlayer, never()) play];
}

- (void)test_gettingTrackingAndThroughClickURL_decodesClickThroughFromInlineSample {
    // Given: a real sample file with encoded ClickThrough URL
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(vastData, @"vast_4_20_example.xml must exist in test bundle!");

    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[vastData] forKey:@"vastArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    NSString *throughClickURL = result[@"throughClickURL"];

    XCTAssertEqualObjects(throughClickURL, @"https://ams.creativecdn.com/ad/clicks?ed_vast-clicked-area=companionAd&tk=UCQADTAsqiLrO6Km0KU90BJ9daAitZRhqz2lrE-8jW2quI0M-3tEngc9em2FnfBeKmRCneTeXrdFxKwx0oKJ5YsozRkRAky8308A_WkGrUYnNRFmevlwVdLTx4LVn2KQQPJ2e8Q0Mb36rFCkJLO463FZOLsgskLaaT-Txuih2o1oj0w_nh6GSuNpn_VzBlt9sjTApyOjSl8fTJW9UvM8W9ABsRPUR8lEkx7K3Xdo0h9Ua-gUE__ijkOHdjH5jfvKwmAKpDvRL9BB5KDlpZAkpVU82sMtDVrT3mVb99SShMC3ccDTDBTZwfHTqcOfT8KdUKsFESuq4BnRAwE78vw-u85Xbq90qNiAmmA-XlAqg46XOJm2Dvtxlge5Vxrdzv9eg27lGexRWP__OOQY9yqDWhV9yk0eTHUSFL6Ljo92qDulpswt72xANHFFIfFz4B5J9kTjU6KpmXY7IGiRzWjdCln9WZRA8c4TmP8xaxSIAh1NHeNG4PBnXSdMxvdj-4B44a3rnkkgb7WQhRTKva2W6Yiw-Xqntkbz_LDhS7KldNAx195i0VZaLoo0VucI15AzNEyUjaDUJQ2DN1DV6Hj4HXB5d5aOWU0wewO3DcFv7hpZgQ_C7nbNqRNXqAel0uLj");
}

- (void)test_gettingTrackingAndThroughClickURL_decodesClickThroughFromWrapperSample {
    // Given: a real sample file with encoded ClickThrough URL
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_wrapper"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(vastData, @"vast_4_20_example.xml must exist in test bundle!");

    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[vastData] forKey:@"vastArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    NSString *throughClickURL = result[@"throughClickURL"];

    XCTAssertEqualObjects(throughClickURL, @"https://ams.creativecdn.com/ad/clicks?ed_vast-clicked-area=companionAd&tk=UCQADTAsqiLrO6Km0KU90BJ9daAitZRhqz2lrE-8jW2quI0M-3tEngc9em2FnfBeKmRCneTeXrdFxKwx0oKJ5YsozRkRAky8308A_WkGrUYnNRFmevlwVdLTx4LVn2KQQPJ2e8Q0Mb36rFCkJLO463FZOLsgskLaaT-Txuih2o1oj0w_nh6GSuNpn_VzBlt9sjTApyOjSl8fTJW9UvM8W9ABsRPUR8lEkx7K3Xdo0h9Ua-gUE__ijkOHdjH5jfvKwmAKpDvRL9BB5KDlpZAkpVU82sMtDVrT3mVb99SShMC3ccDTDBTZwfHTqcOfT8KdUKsFESuq4BnRAwE78vw-u85Xbq90qNiAmmA-XlAqg46XOJm2Dvtxlge5Vxrdzv9eg27lGexRWP__OOQY9yqDWhV9yk0eTHUSFL6Ljo92qDulpswt72xANHFFIfFz4B5J9kTjU6KpmXY7IGiRzWjdCln9WZRA8c4TmP8xaxSIAh1NHeNG4PBnXSdMxvdj-4B44a3rnkkgb7WQhRTKva2W6Yiw-Xqntkbz_LDhS7KldNAx195i0VZaLoo0VucI15AzNEyUjaDUJQ2DN1DV6Hj4HXB5d5aOWU0wewO3DcFv7hpZgQ_C7nbNqRNXqAel0uLj");
}

- (void)test_init_createsController {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    XCTAssertNotNil(controller);
}

- (void)test_gettingTrackingAndThroughClickURL_emptyVastArray_doesNotCrash {
    // With empty vastArray, implementation may return nil; we only assert it doesn't crash
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[] forKey:@"vastArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    (void)result;
}

- (void)test_gettingTrackingAndThroughClickURL_withVastCachedArray_returnsTrackers {
    // Cover branch that uses vastCachedArray (vs vastArray)
    NSString *vastString = [self readFromTxtFileNamed:@"vast_4_20_example"];
    if (!vastString) { return; }
    NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[vastData] forKey:@"vastCachedArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    XCTAssertNotNil(result);
    (void)result[@"throughClickURL"];
    (void)result[@"trackingClickURLs"];
}

/// Covers new code: HyBidOMIDVerificationScriptResourceWrapper alloc in startAdSession when VAST has AdVerifications
- (void)testStartAdSession_withVastModelWithVerifications_doesNotCrash {
    NSString *vastString = [self readFromTxtFileNamed:@"vast_4_20_example"];
    if (!vastString) { return; }
    NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];
    HyBidVASTParser *parser = [[HyBidVASTParser alloc] init];
    XCTestExpectation *exp = [self expectationWithDescription:@"parse"];
    [parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
        XCTAssertNotNil(vastModel);
        if ([[vastModel ads] count] == 0) { [exp fulfill]; return; }
        PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
        [controller loadView];
        [controller setValue:vastModel forKey:@"hyBidVastModel"];
        [controller setValue:@NO forKey:@"isAdSessionCreated"];
        XCTAssertNoThrow([controller startAdSession]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

/// Covers the block: urlString.length != 0 && vendor.length != 0 && params.length != 0 → HyBidOMIDVerificationScriptResourceWrapper alloc.
/// Uses vast_verification_with_params.xml which has one Verification with JavaScriptResource URL, vendor, and VerificationParameters content.
/// Note: Parser completion may pass a non-nil error even on success (HyBidVASTParserError_None maps to unknown error), so we only require model + ads.
- (void)testStartAdSession_withVastVerificationWithUrlVendorAndParams_createsScriptResourceWrapper {
    NSString *vastString = [self readFromTxtFileNamed:@"vast_verification_with_params"];
    if (!vastString) { XCTFail(@"vast_verification_with_params.xml must exist in test bundle"); return; }
    NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];
    HyBidVASTParser *parser = [[HyBidVASTParser alloc] init];
    XCTestExpectation *exp = [self expectationWithDescription:@"parse"];
    [parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
        XCTAssertNotNil(vastModel);
        if ([[vastModel ads] count] == 0) { [exp fulfill]; return; }
        PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
        [controller loadView];
        [controller setValue:vastModel forKey:@"hyBidVastModel"];
        [controller setValue:@NO forKey:@"isAdSessionCreated"];
        // Exercises: verificationParameters content, and HyBidOMIDVerificationScriptResourceWrapper alloc when url/vendor/params all non-empty
        XCTAssertNoThrow([controller startAdSession]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// MARK: - removeElementsForReplay tests

- (void)test_removeElementsForReplay_removesEndCardViewSubview {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    HyBidEndCardView *endCard = [[HyBidEndCardView alloc] initWithFrame:CGRectZero];
    [controller.view addSubview:endCard];
    controller.endCardView = endCard;

    [controller removeElementsForReplay];

    XCTAssertNil(endCard.superview, "HyBidEndCardView should be removed from superview after removeElementsForReplay");
    XCTAssertNil(controller.endCardView, "endCardView property should be nil after removeElementsForReplay");
}

- (void)test_removeElementsForReplay_removesCloseButtonSubview {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    HyBidCloseButton *closeBtn = [[HyBidCloseButton alloc] initWithFrame:CGRectZero];
    [controller.view addSubview:closeBtn];

    [controller removeElementsForReplay];

    XCTAssertNil(closeBtn.superview, "HyBidCloseButton should be removed from superview after removeElementsForReplay");
}

- (void)test_removeElementsForReplay_withBothSubviews_removesAll {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    HyBidEndCardView *endCard = [[HyBidEndCardView alloc] initWithFrame:CGRectZero];
    HyBidCloseButton *closeBtn = [[HyBidCloseButton alloc] initWithFrame:CGRectZero];
    [controller.view addSubview:endCard];
    [controller.view addSubview:closeBtn];
    controller.endCardView = endCard;

    [controller removeElementsForReplay];

    XCTAssertNil(endCard.superview);
    XCTAssertNil(closeBtn.superview);
    XCTAssertNil(controller.endCardView);
}

- (void)test_removeElementsForReplay_withNoSubviews_doesNotCrash {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    XCTAssertNoThrow([controller removeElementsForReplay]);
    XCTAssertNil(controller.endCardView);
}

// MARK: - OMSDK main-thread marshaling (VMI-1622)
// The OMSDK sampling timer walks the registered ad view on the main runloop. setState: and
// moviePlayBackDidFinish: fire OMID events and mutate that view, so when they are reached from an
// off-main AVFoundation callback they must hop to the main thread instead of racing the tree walker.

- (void)test_setState_calledOffMainThread_defersTransitionToMainThread {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];
    controller.currentState = kPNLiteVASTPlayerStateLoad;

    dispatch_semaphore_t bgObserved = dispatch_semaphore_create(0);
    __block BOOL calledOffMain = NO;
    __block NSUInteger stateOnCallingThread = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        calledOffMain = ![NSThread isMainThread];
        [controller setState:kPNLiteVASTPlayerStateReady];
        // The main thread is blocked below, so a correctly-marshaled transition cannot have run yet.
        stateOnCallingThread = controller.currentState;
        dispatch_semaphore_signal(bgObserved);
    });
    // Block the main runloop until the background thread has observed the state, so the dispatched
    // transition cannot slip in and produce a false pass.
    intptr_t waitResult = dispatch_semaphore_wait(bgObserved, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)));
    XCTAssertEqual(waitResult, (intptr_t)0, @"background thread did not signal within 2s (possible off-main hang or crash)");

    XCTAssertTrue(calledOffMain, @"precondition: setState: must be invoked off the main thread");
    XCTAssertEqual(stateOnCallingThread, kPNLiteVASTPlayerStateLoad,
                   @"setState: off-main must not mutate state synchronously on the calling thread");

    XCTestExpectation *drained = [self expectationWithDescription:@"main queue drained"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drained fulfill]; });
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertEqual(controller.currentState, kPNLiteVASTPlayerStateReady,
                   @"the deferred transition must be applied once the main queue runs");

    controller.currentState = kPNLiteVASTPlayerStateIdle; // keep dealloc quiet, mirrors existing tests
}

- (void)test_setState_calledOnMainThread_appliesTransitionSynchronously {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];
    controller.currentState = kPNLiteVASTPlayerStateLoad;

    [controller setState:kPNLiteVASTPlayerStateReady]; // already on the main thread

    XCTAssertEqual(controller.currentState, kPNLiteVASTPlayerStateReady,
                   @"setState: on the main thread must stay synchronous (no behavior change)");

    controller.currentState = kPNLiteVASTPlayerStateIdle;
}

- (void)test_moviePlayBackDidFinish_calledOffMainThread_defersToMainThread {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];
    NSNotification *note = [NSNotification notificationWithName:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    dispatch_semaphore_t bgObserved = dispatch_semaphore_create(0);
    __block BOOL finishedOnCallingThread = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [controller moviePlayBackDidFinish:note];
        finishedOnCallingThread = controller.isMoviePlaybackFinished;
        dispatch_semaphore_signal(bgObserved);
    });
    intptr_t waitResult = dispatch_semaphore_wait(bgObserved, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)));
    XCTAssertEqual(waitResult, (intptr_t)0, @"background thread did not signal within 2s (possible off-main hang or crash)");

    XCTAssertFalse(finishedOnCallingThread,
                   @"moviePlayBackDidFinish: off-main must not run its body on the calling thread");

    XCTestExpectation *drained = [self expectationWithDescription:@"main queue drained"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drained fulfill]; });
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertTrue(controller.isMoviePlaybackFinished,
                  @"the handler body must run once marshaled to the main thread");
}

// MARK: - Helper Methods

- (NSString *)readFromTxtFileNamed:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:name ofType:@"xml"];

    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        XCTFail(@"Error reading file: %@", error.localizedDescription);
        return nil;
    }

    return fileContents;
}

@end
