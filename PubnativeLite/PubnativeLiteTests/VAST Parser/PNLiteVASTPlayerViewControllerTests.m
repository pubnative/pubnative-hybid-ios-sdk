#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidVASTModel.h"
#import "HyBidVASTParser.h"
#import "HyBidXMLEx.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidEndCardView.h"
#import "HyBidEndCardView+Testing.h"
#import "HyBidEndCard.h"
#import "HyBidCloseButton.h"
#import "HyBidSkipOverlay.h"
#import "HyBidVASTLinear.h"
#import "HyBidXMLElementEx.h"
#import "HyBidAdModel.h"
#import "HyBidSKAdNetworkParameter.h"
#import "PNLiteResponseModel.h"
#import "HyBidVASTTrackingEvents.h"
#import "HyBidAutomaticClickTrackingUtil.h"

// Mirrors the private PNLiteVASTPlayerState bitmask defined in the .m.
static const NSUInteger kPNLiteVASTPlayerStateIdle = 1 << 0;
static const NSUInteger kPNLiteVASTPlayerStateLoad = 1 << 1;
static const NSUInteger kPNLiteVASTPlayerStateReady = 1 << 2;
static const NSUInteger kPNLiteVASTPlayerStatePlay = 1 << 3;

static NSString * const kSuppressAutoClickConfigKey = @"suppress_auto_click";
static NSString * const kSDKAutoStoreKitConfigKey = @"sdk_autostorekit";
static NSString * const kSKOverlayEnabledConfigKey = @"SKOverlayenabled";

@interface PNLiteVASTPlayerViewController (TestExpose) <HyBidEndCardViewDelegate>
- (NSDictionary *)gettingTrackingAndThroughClickURL;
- (void)startAdSession;
- (void)removeElementsForReplay;
- (void)resetElementsForReplay;
- (void)resumeAd;
- (void)setState:(NSUInteger)state;
- (void)moviePlayBackDidFinish:(NSNotification *)notification;
- (BOOL)isValidToShowCustomCountdown;
- (void)determineRewardedSkipOffsetForAd:(HyBidAd *)ad;
- (HyBidSkipOffset *)convertSkipOffsetFromVASTLinear:(HyBidVASTLinear *)vastLinear;
- (HyBidSkipOffset *)resolveSkipOffsetFromVAST:(HyBidSkipOffset *)vastSkipOffset remoteConfigOffset:(NSNumber *)remoteConfigOffset;
- (void)trackClickForSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType isFirstPresentation:(BOOL)isFirstPresentation;
- (void)trackClickForAutoStorekit:(HyBidStorekitAutomaticClickType)clickType;
- (void)showEndCard;
- (NSDictionary<NSString *, NSMutableArray<NSString *> *> *)setTrackingEvents:(NSArray *)vastArray;
@property (nonatomic, strong) NSMutableArray<HyBidEndCard *> *endCards;
@property (nonatomic, strong) NSDictionary<NSString *, NSMutableArray<NSString *> *> *events;
@property (nonatomic, strong) NSArray *vastArray;
@property (nonatomic, strong) NSArray *vastCachedArray;
@property (nonatomic, strong) HyBidEndCardView *endCardView;
@property (nonatomic, strong) HyBidEndCard *currentEndCard;
@property (nonatomic, strong) HyBidVASTEventProcessor *vastEventProcessor;
@property (nonatomic, assign) BOOL hasTrackedVideoClick;
@property (nonatomic, assign) BOOL hasTrackedClickEvent;
@property (nonatomic, assign) BOOL hasTrackedCompanionClick;
@property (nonatomic, assign) BOOL hasTrackedCompanionClickEvent;
@property (nonatomic, strong) NSMutableSet<HyBidEndCard *> *trackedEndCards;
@property (nonatomic, assign) BOOL shown;
@property (nonatomic, assign) NSUInteger currentState;
@property (nonatomic, assign) BOOL isMoviePlaybackFinished;
@property (nonatomic, strong) AVPlayer *player;
@end

// VMI-1678: overrides `duration` (normally read from a live AVPlayerItem) so the
// skip-offset-vs-duration logic can be unit tested without a real video asset.
@interface TestableVASTPlayerViewController : PNLiteVASTPlayerViewController
@property (nonatomic, assign) Float64 stubbedDuration;
@end

@implementation TestableVASTPlayerViewController
- (Float64)duration {
    return self.stubbedDuration;
}
@end

// VMI-1733: skips the MRAID web view, impression reporting and close-button chrome so displayEndCard: can run in a unit test.
@interface DisplayOnlyEndCardView : HyBidEndCardView
@end

@implementation DisplayOnlyEndCardView
- (void)displayMRAIDWithContent:(NSString *)content withBaseURL:(NSURL *)baseURL {}
- (void)trackEndCardImpression {}
- (void)setupUI {}
@end

@interface HyBidEndCardView (MRAIDDelegateTestExpose)
- (void)mraidViewAdReady:(HyBidMRAIDView *)mraidView;
- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView withError:(NSError *)error;
@end

// Stands in for the rendered MRAID view handed to mraidViewAdReady:.
@interface RenderedMRAIDViewStub : UIView
@end

@implementation RenderedMRAIDViewStub
- (void)setIsViewable:(BOOL)isViewable {}
- (void)setDelegate:(id)delegate {}
- (void)setServiceDelegate:(id)serviceDelegate {}
@end

@interface HyBidVASTEventProcessor (TestExpose)
- (void)sendTrackingRequest:(NSString *)url trackingType:(NSString *)vastTrackerType;
@end

// VMI-1733: records the URLs the processor would send instead of hitting the network.
@interface RecordingVASTEventProcessor : HyBidVASTEventProcessor
@property (nonatomic, strong) NSMutableArray<NSString *> *sentURLs;
@end

@implementation RecordingVASTEventProcessor
- (void)sendTrackingRequest:(NSString *)url trackingType:(NSString *)vastTrackerType {
    if (!self.sentURLs) { self.sentURLs = [NSMutableArray array]; }
    [self.sentURLs addObject:url];
}
@end

@interface PNLiteVASTPlayerViewControllerTests : XCTestCase
- (HyBidAd *)automaticClickAdFromTestBundle;
- (HyBidAd *)automaticClickAdFromTestBundleWithRemoteConfigs:(NSDictionary *)remoteConfigs;
- (HyBidVASTAd *)vastAdFromAd:(HyBidAd *)ad;
- (PNLiteVASTPlayerViewController *)automaticClickControllerWithProcessor:(HyBidVASTEventProcessor *)processor
                                                                  delegate:(NSObject<PNLiteVASTPlayerViewControllerDelegate> *)delegate;
- (PNLiteVASTPlayerViewController *)automaticClickControllerWithProcessor:(HyBidVASTEventProcessor *)processor
                                                                  delegate:(NSObject<PNLiteVASTPlayerViewControllerDelegate> *)delegate
                                                             remoteConfigs:(NSDictionary *)remoteConfigs;
- (NSArray<NSString *> *)trackingClickURLsForController:(PNLiteVASTPlayerViewController *)controller;
- (void)verifyAutomaticClickTrackingWithInvocations:(void (^)(PNLiteVASTPlayerViewController *controller))invocations
                               delegateVerification:(void (^)(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate))delegateVerification;
- (HyBidEndCardView *)automaticClickEndCardViewWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                  processor:(HyBidVASTEventProcessor *)processor
                                      shouldTriggerAdClick:(BOOL)shouldTriggerAdClick;
- (HyBidEndCardView *)automaticClickEndCardViewWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                  processor:(HyBidVASTEventProcessor *)processor
                                      shouldTriggerAdClick:(BOOL)shouldTriggerAdClick
                                    hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick
                                      hasTrackedVideoClick:(BOOL)hasTrackedVideoClick
                                      hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent
                                  hasTrackedCompanionClick:(BOOL)hasTrackedCompanionClick;
- (HyBidEndCardView *)automaticClickEndCardViewContinuingFromController:(PNLiteVASTPlayerViewController *)controller
                                                              processor:(HyBidVASTEventProcessor *)processor
                                                  shouldTriggerAdClick:(BOOL)shouldTriggerAdClick
                                                hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick;
- (HyBidEndCardView *)automaticClickEndCardViewWithAd:(HyBidAd *)ad
                                             delegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                            processor:(HyBidVASTEventProcessor *)processor
                                 shouldTriggerAdClick:(BOOL)shouldTriggerAdClick
                               hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick
                                 hasTrackedVideoClick:(BOOL)hasTrackedVideoClick
                                 hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent
                             hasTrackedCompanionClick:(BOOL)hasTrackedCompanionClick;
- (HyBidEndCardView *)endCardViewOfClass:(Class)viewClass
                                      ad:(HyBidAd *)ad
                                  vastAd:(HyBidVASTAd *)vastAd
                                delegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                          viewController:(UIViewController *)viewController
                  hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick
                    hasTrackedVideoClick:(BOOL)hasTrackedVideoClick
                    hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent
                hasTrackedCompanionClick:(BOOL)hasTrackedCompanionClick;
- (HyBidEndCardView *)suppressedAutoClickEndCardViewWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                       processor:(HyBidVASTEventProcessor *)processor;
- (HyBidEndCardView *)endCardViewWithSuppressAutoClickValue:(id)suppressAutoClickValue
                                                   delegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                  processor:(HyBidVASTEventProcessor *)processor;
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

- (void)test_trackClickForSKOverlay_repeatedPresentation_sendsVASTClickOnce {
    [self verifyAutomaticClickTrackingWithInvocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
        [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:NO];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, times(2)) vastPlayerDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo];
    }];
}

- (void)test_trackClickForAutoStorekit_repeatedPresentation_sendsVASTClickOnce {
    [self verifyAutomaticClickTrackingWithInvocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];
        [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickDefaultEndCard];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, times(1)) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickVideo];
        [verifyCount(delegate, times(1)) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickDefaultEndCard];
    }];
}

// VMI-1700: AutoStoreKit and SKOverlay share one latch per tracker group, whichever fires first.
- (void)test_autoStorekitThenSKOverlay_sendsVASTClickOnce {
    [self verifyAutomaticClickTrackingWithInvocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];
        [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, times(1)) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickVideo];
        [verifyCount(delegate, times(1)) vastPlayerDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo];
    }];
}

// VMI-1681: suppress_auto_click silences the SKOverlay and AutoStoreKit auto-click paths.

- (void)test_trackClickForSKOverlay_whenSuppressAutoClickEnabled_sendsNoClick {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSuppressAutoClickConfigKey: @YES}
                                  expectedTrackedClicks:0
                                            invocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, never()) vastPlayerDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo];
    }];
}

- (void)test_trackClickForAutoStorekit_whenSuppressAutoClickEnabled_sendsNoClick {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSuppressAutoClickConfigKey: @YES}
                                  expectedTrackedClicks:0
                                            invocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, never()) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickVideo];
    }];
}

- (void)test_trackClickForSKOverlay_whenSuppressAutoClickDisabled_sendsClick {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSuppressAutoClickConfigKey: @NO}
                                  expectedTrackedClicks:1
                                            invocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, times(1)) vastPlayerDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo];
    }];
}

- (void)test_endCardAutoStorekit_whenSuppressAutoClickEnabled_sendsNoClick {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self suppressedAutoClickEndCardViewWithDelegate:delegate processor:processor];

    [endCardView fireClicksForAutoStorekit];

    [verifyCount(processor, never()) sendVASTUrls:endCardView.endCard.clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, never()) endCardViewAutoStorekitClicked:NO
                                                         clickType:HyBidStorekitAutomaticClickDefaultEndCard];
}

- (void)test_endCardSKOverlay_whenSuppressAutoClickEnabled_sendsNoClick {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self suppressedAutoClickEndCardViewWithDelegate:delegate processor:processor];

    [endCardView skOverlayDidShowOnCreative:YES];

    [verifyCount(processor, never()) sendVASTUrls:endCardView.endCard.clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, never()) endCardViewSKOverlayClicked:NO
                                                      clickType:HyBidSKOverlayAutomaticCLickDefaultEndCard
                                            isFirstPresentation:YES];
}

// VMI-1681: suppression must silence the auto-click only — a real user click still counts.
- (void)test_endCardUserClick_afterSuppressedAutoStorekit_stillTriggersAdClick {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithAd:[self automaticClickAdFromTestBundleWithRemoteConfigs:@{kSuppressAutoClickConfigKey: @YES}]
                                                                delegate:delegate
                                                               processor:processor
                                                    shouldTriggerAdClick:YES
                                                  hasTrackedEndCardClick:NO
                                                    hasTrackedVideoClick:NO
                                                    hasTrackedCompanionClickEvent:NO
                                                hasTrackedCompanionClick:NO];

    [endCardView fireClicksForAutoStorekit];
    [endCardView endCardViewClicked];

    [verifyCount(delegate, never()) endCardViewAutoStorekitClicked:YES
                                                         clickType:HyBidStorekitAutomaticClickCustomEndCard];
    [verifyCount(delegate, times(1)) endCardViewClicked:YES aakCustomClickAd:(id)anything()];
}

// VMI-1681: suppression holds across the VMI-1673 AutoStoreKit x SKOverlay toggle matrix (all four combinations).
- (void)test_automaticClickPaths_whenSuppressAutoClickEnabled_sendNoClickAcrossToggleMatrix {
    [self verifyToggleMatrixWithSuppressAutoClickValue:@YES expectedTrackedClicks:0];
}

// VMI-1700: the AutoStoreKit/SKOverlay toggles alone must not suppress — one beacon per ad view across both auto-click sources in every combination.
- (void)test_automaticClickPaths_whenSuppressAutoClickDisabled_sendClickAcrossToggleMatrix {
    [self verifyToggleMatrixWithSuppressAutoClickValue:@NO expectedTrackedClicks:1];
}

- (void)test_trackClickForAutoStorekit_whenSuppressAutoClickDisabled_sendsClick {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSuppressAutoClickConfigKey: @NO}
                                  expectedTrackedClicks:1
                                            invocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, times(1)) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickVideo];
    }];
}

// VMI-1681: a structurally invalid suppress_auto_click must not crash and must leave today's behaviour intact.
- (void)test_trackClickForAutoStorekit_whenSuppressAutoClickIsNonBooleanObject_sendsClick {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSuppressAutoClickConfigKey: @{@"unexpected": @"object"}}
                                  expectedTrackedClicks:1
                                            invocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, times(1)) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickVideo];
    }];
}

- (void)test_trackClickForSKOverlay_whenSuppressAutoClickIsNull_sendsClick {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSuppressAutoClickConfigKey: [NSNull null]}
                                  expectedTrackedClicks:1
                                            invocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, times(1)) vastPlayerDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo];
    }];
}

// VMI-1681: a string-typed boolean still coerces, so a stringified config value suppresses rather than silently firing.
- (void)test_trackClickForAutoStorekit_whenSuppressAutoClickIsBooleanString_sendsNoClick {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSuppressAutoClickConfigKey: @"true"}
                                  expectedTrackedClicks:0
                                            invocations:^(PNLiteVASTPlayerViewController *controller) {
        [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];
    } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
        [verifyCount(delegate, never()) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickVideo];
    }];
}

- (void)test_endCardAutoStorekit_whenSuppressAutoClickDisabled_sendsClick {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self endCardViewWithSuppressAutoClickValue:@NO delegate:delegate processor:processor];

    [endCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:endCardView.endCard.clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, times(1)) endCardViewAutoStorekitClicked:NO
                                                          clickType:HyBidStorekitAutomaticClickDefaultEndCard];
}

- (void)test_endCardSKOverlay_whenSuppressAutoClickDisabled_sendsClick {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self endCardViewWithSuppressAutoClickValue:@NO delegate:delegate processor:processor];

    [endCardView skOverlayDidShowOnCreative:YES];

    [verifyCount(processor, times(1)) sendVASTUrls:endCardView.endCard.clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, times(1)) endCardViewSKOverlayClicked:NO
                                                       clickType:HyBidSKOverlayAutomaticCLickDefaultEndCard
                                             isFirstPresentation:YES];
}

- (void)test_endCardAutoStorekit_whenSuppressAutoClickIsNonBooleanObject_sendsClick {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self endCardViewWithSuppressAutoClickValue:@[@"unexpected"]
                                                                      delegate:delegate
                                                                     processor:processor];

    [endCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:endCardView.endCard.clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, times(1)) endCardViewAutoStorekitClicked:NO
                                                          clickType:HyBidStorekitAutomaticClickDefaultEndCard];
}

- (void)test_endCardSKOverlay_afterVideoPresentation_sendsCompanionClickOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    NSArray *clickTrackings = endCardView.endCard.clickTrackings;

    [endCardView skOverlayDidShowOnCreative:NO];
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, times(2)) endCardViewSKOverlayClicked:NO
                                                     clickType:HyBidSKOverlayAutomaticCLickDefaultEndCard
                                           isFirstPresentation:NO];
}

- (void)test_endCardSKOverlay_emptyFirstPresentation_doesNotSuppressLaterTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    endCardView.endCard.clickTrackings = @[];

    [endCardView skOverlayDidShowOnCreative:NO];

    NSArray *clickTrackings = @[@"https://companion-click.example"];
    endCardView.endCard.clickTrackings = clickTrackings;
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
}

- (void)test_endCardSKOverlay_invalidTrackingContainerDoesNotSuppressLaterTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    endCardView.endCard.clickTrackings = (id)@"invalid";

    [endCardView skOverlayDidShowOnCreative:NO];

    NSArray *clickTrackings = @[@"https://companion-click.example"];
    endCardView.endCard.clickTrackings = clickTrackings;
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
}

- (void)test_endCardSKOverlay_invalidTrackingValuesDoNotSuppressLaterTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    endCardView.endCard.clickTrackings = (id)@[[NSNull null], @"", @42];

    [endCardView skOverlayDidShowOnCreative:NO];

    NSArray *validClickTrackings = @[@"https://first-companion-click.example", @"https://second-companion-click.example"];
    endCardView.endCard.clickTrackings = validClickTrackings;

    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:validClickTrackings withType:HyBidVASTClickTrackingURL];
}

- (void)test_endCardSKOverlay_triggeredAdClick_afterVideoPresentation_sendsEachClickGroupOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    NSArray *linearClickTrackings = [self trackingClickURLsForController:controller];
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                      processor:processor
                                                          shouldTriggerAdClick:YES];
    NSArray *companionClickTrackings = endCardView.endCard.clickTrackings;

    [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
    XCTAssertTrue(controller.hasTrackedVideoClick);
    XCTAssertTrue(controller.hasTrackedClickEvent);
    [endCardView skOverlayDidShowOnCreative:NO];
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:companionClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) sendVASTUrls:linearClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    [verifyCount(delegate, times(2)) vastPlayerDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickCustomEndCard];
}

- (void)test_endCardAutoStorekit_repeatedPresentation_sendsCompanionClickOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    NSArray *clickTrackings = endCardView.endCard.clickTrackings;

    [endCardView fireClicksForAutoStorekit];
    [endCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, times(2)) endCardViewAutoStorekitClicked:NO
                                                        clickType:HyBidStorekitAutomaticClickDefaultEndCard];
}

- (void)test_endCardSKOverlay_withVASTAd_afterVideoPresentation_sendsOnlyCompanionClickOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    NSArray *videoClickTrackings = [self trackingClickURLsForController:controller];

    [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];

    // VMI-1733: the end card owns a processor loaded with the companion list, separate from the player's linear one.
    HyBidVASTEventProcessor *endCardProcessor = mock([HyBidVASTEventProcessor class]);
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:endCardProcessor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:NO];
    NSArray *companionClickTrackings = @[@"https://companion-click.example"];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastCompanionsClicksTracking = companionClickTrackings;
    endCardView.vastVideoClicksTracking = videoClickTrackings;
    controller.endCardView = endCardView;

    [endCardView skOverlayDidShowOnCreative:NO];
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(endCardProcessor, times(1)) sendVASTUrls:companionClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(endCardProcessor, never()) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    // Linear and companion click events are separate declared lists; each fires once.
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    [verifyCount(endCardProcessor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
}

- (void)test_endCardSKOverlay_withVASTAd_firstPresentation_sendsVideoAndCompanionClicksOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    NSArray *videoClickTrackings = @[@"https://video-click.example"];
    NSArray *companionClickTrackings = @[@"https://companion-click.example"];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastVideoClicksTracking = videoClickTrackings;
    endCardView.vastCompanionsClicksTracking = companionClickTrackings;
    controller.endCardView = endCardView;

    [endCardView skOverlayDidShowOnCreative:YES];
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) sendVASTUrls:companionClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    XCTAssertTrue(controller.hasTrackedVideoClick);
    XCTAssertTrue(controller.hasTrackedCompanionClickEvent);
}

- (void)test_endCardSKOverlay_withVASTAd_emptyVideoFirstPresentation_doesNotSuppressLaterTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastVideoClicksTracking = @[];
    endCardView.vastCompanionsClicksTracking = @[];

    [endCardView skOverlayDidShowOnCreative:YES];

    NSArray *videoClickTrackings = @[@"https://video-click.example"];
    endCardView.vastVideoClicksTracking = videoClickTrackings;
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
}

- (void)test_endCardSKOverlay_withVASTAd_untrackedFirstPresentation_retriesAllTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    NSArray *videoClickTrackings = @[@"https://video-click.example"];
    NSArray *companionClickTrackings = @[@"https://companion-click.example"];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastVideoClicksTracking = videoClickTrackings;
    endCardView.vastCompanionsClicksTracking = companionClickTrackings;
    controller.endCardView = endCardView;

    endCardView.vastEventProcessor = nil;
    [endCardView skOverlayDidShowOnCreative:YES];
    endCardView.vastEventProcessor = processor;
    [endCardView skOverlayDidShowOnCreative:NO];
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) sendVASTUrls:companionClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    XCTAssertTrue(controller.hasTrackedVideoClick);
    XCTAssertTrue(controller.hasTrackedCompanionClickEvent);
}

- (void)test_endCardSKOverlay_withVASTAd_acrossDistinctEndCards_sendsCompanionAggregateOncePerAdView {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    NSArray *companionClickTrackings = @[@"https://companion-click.example"];

    HyBidEndCardView *firstEndCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO];
    firstEndCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    firstEndCardView.vastCompanionsClicksTracking = companionClickTrackings;
    controller.endCardView = firstEndCardView;

    [firstEndCardView skOverlayDidShowOnCreative:YES];

    XCTAssertTrue(controller.hasTrackedCompanionClick);

    HyBidEndCardView *secondEndCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:NO];
    secondEndCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    secondEndCardView.vastCompanionsClicksTracking = companionClickTrackings;
    controller.endCardView = secondEndCardView;

    [secondEndCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:companionClickTrackings withType:HyBidVASTClickTrackingURL];
}

// VMI-1700: the VAST companion branch sends the aggregate list; it must not arm the per-end-card latch.
- (void)test_endCardSKOverlay_withVASTAd_companionBranch_doesNotArmEndCardClickLatch {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor
                                                                                    delegate:mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate))];
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastCompanionsClicksTracking = @[@"https://companion-click.example"];
    controller.endCardView = endCardView;

    [endCardView skOverlayDidShowOnCreative:YES];

    XCTAssertTrue(controller.hasTrackedCompanionClick);
    XCTAssertFalse([controller.trackedEndCards containsObject:endCardView.endCard]);
}

- (void)test_endCardSKOverlay_acrossEndCardViews_sendsCompanionClickOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    HyBidEndCardView *firstEndCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                           processor:processor
                                                               shouldTriggerAdClick:NO];
    controller.endCardView = firstEndCardView;
    NSArray *clickTrackings = firstEndCardView.endCard.clickTrackings;

    [firstEndCardView skOverlayDidShowOnCreative:NO];

    XCTAssertTrue([controller.trackedEndCards containsObject:firstEndCardView.endCard]);
    HyBidEndCardView *secondEndCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:[controller.trackedEndCards containsObject:firstEndCardView.endCard]];
    secondEndCardView.endCard = firstEndCardView.endCard;
    controller.endCardView = secondEndCardView;
    [secondEndCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
}

- (void)test_endCardSKOverlay_distinctEndCards_sendEachCreativeClickOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    HyBidEndCardView *firstEndCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                           processor:processor
                                                               shouldTriggerAdClick:NO];
    NSArray *firstClickTrackings = @[@"https://first-companion-click.example"];
    firstEndCardView.endCard.clickTrackings = firstClickTrackings;
    controller.endCardView = firstEndCardView;

    [firstEndCardView skOverlayDidShowOnCreative:NO];

    HyBidEndCardView *secondEndCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:NO];
    NSArray *secondClickTrackings = @[@"https://second-companion-click.example"];
    secondEndCardView.endCard.clickTrackings = secondClickTrackings;
    controller.endCardView = secondEndCardView;

    [secondEndCardView skOverlayDidShowOnCreative:NO];
    [secondEndCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:firstClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) sendVASTUrls:secondClickTrackings withType:HyBidVASTClickTrackingURL];
}

- (void)test_endCardSKOverlay_firstPresentationWithAdClick_sendsEachClickGroupOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    NSArray *linearClickTrackings = [self trackingClickURLsForController:controller];
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                      processor:processor
                                                          shouldTriggerAdClick:YES];
    controller.endCardView = endCardView;
    NSArray *endCardClickTrackings = endCardView.endCard.clickTrackings;

    [endCardView skOverlayDidShowOnCreative:YES];
    [endCardView skOverlayDidShowOnCreative:NO];

    [verifyCount(processor, times(1)) sendVASTUrls:endCardClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) sendVASTUrls:linearClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    XCTAssertTrue(controller.hasTrackedVideoClick);
    XCTAssertTrue(controller.hasTrackedClickEvent);
}

- (void)test_endCardAutoStorekit_withVASTAd_sendsVideoClickOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    NSArray *videoClickTrackings = @[@"https://video-click.example"];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastVideoClicksTracking = videoClickTrackings;

    [endCardView fireClicksForAutoStorekit];
    [endCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
}

// VMI-1700: on the end card both auto-click sources share the video and click-event latches, whichever fires first.
- (void)test_endCardSKOverlayThenAutoStorekit_withVASTAd_sendsVideoClickOnce {
    [self verifyEndCardVideoClickSentOnceWithInvocations:^(HyBidEndCardView *endCardView) {
        [endCardView skOverlayDidShowOnCreative:YES];
        [endCardView fireClicksForAutoStorekit];
    }];
}

- (void)test_endCardAutoStorekitThenSKOverlay_withVASTAd_sendsVideoClickOnce {
    [self verifyEndCardVideoClickSentOnceWithInvocations:^(HyBidEndCardView *endCardView) {
        [endCardView fireClicksForAutoStorekit];
        [endCardView skOverlayDidShowOnCreative:YES];
    }];
}

// VMI-1700: the end card's own click trackings share one latch across both auto-click sources.
- (void)test_endCardSKOverlayThenAutoStorekit_sendsEndCardClickOnce {
    [self verifyEndCardClickSentOnceWithInvocations:^(HyBidEndCardView *endCardView) {
        [endCardView skOverlayDidShowOnCreative:NO];
        [endCardView fireClicksForAutoStorekit];
    }];
}

- (void)test_endCardAutoStorekitThenSKOverlay_sendsEndCardClickOnce {
    [self verifyEndCardClickSentOnceWithInvocations:^(HyBidEndCardView *endCardView) {
        [endCardView fireClicksForAutoStorekit];
        [endCardView skOverlayDidShowOnCreative:NO];
    }];
}

// VMI-1700: AutoStoreKit follows the SKOverlay rule — one send per end card, shared across both auto-click sources.
- (void)test_endCardAutoStorekit_acrossEndCardViews_sendsEndCardClickOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    HyBidEndCardView *firstEndCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                           processor:processor
                                                               shouldTriggerAdClick:NO];
    NSArray *clickTrackings = firstEndCardView.endCard.clickTrackings;
    controller.endCardView = firstEndCardView;

    [firstEndCardView fireClicksForAutoStorekit];

    XCTAssertTrue([controller.trackedEndCards containsObject:firstEndCardView.endCard]);
    HyBidEndCardView *secondEndCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:[controller.trackedEndCards containsObject:firstEndCardView.endCard]];
    secondEndCardView.endCard = firstEndCardView.endCard;
    controller.endCardView = secondEndCardView;
    [secondEndCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(delegate, times(2)) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickDefaultEndCard];
}

- (void)test_endCardAutoStorekit_emptyFirstEndCard_doesNotSuppressSecondEndCardTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    HyBidEndCardView *firstEndCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                           processor:processor
                                                               shouldTriggerAdClick:NO];
    firstEndCardView.endCard.clickTrackings = @[];
    controller.endCardView = firstEndCardView;

    [firstEndCardView fireClicksForAutoStorekit];

    XCTAssertFalse([controller.trackedEndCards containsObject:firstEndCardView.endCard]);
    HyBidEndCardView *secondEndCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:NO];
    controller.endCardView = secondEndCardView;
    NSArray *clickTrackings = secondEndCardView.endCard.clickTrackings;

    [secondEndCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
    XCTAssertTrue([controller.trackedEndCards containsObject:secondEndCardView.endCard]);
}

- (void)test_endCardAutoStorekit_withVASTAd_emptyFirstEndCard_doesNotSuppressSecondEndCardTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    HyBidVASTAd *vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    HyBidEndCardView *firstEndCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                           processor:processor
                                                               shouldTriggerAdClick:NO];
    firstEndCardView.vastAd = vastAd;
    firstEndCardView.vastVideoClicksTracking = @[];
    controller.endCardView = firstEndCardView;

    [firstEndCardView fireClicksForAutoStorekit];

    XCTAssertFalse(controller.hasTrackedVideoClick);
    XCTAssertTrue(controller.hasTrackedCompanionClickEvent);
    HyBidEndCardView *secondEndCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:NO];
    NSArray *videoClickTrackings = @[@"https://video-click.example"];
    secondEndCardView.vastAd = vastAd;
    secondEndCardView.vastVideoClicksTracking = videoClickTrackings;
    controller.endCardView = secondEndCardView;

    [secondEndCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    XCTAssertTrue(controller.hasTrackedVideoClick);
    XCTAssertTrue(controller.hasTrackedCompanionClickEvent);
}

- (void)test_endCardAutoStorekit_emptyVideoTracking_doesNotSuppressEndCardTracking {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    controller.vastArray = @[];

    [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];

    XCTAssertFalse(controller.hasTrackedVideoClick);
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewContinuingFromController:controller
                                                                          processor:processor
                                                              shouldTriggerAdClick:NO
                                                            hasTrackedEndCardClick:NO];
    NSArray *videoClickTrackings = @[@"https://video-click.example"];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastVideoClicksTracking = videoClickTrackings;
    controller.endCardView = endCardView;

    [endCardView fireClicksForAutoStorekit];

    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    XCTAssertTrue(controller.hasTrackedVideoClick);
}

// MARK: - VMI-1733: companion-scoped click event

static NSString * const kCompanionClickEventURL = @"https://companion-click-event.example";
static NSString * const kCompanionCreativeViewEventURL = @"https://companion-creativeview-event.example";

- (HyBidVASTTrackingEvents *)trackingEventsWithURLsByEvent:(NSDictionary<NSString *, NSString *> *)urlsByEvent {
    NSMutableString *xml = [NSMutableString stringWithString:@"<TrackingEvents>"];
    for (NSString *event in urlsByEvent) {
        [xml appendFormat:@"<Tracking event=\"%@\"><![CDATA[%@]]></Tracking>", event, urlsByEvent[event]];
    }
    [xml appendString:@"</TrackingEvents>"];
    HyBidXMLElementEx *element = [[HyBidXMLEx parserWithXML:xml] rootElement];
    XCTAssertNotNil(element);
    return [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:element];
}

// PR 1456 review: the click event carries the OMID click and VIDEO_AD_CLICKED reporting, so it fires once per
// list even when the list declares no click URL.
- (void)test_trackClickEventWithProcessor_withoutClickURL_stillReportsClickEventOnce {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);

    BOOL tracked = [HyBidAutomaticClickTrackingUtil trackClickEventWithProcessor:processor alreadyTracked:NO];
    [HyBidAutomaticClickTrackingUtil trackClickEventWithProcessor:processor alreadyTracked:tracked];

    XCTAssertTrue(tracked);
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
}

- (HyBidEndCard *)companionEndCardWithURLsByEvent:(NSDictionary<NSString *, NSString *> *)urlsByEvent {
    HyBidEndCard *endCard = [[HyBidEndCard alloc] init];
    endCard.type = HyBidEndCardType_HTML;
    endCard.content = @"<html></html>";
    endCard.events = [self trackingEventsWithURLsByEvent:urlsByEvent];
    return endCard;
}

- (DisplayOnlyEndCardView *)displayOnlyEndCardViewWithViewController:(UIViewController *)viewController {
    return [self displayOnlyEndCardViewWithDelegate:mockProtocol(@protocol(HyBidEndCardViewDelegate))
                                     viewController:viewController
                               hasTrackedCompanionClickEvent:NO];
}

- (DisplayOnlyEndCardView *)displayOnlyEndCardViewWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                viewController:(UIViewController *)viewController
                                          hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent {
    HyBidAd *ad = [self automaticClickAdFromTestBundle];
    return (DisplayOnlyEndCardView *)[self endCardViewOfClass:[DisplayOnlyEndCardView class]
                                                            ad:ad
                                                        vastAd:[self vastAdFromAd:ad]
                                                      delegate:delegate
                                                viewController:viewController
                                        hasTrackedEndCardClick:NO
                                          hasTrackedVideoClick:NO
                                          hasTrackedCompanionClickEvent:hasTrackedCompanionClickEvent
                                      hasTrackedCompanionClick:NO];
}

// The displayed companion's TrackingEvents must end up in the end card's own processor.
- (void)test_displayEndCard_loadsCompanionTrackingEventsIntoProcessor {
    UIViewController *viewController = [[UIViewController alloc] init];
    DisplayOnlyEndCardView *endCardView = [self displayOnlyEndCardViewWithViewController:viewController];
    RecordingVASTEventProcessor *processor = [[RecordingVASTEventProcessor alloc] init];
    endCardView.vastEventProcessor = processor;
    HyBidEndCard *endCard = [self companionEndCardWithURLsByEvent:@{ @"click": kCompanionClickEventURL }];

    [endCardView displayEndCard:endCard withCTAButton:nil withViewController:viewController];
    [endCardView.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];

    XCTAssertEqualObjects(processor.sentURLs, @[kCompanionClickEventURL]);
}

// PR 1456 review: an end card without TrackingEvents must not keep the previous companion's events on a reused view.
- (void)test_displayEndCard_withoutTrackingEvents_clearsPreviouslyLoadedEvents {
    UIViewController *viewController = [[UIViewController alloc] init];
    DisplayOnlyEndCardView *endCardView = [self displayOnlyEndCardViewWithViewController:viewController];
    RecordingVASTEventProcessor *processor = [[RecordingVASTEventProcessor alloc] init];
    endCardView.vastEventProcessor = processor;
    [endCardView displayEndCard:[self companionEndCardWithURLsByEvent:@{ @"click": kCompanionClickEventURL }]
                  withCTAButton:nil
             withViewController:viewController];
    HyBidEndCard *endCardWithoutEvents = [[HyBidEndCard alloc] init];
    endCardWithoutEvents.type = HyBidEndCardType_HTML;
    endCardWithoutEvents.content = @"<html></html>";

    [endCardView displayEndCard:endCardWithoutEvents withCTAButton:nil withViewController:viewController];
    [endCardView.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];

    XCTAssertEqual(processor.sentURLs.count, 0);
}

// PR 1456 review: the displayed companion's creativeView fires once, when the creative renders.
- (void)test_endCard_companionCreativeView_firesOnceOnRender {
    UIViewController *viewController = [[UIViewController alloc] init];
    DisplayOnlyEndCardView *endCardView = [self displayOnlyEndCardViewWithViewController:viewController];
    RecordingVASTEventProcessor *processor = [[RecordingVASTEventProcessor alloc] init];
    endCardView.vastEventProcessor = processor;
    [endCardView displayEndCard:[self companionEndCardWithURLsByEvent:@{ @"creativeView": kCompanionCreativeViewEventURL }]
                  withCTAButton:nil
             withViewController:viewController];
    XCTAssertEqual(processor.sentURLs.count, 0);

    [endCardView mraidViewAdReady:(HyBidMRAIDView *)[[RenderedMRAIDViewStub alloc] init]];

    XCTAssertEqualObjects(processor.sentURLs, @[kCompanionCreativeViewEventURL]);
}

// PR 1456 review: a companion that fails to render is never viewed, so its creativeView is not sent.
- (void)test_endCard_companionCreativeView_notSentWhenRenderFails {
    UIViewController *viewController = [[UIViewController alloc] init];
    DisplayOnlyEndCardView *endCardView = [self displayOnlyEndCardViewWithViewController:viewController];
    RecordingVASTEventProcessor *processor = [[RecordingVASTEventProcessor alloc] init];
    endCardView.vastEventProcessor = processor;
    [endCardView displayEndCard:[self companionEndCardWithURLsByEvent:@{ @"creativeView": kCompanionCreativeViewEventURL }]
                  withCTAButton:nil
             withViewController:viewController];

    [endCardView mraidViewAdFailed:nil withError:[NSError errorWithDomain:@"test" code:1 userInfo:nil]];

    XCTAssertEqual(processor.sentURLs.count, 0);
}

// The end card's click-event latch covers the companion list, so the player must keep it apart from the linear one.
- (void)test_endCardSKOverlay_trackedCompanionClickEvent_leavesLinearClickEventLatchOpen {
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:mock([HyBidVASTEventProcessor class])
                                                                                    delegate:mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate))];
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                      processor:mock([HyBidVASTEventProcessor class])
                                                          shouldTriggerAdClick:NO];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    controller.endCardView = endCardView;

    [endCardView skOverlayDidShowOnCreative:YES];

    XCTAssertTrue(endCardView.hasTrackedCompanionClickEvent);
    XCTAssertTrue(controller.hasTrackedCompanionClickEvent);
    XCTAssertFalse(controller.hasTrackedClickEvent);
}

- (void)test_endCardAutoStorekit_trackedCompanionClickEvent_leavesLinearClickEventLatchOpen {
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:mock([HyBidVASTEventProcessor class])
                                                                                    delegate:mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate))];
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:controller
                                                                      processor:mock([HyBidVASTEventProcessor class])
                                                          shouldTriggerAdClick:NO];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    controller.endCardView = endCardView;

    [endCardView fireClicksForAutoStorekit];

    XCTAssertTrue(endCardView.hasTrackedCompanionClickEvent);
    XCTAssertTrue(controller.hasTrackedCompanionClickEvent);
    XCTAssertFalse(controller.hasTrackedClickEvent);
}

// showEndCard hands the end card the companion-scoped latch; a linear click event tracked on the video
// surface must not block the companion click event on the end card.
- (void)test_showEndCard_handsCompanionClickEventLatchToEndCard {
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:mock([HyBidVASTEventProcessor class])
                                                                                    delegate:mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate))];

    controller.hasTrackedClickEvent = YES;
    controller.hasTrackedCompanionClickEvent = NO;
    controller.endCards = [@[[self companionEndCardWithURLsByEvent:@{ @"click": kCompanionClickEventURL }]] mutableCopy];
    [controller showEndCard];
    XCTAssertFalse(controller.endCardView.hasTrackedCompanionClickEvent);

    controller.hasTrackedClickEvent = NO;
    controller.hasTrackedCompanionClickEvent = YES;
    controller.endCards = [@[[self companionEndCardWithURLsByEvent:@{ @"click": kCompanionClickEventURL }]] mutableCopy];
    [controller showEndCard];
    XCTAssertTrue(controller.endCardView.hasTrackedCompanionClickEvent);
}

// The player's processor stays linear when a companion end card shows: the companion's TrackingEvents
// (creativeView, click, close) belong to the end card's own processor, which fires them when the creative renders.
- (void)test_showEndCard_withCompanionEndCard_keepsLinearProcessorOnPlayer {
    HyBidVASTEventProcessor *linearProcessor = mock([HyBidVASTEventProcessor class]);
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:linearProcessor
                                                                                    delegate:mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate))];
    // Runs the production parse over the fixture, whose four companions each declare a creativeView event.
    controller.events = [controller setTrackingEvents:controller.vastArray];
    controller.endCards = [@[[self companionEndCardWithURLsByEvent:@{ @"creativeView": kCompanionCreativeViewEventURL }]] mutableCopy];

    [controller showEndCard];

    XCTAssertEqual(controller.vastEventProcessor, linearProcessor);
    [verifyCount(linearProcessor, never()) trackEventWithType:HyBidVASTAdTrackingEventType_creativeView];
}

- (DisplayOnlyEndCardView *)displayedEndCardViewWithEndCard:(HyBidEndCard *)endCard
                                                    delegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                   processor:(HyBidVASTEventProcessor *)processor
                                        hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent {
    UIViewController *viewController = [[UIViewController alloc] init];
    DisplayOnlyEndCardView *endCardView = [self displayOnlyEndCardViewWithDelegate:delegate
                                                                    viewController:viewController
                                                              hasTrackedCompanionClickEvent:hasTrackedCompanionClickEvent];
    endCardView.vastEventProcessor = processor;
    [endCardView displayEndCard:endCard withCTAButton:nil withViewController:viewController];
    return endCardView;
}

// Acceptance for the ticket fixture: the Linear list declares no click event, the SKOverlay presents over the
// video, twice over the companion end card and once over the custom end card. The companion-declared click
// event fires exactly once; the linear list reports its click event once (OMID) and sends nothing.
- (void)test_skOverlay_videoWithoutLinearClickEvent_thenEndCards_sendsCompanionClickEventOnce {
    HyBidVASTEventProcessor *linearProcessor = mock([HyBidVASTEventProcessor class]);
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:linearProcessor
                                                                                    delegate:mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate))];

    [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
    XCTAssertTrue(controller.hasTrackedClickEvent);

    RecordingVASTEventProcessor *companionProcessor = [[RecordingVASTEventProcessor alloc] init];
    controller.endCardView = [self displayedEndCardViewWithEndCard:[self companionEndCardWithURLsByEvent:@{ @"click": kCompanionClickEventURL }]
                                                          delegate:controller
                                                         processor:companionProcessor
                                              hasTrackedCompanionClickEvent:controller.hasTrackedCompanionClickEvent];
    [controller.endCardView skOverlayDidShowOnCreative:YES];
    [controller.endCardView skOverlayDidShowOnCreative:NO];
    XCTAssertTrue(controller.hasTrackedCompanionClickEvent);

    HyBidEndCard *customEndCard = [[HyBidEndCard alloc] init];
    customEndCard.type = HyBidEndCardType_HTML;
    customEndCard.content = @"<html></html>";
    customEndCard.isCustomEndCard = YES;
    RecordingVASTEventProcessor *customProcessor = [[RecordingVASTEventProcessor alloc] init];
    controller.endCardView = [self displayedEndCardViewWithEndCard:customEndCard
                                                          delegate:controller
                                                         processor:customProcessor
                                              hasTrackedCompanionClickEvent:controller.hasTrackedCompanionClickEvent];
    [controller.endCardView skOverlayDidShowOnCreative:YES];

    XCTAssertEqualObjects(companionProcessor.sentURLs, @[kCompanionClickEventURL]);
    XCTAssertEqual(customProcessor.sentURLs.count, 0);
    [verifyCount(linearProcessor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
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

- (void)test_resetElementsForReplay_resetsAutomaticClickTrackingState {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor delegate:delegate];
    controller.currentEndCard = [[HyBidEndCard alloc] init];
    controller.hasTrackedVideoClick = YES;
    controller.hasTrackedClickEvent = YES;
    controller.hasTrackedCompanionClick = YES;
    controller.hasTrackedCompanionClickEvent = YES;
    controller.trackedEndCards = [NSMutableSet setWithObject:controller.currentEndCard];

    [controller resetElementsForReplay];

    XCTAssertFalse(controller.hasTrackedVideoClick);
    XCTAssertFalse(controller.hasTrackedClickEvent);
    XCTAssertFalse(controller.hasTrackedCompanionClick);
    XCTAssertFalse(controller.hasTrackedCompanionClickEvent);
    XCTAssertEqual(controller.trackedEndCards.count, 0);
    controller.shown = NO;
    HyBidSKAdNetworkViewController.shared.avoidAutoStoreKitPresentationAfterReplay = NO;
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
    // A detached thread, not a global-queue block: the main thread is blocked below, and a saturated
    // GCD pool can delay a dispatch_async past the timeout, failing the test for unrelated reasons.
    [NSThread detachNewThreadWithBlock:^{
        calledOffMain = ![NSThread isMainThread];
        [controller setState:kPNLiteVASTPlayerStateReady];
        // The main thread is blocked below, so a correctly-marshaled transition cannot have run yet.
        stateOnCallingThread = controller.currentState;
        dispatch_semaphore_signal(bgObserved);
    }];
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
    // A detached thread, not a global-queue block: the main thread is blocked below, and a saturated
    // GCD pool can delay a dispatch_async past the timeout, failing the test for unrelated reasons.
    [NSThread detachNewThreadWithBlock:^{
        [controller moviePlayBackDidFinish:note];
        finishedOnCallingThread = controller.isMoviePlaybackFinished;
        dispatch_semaphore_signal(bgObserved);
    }];
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

// MARK: - VMI-1678 skip-offset ceiling removal

- (HyBidAd *)adWithRemoteConfigs:(NSDictionary *)jsondata hasEndCard:(BOOL)hasEndCard {
    NSDictionary *adDictionary = @{
        @"assetgroupid": @15,
        @"assets": @[],
        @"meta": @[ @{@"type": @"remoteconfigs", @"data": @{@"jsondata": jsondata}} ]
    };
    HyBidAdModel *adModel = [[HyBidAdModel alloc] initWithDictionary:adDictionary];
    HyBidAd *ad = [[HyBidAd alloc] initWithData:adModel withZoneID:@"1"];
    ad.hasEndCard = hasEndCard;
    return ad;
}

- (HyBidVASTLinear *)vastLinearWithSkipOffset:(NSString *)skipOffset {
    NSString *xml = [NSString stringWithFormat:@"<Linear skipoffset=\"%@\"><Duration>00:01:00</Duration></Linear>", skipOffset];
    HyBidXMLElementEx *root = [[HyBidXMLEx parserWithXML:xml] rootElement];
    return [[HyBidVASTLinear alloc] initWithInLineXMLElement:root];
}

- (void)test_isValidToShowCustomCountdown_durationAboveSkipOffset_returnsYes {
    HyBidAd *ad = [self adWithRemoteConfigs:@{} hasEndCard:NO];
    TestableVASTPlayerViewController *controller = [[TestableVASTPlayerViewController alloc] initPlayerWithAdModel:ad withAdFormat:HyBidAdFormatInterstitial];
    controller.stubbedDuration = 60;
    controller.skipOffset = [[HyBidSkipOffset alloc] initWithOffset:@45 isCustom:YES];

    XCTAssertTrue([controller isValidToShowCustomCountdown]);
}

- (void)test_isValidToShowCustomCountdown_durationAtOrBelowSkipOffset_returnsNo {
    HyBidAd *ad = [self adWithRemoteConfigs:@{} hasEndCard:NO];
    TestableVASTPlayerViewController *controller = [[TestableVASTPlayerViewController alloc] initPlayerWithAdModel:ad withAdFormat:HyBidAdFormatInterstitial];
    controller.stubbedDuration = 60;
    // Skip offset above (or at) the creative duration: no skip control, close reachable only at natural end.
    controller.skipOffset = [[HyBidSkipOffset alloc] initWithOffset:@500 isCustom:YES];

    XCTAssertFalse([controller isValidToShowCustomCountdown]);
}

- (void)test_determineRewardedSkipOffsetForAd_negativeOffset_fallsBackToDefault {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"rewarded_video_skip_offset": @(-6)} hasEndCard:YES];
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:ad withAdFormat:HyBidAdFormatRewarded];

    [controller determineRewardedSkipOffsetForAd:ad];

    XCTAssertEqual(controller.skipOffset.offset.integerValue, HyBidSkipOffset.DEFAULT_REWARDED_VIDEO_SKIP_OFFSET);
    XCTAssertFalse(controller.skipOffset.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_interstitialWithVASTSkipOffset_isHonoured {
    HyBidAd *ad = [self adWithRemoteConfigs:@{} hasEndCard:YES];
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:ad withAdFormat:HyBidAdFormatInterstitial];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"00:00:12"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 12);
    XCTAssertTrue(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_rewardedNoVASTOffsetWithEndCard_returnsRewardedDefault {
    HyBidAd *ad = [self adWithRemoteConfigs:@{} hasEndCard:YES];
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:ad withAdFormat:HyBidAdFormatRewarded];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@""];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, HyBidSkipOffset.DEFAULT_REWARDED_VIDEO_SKIP_OFFSET);
    XCTAssertFalse(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_rewardedNoVASTOffsetNoEndCard_returnsRewardedDefault {
    HyBidAd *ad = [self adWithRemoteConfigs:@{} hasEndCard:NO];
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:ad withAdFormat:HyBidAdFormatRewarded];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@""];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, HyBidSkipOffset.DEFAULT_REWARDED_VIDEO_SKIP_OFFSET);
    XCTAssertFalse(result.isCustom);
}

// MARK: - VMI-1704 min(VAST, remote config) skip-offset resolution

- (PNLiteVASTPlayerViewController *)interstitialControllerWithRemoteConfigs:(NSDictionary *)jsondata {
    HyBidAd *ad = [self adWithRemoteConfigs:jsondata hasEndCard:YES];
    return [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:ad withAdFormat:HyBidAdFormatInterstitial];
}

- (void)test_resolveSkipOffset_remoteConfigBelowVAST_remoteConfigWins {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@8 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:@5];

    XCTAssertEqual(result.offset.integerValue, 5);
    XCTAssertFalse(result.isCustom);
}

- (void)test_resolveSkipOffset_vastBelowRemoteConfig_vastWins {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@5 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:@8];

    XCTAssertEqual(result.offset.integerValue, 5);
    XCTAssertTrue(result.isCustom);
}

- (void)test_resolveSkipOffset_longVASTOffsetCappedByRemoteConfig {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@120 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:@30];

    XCTAssertEqual(result.offset.integerValue, 30);
    XCTAssertFalse(result.isCustom);
}

- (void)test_resolveSkipOffset_equalValues_vastWins {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@8 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:@8];

    XCTAssertEqual(result.offset.integerValue, 8);
    XCTAssertTrue(result.isCustom);
}

- (void)test_resolveSkipOffset_vastOnly_vastApplies {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@12 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:nil];

    XCTAssertEqual(result.offset.integerValue, 12);
    XCTAssertTrue(result.isCustom);
}

- (void)test_resolveSkipOffset_remoteConfigOnly_remoteConfigApplies {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:nil remoteConfigOffset:@7];

    XCTAssertEqual(result.offset.integerValue, 7);
    XCTAssertFalse(result.isCustom);
}

- (void)test_resolveSkipOffset_bothAbsent_returnsNil {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];

    XCTAssertNil([controller resolveSkipOffsetFromVAST:nil remoteConfigOffset:nil]);
}

- (void)test_resolveSkipOffset_zeroRemoteConfig_actsAsCeiling {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@12 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:@0];

    XCTAssertEqual(result.offset.integerValue, 0);
    XCTAssertFalse(result.isCustom);
}

- (void)test_resolveSkipOffset_zeroRemoteConfigAlone_isGenuineZero {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:nil remoteConfigOffset:@0];

    XCTAssertEqual(result.offset.integerValue, 0);
    XCTAssertFalse(result.isCustom);
}

- (void)test_resolveSkipOffset_negativeRemoteConfig_treatedAsAbsent {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@12 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:@-5];

    XCTAssertEqual(result.offset.integerValue, 12);
    XCTAssertTrue(result.isCustom);
}

// MARK: - VMI-1704 non-numeric VAST skipoffset falls back instead of resolving to 0

- (void)test_convertSkipOffsetFromVASTLinear_nonNumericComponents_fallsBackToRemoteConfig {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{@"video_skip_offset": @12}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"aa:bb:cc"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 12);
    XCTAssertFalse(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_nonNumericComponentsNoRemoteConfig_fallsBackToDefault {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"aa:bb:cc"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET);
    XCTAssertFalse(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_allZeroComponents_isGenuineZero {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{@"video_skip_offset": @12}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"00:00:00"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 0);
    XCTAssertTrue(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_twoPartValue_fallsBackToRemoteConfig {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{@"video_skip_offset": @12}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"00:08"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 12);
    XCTAssertFalse(result.isCustom);
}

- (void)test_resolveSkipOffset_genuineZeroVAST_staysZeroUnderMin {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidSkipOffset *vast = [[HyBidSkipOffset alloc] initWithOffset:@0 isCustom:YES];

    HyBidSkipOffset *result = [controller resolveSkipOffsetFromVAST:vast remoteConfigOffset:@5];

    XCTAssertEqual(result.offset.integerValue, 0);
    XCTAssertTrue(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_leadingWhitespace_stillAccepted {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@" 00:00:05"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 5);
    XCTAssertTrue(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_nonASCIIDigit_fallsBackToRemoteConfig {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{@"video_skip_offset": @12}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"00:00:𝟝"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 12);
    XCTAssertFalse(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_overlongHoursComponent_fallsBackToRemoteConfig {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{@"video_skip_offset": @12}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"9999999999999999999:00:00"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 12);
    XCTAssertFalse(result.isCustom);
}

- (void)test_convertSkipOffsetFromVASTLinear_fractionalSeconds_stillAccepted {
    PNLiteVASTPlayerViewController *controller = [self interstitialControllerWithRemoteConfigs:@{}];
    HyBidVASTLinear *linear = [self vastLinearWithSkipOffset:@"00:00:10.500"];

    HyBidSkipOffset *result = [controller convertSkipOffsetFromVASTLinear:linear];

    XCTAssertEqual(result.offset.integerValue, 10);
    XCTAssertTrue(result.isCustom);
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

- (HyBidAd *)automaticClickAdFromTestBundle {
    return [self automaticClickAdFromTestBundleWithRemoteConfigs:nil];
}

- (HyBidAd *)automaticClickAdFromTestBundleWithRemoteConfigs:(NSDictionary *)remoteConfigs {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"AdResponse" ofType:@"json"];
    XCTAssertNotNil(path);
    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data);

    NSError *error = nil;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    XCTAssertNil(error);
    XCTAssertTrue([json isKindOfClass:[NSMutableDictionary class]]);
    NSMutableArray *metadata = json[@"ads"][0][@"meta"];
    NSMutableDictionary *skAdNetworkData;
    NSMutableDictionary *remoteConfigsData;
    for (NSMutableDictionary *entry in metadata) {
        if ([entry[@"type"] isEqualToString:@"skadnetwork"]) {
            skAdNetworkData = entry[@"data"];
        } else if ([entry[@"type"] isEqualToString:@"remoteconfigs"]) {
            remoteConfigsData = entry[@"data"][@"jsondata"];
        }
    }
    XCTAssertNotNil(skAdNetworkData);
    skAdNetworkData[HyBidSKAdNetworkParameter.click] = @YES;
    if (remoteConfigs.count > 0) {
        XCTAssertNotNil(remoteConfigsData);
        [remoteConfigsData addEntriesFromDictionary:remoteConfigs];
    }

    PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:json];
    XCTAssertEqual(response.ads.count, 1);
    HyBidAd *ad = [[HyBidAd alloc] initWithData:response.ads.firstObject withZoneID:@"4"];
    XCTAssertTrue(ad.vast.length > 0);
    XCTAssertTrue([ad.vast containsString:@"<ClickTracking"]);
    XCTAssertTrue([[ad getSkAdNetworkModel].productParameters[HyBidSKAdNetworkParameter.click] boolValue]);
    return ad;
}

- (PNLiteVASTPlayerViewController *)automaticClickControllerWithProcessor:(HyBidVASTEventProcessor *)processor
                                                                  delegate:(NSObject<PNLiteVASTPlayerViewControllerDelegate> *)delegate {
    return [self automaticClickControllerWithProcessor:processor delegate:delegate remoteConfigs:nil];
}

- (PNLiteVASTPlayerViewController *)automaticClickControllerWithProcessor:(HyBidVASTEventProcessor *)processor
                                                                  delegate:(NSObject<PNLiteVASTPlayerViewControllerDelegate> *)delegate
                                                             remoteConfigs:(NSDictionary *)remoteConfigs {
    HyBidAd *ad = [self automaticClickAdFromTestBundleWithRemoteConfigs:remoteConfigs];
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:ad
                                                                                                 withAdFormat:HyBidAdFormatInterstitial];
    controller.vastArray = @[[ad.vast dataUsingEncoding:NSUTF8StringEncoding]];
    controller.vastEventProcessor = processor;
    controller.delegate = delegate;
    [controller setValue:nil forKey:@"skAdModel"];
    return controller;
}

- (HyBidVASTAd *)vastAdFromAd:(HyBidAd *)ad {
    HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:ad.vast];
    NSArray *elements = [[parser rootElement] query:@"Ad"];
    XCTAssertTrue(elements.count > 0);
    return [[HyBidVASTAd alloc] initWithXMLElement:elements.firstObject];
}

- (NSArray<NSString *> *)trackingClickURLsForController:(PNLiteVASTPlayerViewController *)controller {
    NSArray<NSString *> *trackingClickURLs = [controller gettingTrackingAndThroughClickURL][@"trackingClickURLs"];
    XCTAssertEqual(trackingClickURLs.count, 3);
    XCTAssertEqualObjects(trackingClickURLs.firstObject, @"https://backend.europe-west4gcp0.pubnative.net/mockdsp/v1/tracker/clickTracking");
    return trackingClickURLs;
}

- (void)verifyAutomaticClickTrackingWithInvocations:(void (^)(PNLiteVASTPlayerViewController *controller))invocations
                               delegateVerification:(void (^)(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate))delegateVerification {
    [self verifyAutomaticClickTrackingWithRemoteConfigs:nil
                                    expectedTrackedClicks:1
                                              invocations:invocations
                                     delegateVerification:delegateVerification];
}

- (void)verifyAutomaticClickTrackingWithRemoteConfigs:(NSDictionary *)remoteConfigs
                                expectedTrackedClicks:(NSUInteger)expectedTrackedClicks
                                          invocations:(void (^)(PNLiteVASTPlayerViewController *controller))invocations
                                 delegateVerification:(void (^)(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate))delegateVerification {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate = mockProtocol(@protocol(PNLiteVASTPlayerViewControllerDelegate));
    PNLiteVASTPlayerViewController *controller = [self automaticClickControllerWithProcessor:processor
                                                                                    delegate:delegate
                                                                               remoteConfigs:remoteConfigs];
    NSArray *trackingClickURLs = [self trackingClickURLsForController:controller];

    invocations(controller);

    [verifyCount(processor, times(expectedTrackedClicks)) sendVASTUrls:trackingClickURLs withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(expectedTrackedClicks)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    delegateVerification(delegate);
}

- (HyBidEndCardView *)automaticClickEndCardViewWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                  processor:(HyBidVASTEventProcessor *)processor
                                      shouldTriggerAdClick:(BOOL)shouldTriggerAdClick {
    return [self automaticClickEndCardViewWithDelegate:delegate
                                             processor:processor
                                 shouldTriggerAdClick:shouldTriggerAdClick
                               hasTrackedEndCardClick:NO
                                 hasTrackedVideoClick:NO
                                 hasTrackedCompanionClickEvent:NO
                             hasTrackedCompanionClick:NO];
}

- (HyBidEndCardView *)automaticClickEndCardViewWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                  processor:(HyBidVASTEventProcessor *)processor
                                      shouldTriggerAdClick:(BOOL)shouldTriggerAdClick
                                    hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick
                                      hasTrackedVideoClick:(BOOL)hasTrackedVideoClick
                                      hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent
                                  hasTrackedCompanionClick:(BOOL)hasTrackedCompanionClick {
    return [self automaticClickEndCardViewWithAd:[self automaticClickAdFromTestBundle]
                                        delegate:delegate
                                       processor:processor
                            shouldTriggerAdClick:shouldTriggerAdClick
                          hasTrackedEndCardClick:hasTrackedEndCardClick
                            hasTrackedVideoClick:hasTrackedVideoClick
                            hasTrackedCompanionClickEvent:hasTrackedCompanionClickEvent
                        hasTrackedCompanionClick:hasTrackedCompanionClick];
}

- (HyBidEndCardView *)automaticClickEndCardViewContinuingFromController:(PNLiteVASTPlayerViewController *)controller
                                                              processor:(HyBidVASTEventProcessor *)processor
                                                  shouldTriggerAdClick:(BOOL)shouldTriggerAdClick
                                                hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick {
    return [self automaticClickEndCardViewWithDelegate:controller
                                             processor:processor
                                 shouldTriggerAdClick:shouldTriggerAdClick
                               hasTrackedEndCardClick:hasTrackedEndCardClick
                                 hasTrackedVideoClick:controller.hasTrackedVideoClick
                                 hasTrackedCompanionClickEvent:controller.hasTrackedCompanionClickEvent
                             hasTrackedCompanionClick:controller.hasTrackedCompanionClick];
}

- (HyBidEndCardView *)automaticClickEndCardViewWithAd:(HyBidAd *)ad
                                             delegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                            processor:(HyBidVASTEventProcessor *)processor
                                 shouldTriggerAdClick:(BOOL)shouldTriggerAdClick
                               hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick
                                 hasTrackedVideoClick:(BOOL)hasTrackedVideoClick
                                 hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent
                             hasTrackedCompanionClick:(BOOL)hasTrackedCompanionClick {
    HyBidEndCardView *endCardView = [self endCardViewOfClass:[HyBidEndCardView class]
                                                          ad:ad
                                                      vastAd:nil
                                                    delegate:delegate
                                              viewController:[[UIViewController alloc] init]
                                      hasTrackedEndCardClick:hasTrackedEndCardClick
                                        hasTrackedVideoClick:hasTrackedVideoClick
                                        hasTrackedCompanionClickEvent:hasTrackedCompanionClickEvent
                                    hasTrackedCompanionClick:hasTrackedCompanionClick];
    HyBidEndCard *endCard = [[HyBidEndCard alloc] init];
    endCard.content = shouldTriggerAdClick ? @"https://customendcard.verve.com/click" : @"<html></html>";
    endCard.clickTrackings = @[@"https://companion-click.example"];
    endCard.isCustomEndCard = shouldTriggerAdClick;
    endCardView.endCard = endCard;
    endCardView.vastEventProcessor = processor;
    return endCardView;
}

// The only place the 15-argument HyBidEndCardView initializer is spelled out.
- (HyBidEndCardView *)endCardViewOfClass:(Class)viewClass
                                      ad:(HyBidAd *)ad
                                  vastAd:(HyBidVASTAd *)vastAd
                                delegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                          viewController:(UIViewController *)viewController
                  hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick
                    hasTrackedVideoClick:(BOOL)hasTrackedVideoClick
                    hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent
                hasTrackedCompanionClick:(BOOL)hasTrackedCompanionClick {
    return [[viewClass alloc] initWithDelegate:delegate
                            withViewController:viewController
                                        withAd:ad
                                    withVASTAd:vastAd
                                isInterstitial:YES
                                 iconXposition:nil
                                 iconYposition:nil
                                withSkipButton:NO
                   vastCompanionsClicksThrough:@[]
                  vastCompanionsClicksTracking:@[]
                       vastVideoClicksTracking:@[]
                        hasTrackedEndCardClick:hasTrackedEndCardClick
                          hasTrackedVideoClick:hasTrackedVideoClick
                          hasTrackedCompanionClickEvent:hasTrackedCompanionClickEvent
                      hasTrackedCompanionClick:hasTrackedCompanionClick];
}

- (HyBidEndCardView *)suppressedAutoClickEndCardViewWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                       processor:(HyBidVASTEventProcessor *)processor {
    return [self endCardViewWithSuppressAutoClickValue:@YES delegate:delegate processor:processor];
}

- (HyBidEndCardView *)endCardViewWithSuppressAutoClickValue:(id)suppressAutoClickValue
                                                   delegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
                                                  processor:(HyBidVASTEventProcessor *)processor {
    NSDictionary *remoteConfigs = suppressAutoClickValue ? @{kSuppressAutoClickConfigKey: suppressAutoClickValue} : nil;
    return [self automaticClickEndCardViewWithAd:[self automaticClickAdFromTestBundleWithRemoteConfigs:remoteConfigs]
                                        delegate:delegate
                                       processor:processor
                            shouldTriggerAdClick:NO
                          hasTrackedEndCardClick:NO
                            hasTrackedVideoClick:NO
                            hasTrackedCompanionClickEvent:NO
                        hasTrackedCompanionClick:NO];
}

- (void)verifyEndCardClickSentOnceWithInvocations:(void (^)(HyBidEndCardView *endCardView))invocations {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    NSArray *clickTrackings = endCardView.endCard.clickTrackings;

    invocations(endCardView);

    [verifyCount(processor, times(1)) sendVASTUrls:clickTrackings withType:HyBidVASTClickTrackingURL];
}

- (void)verifyEndCardVideoClickSentOnceWithInvocations:(void (^)(HyBidEndCardView *endCardView))invocations {
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidEndCardViewDelegate> *delegate = mockProtocol(@protocol(HyBidEndCardViewDelegate));
    HyBidEndCardView *endCardView = [self automaticClickEndCardViewWithDelegate:delegate
                                                                      processor:processor
                                                          shouldTriggerAdClick:NO];
    NSArray *videoClickTrackings = @[@"https://video-click.example"];
    endCardView.vastAd = [self vastAdFromAd:[self automaticClickAdFromTestBundle]];
    endCardView.vastVideoClicksTracking = videoClickTrackings;

    invocations(endCardView);

    [verifyCount(processor, times(1)) sendVASTUrls:videoClickTrackings withType:HyBidVASTClickTrackingURL];
    [verifyCount(processor, times(1)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
}

- (void)verifyToggleMatrixWithSuppressAutoClickValue:(id)suppressAutoClickValue
                               expectedTrackedClicks:(NSUInteger)expectedTrackedClicks {
    for (NSNumber *autoStoreKitEnabled in @[@YES, @NO]) {
        for (NSNumber *skOverlayEnabled in @[@YES, @NO]) {
            NSString *combination = [NSString stringWithFormat:@"AutoStoreKit %@ / SKOverlay %@",
                                     autoStoreKitEnabled.boolValue ? @"on" : @"off",
                                     skOverlayEnabled.boolValue ? @"on" : @"off"];
            [XCTContext runActivityNamed:combination block:^(id<XCTActivity> activity) {
                [self verifyAutomaticClickTrackingWithRemoteConfigs:@{kSDKAutoStoreKitConfigKey: autoStoreKitEnabled,
                                                                      kSKOverlayEnabledConfigKey: skOverlayEnabled,
                                                                      kSuppressAutoClickConfigKey: suppressAutoClickValue}
                                              expectedTrackedClicks:expectedTrackedClicks
                                                        invocations:^(PNLiteVASTPlayerViewController *controller) {
                    [controller trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
                    [controller trackClickForAutoStorekit:HyBidStorekitAutomaticClickVideo];
                } delegateVerification:^(NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate) {
                    NSUInteger expectedDelegateClicks = expectedTrackedClicks > 0 ? 1 : 0;
                    [verifyCount(delegate, times(expectedDelegateClicks)) vastPlayerDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo];
                    [verifyCount(delegate, times(expectedDelegateClicks)) vastPlayerDidShowStorekitWithClickType:HyBidStorekitAutomaticClickVideo];
                }];
            }];
        }
    }
}

@end
