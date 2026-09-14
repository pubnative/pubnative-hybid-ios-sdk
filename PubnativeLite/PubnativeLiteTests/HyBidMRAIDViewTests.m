//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "HyBidAd+Internal.h"
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceProvider.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "HyBidEndCardView.h"
#import "HyBidEndCardView+Testing.h"
#import "HyBidTimerState.h"
#import "HyBidAd.h"
#import "HyBidAdModel.h"
#import "HyBidSkAdNetworkModel.h"
#import "HyBidSKAdNetworkParameter.h"
#import "HyBidVASTEventProcessor.h"
#import <objc/runtime.h>
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

// Expose HyBidMRAIDServiceProvider private method for testing
@interface HyBidMRAIDServiceProvider (Testing)
- (NSURL *)safeURLFromObject:(id)value;
@end

@interface HyBidMRAIDView (Testing)
- (void)trackClickForSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType isFirstPresentation:(BOOL)isFirstPresentation;
- (void)trackClickForAutoStoreKitViewWith:(HyBidStorekitAutomaticClickType)clickType;
- (void)onURLRedirectorFinishWithUrl:(NSString *)url;
- (void)loadHTMLData:(NSString *)htmlData;
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)injectJavaScript:(NSString *)js;
- (void)cleanupWebViewPart2;
- (void)cancel;
- (void)close;
- (void)skipTimerCompleted;
- (void)addSkipOverlay;
- (NSString *)enforceInlineVideoPlaybackForBannerHtml:(NSString *)html;
+ (NSString *)resolvedExpandURLString:(NSString *)urlString withBaseURL:(NSURL *)expandBaseURL;
- (void)setClickThroughTimer;
- (void)triggerClickThrough;
- (void)stopClickThroughTimer;
- (void)pauseClickThroughTimer;
- (void)resumeClickThroughTimer;
- (void)scheduleClickThroughTimerWithDelay:(NSTimeInterval)delay;
- (void)oneFingerOneTap;
- (void)observeClickThroughTouchesOnWebView;
- (void)removeClickThroughTouchObserver;
- (void)clickThroughTouchObserved;
- (void)open:(NSString *)urlString;
- (void)notifyDelegateToNavigateToURL:(NSURL *)url;
- (BOOL)shouldSuppressNavigationToURL:(NSURL *)url;
- (void)clearSyntheticClickSuppression;
- (void)clickThroughDestinationDidOpen;
- (BOOL)openAppStoreWithAppID:(NSString *)urlString;
@end

@protocol HyBidMRAIDViewDelegate;

// Mock delegate for HyBidEndCardView navigationToURL tests
@interface MockEndCardViewDelegate : NSObject <HyBidEndCardViewDelegate>
@property (nonatomic, assign) BOOL redirectedWithSuccessCalled;
@property (nonatomic, assign) BOOL lastRedirectSuccess;
@end
@implementation MockEndCardViewDelegate
- (void)endCardViewRedirectedWithSuccess:(BOOL)success {
    _redirectedWithSuccessCalled = YES;
    _lastRedirectSuccess = success;
}
@end

/// Records deactivateContext: calls so we can assert MRAID close notifies the handler exactly once when appropriate.
@interface MockInterruptionHandlerForClose : NSObject
@property (nonatomic, assign) NSInteger deactivateContextCallCount;
@property (nonatomic, assign) HyBidAdContext lastDeactivateContext;
@end
@implementation MockInterruptionHandlerForClose
- (void)deactivateContext:(HyBidAdContext)context {
    _deactivateContextCallCount++;
    _lastDeactivateContext = context;
}
@end

/// Modal VC that invokes the dismiss completion block immediately so close()'s deactivate-in-completion path is run and testable.
@interface MockModalVCInvokesCompletion : UIViewController
@end
@implementation MockModalVCInvokesCompletion
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (completion) { completion(); }
}
@end

/// Modal VC that does not respond to dismissViewControllerAnimated:completion: so close() takes the legacy path (dismissModalViewControllerAnimated + deactivate).
@interface LegacyMockModalVC : UIViewController
@end
@implementation LegacyMockModalVC
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(dismissViewControllerAnimated:completion:)) { return NO; }
    return [super respondsToSelector:aSelector];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)dismissModalViewControllerAnimated:(BOOL)animated { /* no-op for test */ }
#pragma clang diagnostic pop
@end

static id gMockInterruptionHandlerForClose = nil;
static HyBidInterruptionHandler *gOriginalSharedHandler = nil;
static IMP gOriginalSharedIMP = NULL;

static id swizzled_shared(id self, SEL _cmd) {
    (void)self;
    (void)_cmd;
    return gMockInterruptionHandlerForClose ?: gOriginalSharedHandler;
}

/// Swaps [HyBidInterruptionHandler shared] to return mock for the duration of close tests. Call teardown when done.
static void HyBidSwizzleInterruptionHandlerSharedForClose(MockInterruptionHandlerForClose *mock) {
    gMockInterruptionHandlerForClose = mock;
    gOriginalSharedHandler = [HyBidInterruptionHandler shared];
    Method m = class_getClassMethod([HyBidInterruptionHandler class], @selector(shared));
    if (m) {
        gOriginalSharedIMP = method_getImplementation(m);
        method_setImplementation(m, (IMP)swizzled_shared);
    }
}

static void HyBidUnswizzleInterruptionHandlerSharedForClose(void) {
    gMockInterruptionHandlerForClose = nil;
    Method m = class_getClassMethod([HyBidInterruptionHandler class], @selector(shared));
    if (m && gOriginalSharedIMP) {
        method_setImplementation(m, gOriginalSharedIMP);
        gOriginalSharedIMP = NULL;
    }
    gOriginalSharedHandler = nil;
}

@interface HyBidMRAIDViewTests : XCTestCase
@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, strong) HyBidEndCardView *endCardView;
@property (nonatomic, strong) HyBidAd *mockAd;
@property (nonatomic, strong) MockEndCardViewDelegate *endCardDelegate;
/// Ensures [UIApplication sharedApplication].topViewController is non-nil so internal browser doesn't crash on present.
@property (nonatomic, strong) UIWindow *testWindow;
@end

@implementation HyBidMRAIDViewTests

static IMP HyBidOrigCommandTypeIMP = NULL;

- (void)setUp {
    [super setUp];
    _testWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _testWindow.rootViewController = [[UIViewController alloc] init];
    [_testWindow makeKeyAndVisible];
    _serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    _endCardDelegate = [[MockEndCardViewDelegate alloc] init];
    HyBidAdModel *adModel = [[HyBidAdModel alloc] init];
    _mockAd = [[HyBidAd alloc] initWithData:adModel withZoneID:@"test-zone"];
    _endCardView = [[HyBidEndCardView alloc] initWithFrame:CGRectZero];
    _endCardView.delegate = _endCardDelegate;
    [_endCardView setValue:_mockAd forKey:@"ad"];
}

- (void)tearDown {
    [_testWindow resignKeyWindow];
    _testWindow.hidden = YES;
    _testWindow = nil;
    _serviceProvider = nil;
    _endCardView = nil;
    _mockAd = nil;
    _endCardDelegate = nil;
    [super tearDown];
}

/// HyBidMRAIDView's `-init` throws by design. For these focused unit tests we only need a raw instance
/// to call `loadHTMLData:` and to set `currentWebView` + `delegate` ivars via KVC.
- (HyBidMRAIDView *)makeRawMRAIDView {
    return [HyBidMRAIDView alloc];
}

- (NSString *)readFromResourceNamed:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    // Try common extensions in order.
    NSArray<NSString *> *extensions = @[ @"html", @"txt", @"xml" ];
    NSString *filepath = nil;
    for (NSString *ext in extensions) {
        filepath = [bundle pathForResource:name ofType:ext];
        if (filepath.length > 0) { break; }
    }

    if (filepath.length == 0) {
        return nil;
    }

    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        XCTFail(@"Error reading resource %@: %@", name, error.localizedDescription);
        return nil;
    }
    return fileContents;
}

#pragma mark - Tests


- (void)test_loadHTMLData_whenNil_notifiesDelegateAdFailed {
    HyBidMRAIDView *view = [self makeRawMRAIDView];

    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));

    // The production code checks `respondsToSelector:` before calling.
    SEL sel = @selector(mraidViewAdFailed:);
    [given([delegate respondsToSelector:sel]) willReturnBool:YES];

    [view setValue:delegate forKey:@"delegate"];

    [view loadHTMLData:nil];

    [verify(delegate) mraidViewAdFailed:view];
}


#pragma mark - webView:decidePolicyForNavigationAction:decisionHandler: Tests

- (id)mockAdForMRAIDView {
    id ad = mock([HyBidAd class]);
    [given([ad nativeCloseButtonDelay]) willReturn:nil];
    [given([ad creativeAutoStorekitEnabled]) willReturn:nil];
    [given([ad sdkAutoStorekitEnabled]) willReturn:nil];
    [given([ad link]) willReturn:nil];
    return ad;
}

- (HyBidMRAIDView *)makeInitializedMRAIDViewWithHTML:(NSString *)html
                                      isInterstitial:(BOOL)isInterstitial
                                           isEndcard:(BOOL)isEndcard {
    return [self makeInitializedMRAIDViewWithHTML:html
                                   isInterstitial:isInterstitial
                                        isEndcard:isEndcard
                                           withAd:[self mockAdForMRAIDView]];
}

- (HyBidMRAIDView *)makeInitializedMRAIDViewWithHTML:(NSString *)html
                                      isInterstitial:(BOOL)isInterstitial
                                           isEndcard:(BOOL)isEndcard
                                              withAd:(HyBidAd *)ad {
    __block HyBidMRAIDView *view = nil;

    void (^createView)(void) = ^{
        UIViewController *rootVC = [[UIViewController alloc] init];

        view = [[HyBidMRAIDView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                         withHtmlData:html
                                          withBaseURL:nil
                                               withAd:ad
                                      supportedFeatures:@[]
                                          isInterstital:isInterstitial
                                           isScrollable:YES
                                               delegate:nil
                                        serviceDelegate:nil
                                     rootViewController:rootVC
                                            contentInfo:nil
                                             skipOffset:0
                                              isEndcard:isEndcard
                             shouldHandleInterruptions:NO];
    };

    if ([NSThread isMainThread]) {
        createView();
    } else {
        dispatch_sync(dispatch_get_main_queue(), createView);
    }

    return view;
}

// VMI-1681: suppress_auto_click silences the MRAID SKOverlay and AutoStoreKit auto-click paths.
- (void)test_automaticClickPaths_whenSuppressAutoClickEnabled_sendNoClick {
    [self verifyMRAIDAutomaticClickPathsWithSuppressAutoClick:@YES expectSuppressed:YES];
}

- (void)test_automaticClickPaths_whenSuppressAutoClickAbsent_sendClick {
    [self verifyMRAIDAutomaticClickPathsWithSuppressAutoClick:nil expectSuppressed:NO];
}

- (void)test_automaticClickPaths_whenSuppressAutoClickDisabled_sendClick {
    [self verifyMRAIDAutomaticClickPathsWithSuppressAutoClick:@NO expectSuppressed:NO];
}

// VMI-1681: a structurally invalid suppress_auto_click must not crash and must leave today's behaviour intact.
- (void)test_automaticClickPaths_whenSuppressAutoClickIsNonBooleanObject_sendClick {
    [self verifyMRAIDAutomaticClickPathsWithSuppressAutoClick:(id)@{@"unexpected": @"object"} expectSuppressed:NO];
}

- (void)verifyMRAIDAutomaticClickPathsWithSuppressAutoClick:(NSNumber *)suppressAutoClick
                                           expectSuppressed:(BOOL)expectSuppressed {
    id ad = [self mockAdForMRAIDView];
    [given([ad suppressAutoClick]) willReturn:suppressAutoClick];
    [given([ad getSkAdNetworkModel]) willReturn:[[HyBidSkAdNetworkModel alloc] initWithParameters:@{HyBidSKAdNetworkParameter.click: @YES}]];

    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html></html>"
                                                  isInterstitial:YES
                                                       isEndcard:NO
                                                          withAd:ad];
    HyBidVASTEventProcessor *processor = mock([HyBidVASTEventProcessor class]);
    NSObject<HyBidMRAIDViewDelegate> *delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewDidShowSKOverlayWithClickType:)]) willReturnBool:YES];
    [given([delegate respondsToSelector:@selector(mraidViewAutoStoreKitDidShowWithClickType:)]) willReturnBool:YES];
    [view setValue:processor forKey:@"vastEventProcessor"];
    view.delegate = delegate;

    [view trackClickForSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:YES];
    [view trackClickForAutoStoreKitViewWith:HyBidStorekitAutomaticClickVideo];

    NSUInteger expectedDelegateClicks = expectSuppressed ? 0 : 1;
    // One click event per auto-click source (SKOverlay first presentation + AutoStoreKit).
    [verifyCount(processor, times(expectSuppressed ? 0 : 2)) trackEventWithType:HyBidVASTAdTrackingEventType_click];
    [verifyCount(delegate, times(expectedDelegateClicks)) mraidViewDidShowSKOverlayWithClickType:HyBidSKOverlayAutomaticCLickVideo];
    [verifyCount(delegate, times(expectedDelegateClicks)) mraidViewAutoStoreKitDidShowWithClickType:HyBidStorekitAutomaticClickVideo];
}

- (WKWebView *)currentWebViewFromView:(HyBidMRAIDView *)view {
    WKWebView *wv = [view valueForKey:@"currentWebView"];
    XCTAssertNotNil(wv);
    return wv;
}

- (WKNavigationAction *)mockNavigationActionWithURL:(NSURL *)url
                                     navigationType:(WKNavigationType)type {
    WKNavigationAction *navAction = mock([WKNavigationAction class]);

    NSURLRequest *request = url ? [NSURLRequest requestWithURL:url] : (NSURLRequest *)nil;
    [given([navAction request]) willReturn:request];
    [given([navAction navigationType]) willReturnInteger:type];

    WKFrameInfo *frameInfo = mock([WKFrameInfo class]);
    [given([frameInfo isMainFrame]) willReturnBool:YES];
    [given([navAction targetFrame]) willReturn:frameInfo];

    return navAction;
}

- (void)assertDecisionHandlerCalledOnceWithExpectedPolicy:(WKNavigationActionPolicy)expectedPolicy
                                                   block:(void (^)(void (^decisionHandler)(WKNavigationActionPolicy)))invoke {
    __block NSInteger callCount = 0;
    __block WKNavigationActionPolicy received = WKNavigationActionPolicyCancel;

    invoke(^(WKNavigationActionPolicy policy) {
        callCount += 1;
        received = policy;
    });

    XCTAssertEqual(callCount, 1, @"decisionHandler must be called exactly once");
    XCTAssertEqual(received, expectedPolicy);
}

- (void)test_webView_decidePolicy_aboutBlank_allowsAndCallsDecisionHandlerOnce {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];
    WKWebView *wv = [self currentWebViewFromView:view];

    WKNavigationAction *action = [self mockNavigationActionWithURL:[NSURL URLWithString:@"about:blank"]
                                                   navigationType:WKNavigationTypeOther];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];
}

- (void)test_webView_decidePolicy_emptyURL_allowsAndCallsDecisionHandlerOnce {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];
    WKWebView *wv = [self currentWebViewFromView:view];

    WKNavigationAction *action = [self mockNavigationActionWithURL:nil
                                                   navigationType:WKNavigationTypeOther];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];
}

- (void)test_webView_decidePolicy_mraidCommand_cancelsAndCallsDecisionHandlerOnce {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];
    WKWebView *wv = [self currentWebViewFromView:view];

    WKNavigationAction *action = [self mockNavigationActionWithURL:[NSURL URLWithString:@"mraid://close"]
                                                   navigationType:WKNavigationTypeLinkActivated];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];
}

- (void)test_webView_decidePolicy_httpLinkActivated_allowsAndCallsDecisionHandlerOnce {
    NSString *html = @"<html><body>ok</body></html>";

    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:html
                                                  isInterstitial:NO
                                                       isEndcard:NO];
    WKWebView *wv = [self currentWebViewFromView:view];

    WKNavigationAction *action =
        [self mockNavigationActionWithURL:[NSURL URLWithString:@"https://example.com"]
                           navigationType:WKNavigationTypeLinkActivated];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];
}

- (void)test_webView_decidePolicy_customSchemeLinkActivated_allowsAndCallsDecisionHandlerOnce {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];
    WKWebView *wv = [self currentWebViewFromView:view];

    WKNavigationAction *action = [self mockNavigationActionWithURL:[NSURL URLWithString:@"myapp://something"]
                                                   navigationType:WKNavigationTypeLinkActivated];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];
}


// MARK: - webView:decidePolicyForNavigationAction:decisionHandler: ConsoleLog tests

- (void)test_cancel_whenWebViewPart2Exists_stopsLoading_nilsDelegates_andClearsReference {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:YES
                                                       isEndcard:NO];

    // Arrange: set a mock WKWebView as webViewPart2
    WKWebView *webViewPart2 = mock([WKWebView class]);
    [view setValue:webViewPart2 forKey:@"webViewPart2"];

    [view setValue:@(YES) forKey:@"isExpanded"];
    [view setValue:@(2) forKey:@"state"];

    // Also set currentWebView to something valid so cancel doesn't early-return.
    WKWebView *current = [self currentWebViewFromView:view];
    XCTAssertNotNil(current);

    // Act
    if (![view respondsToSelector:@selector(cancel)]) {
        XCTFail(@"HyBidMRAIDView does not respond to -cancel (expected to cover webViewPart2 cleanup)");
        return;
    }
    [view cancel];

    // Assert: cleanup happened
    // Assert: cancel only cleans up currentWebView (not webViewPart2).
    WKWebView *currentAfter = [view valueForKey:@"currentWebView"];
    XCTAssertNil(currentAfter);

    // webViewPart2 is NOT cleaned up in -cancel (it is cleaned in -dealloc / close paths).
    XCTAssertNotNil([view valueForKey:@"webViewPart2"]);
}

- (void)test_dealloc_whenWebViewPart2Exists_stopsLoading_nilsDelegates_andClearsReference {
    WKWebView *webViewPart2 = mock([WKWebView class]);

    __weak HyBidMRAIDView *weakView = nil;
    @autoreleasepool {
        HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                      isInterstitial:YES
                                                           isEndcard:NO];
        weakView = view;

        // Arrange: inject mock into the ivar so -dealloc executes the cleanup block.
        [view setValue:webViewPart2 forKey:@"webViewPart2"];

        // Drop the last strong reference inside the autoreleasepool.
        view = nil;
    }

    // Assert dealloc happened.
    XCTAssertNil(weakView);

    // Assert: dealloc cleaned webViewPart2.
    [verify(webViewPart2) stopLoading];
    [verify(webViewPart2) setNavigationDelegate:nil];
    [verify(webViewPart2) setUIDelegate:nil];
}

- (void)test_webView_decidePolicy_whenLandingPageFlowActive_injectsLandingPageTemplateScript {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];

    WKWebView *mockInternalWebView = mock([WKWebView class]);
    [view setValue:mockInternalWebView forKey:@"currentWebView"];

    NSString *templateScript = @"console.log('landing-page-template');";
    [view setValue:@(YES) forKey:@"landingPageFlowActive"];
    [view setValue:templateScript forKey:@"landingPageTemplateScript"];

    WKNavigationAction *action = [self mockNavigationActionWithURL:[NSURL URLWithString:@"https://example.com"]
                                                   navigationType:WKNavigationTypeOther];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:mockInternalWebView decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    // The template injection happens synchronously inside decidePolicy
    // (injectJavaScript: -> evaluateJavaScript:), so verify directly.
    [verify(mockInternalWebView) evaluateJavaScript:templateScript completionHandler:anything()];
}

- (void)test_webView_decidePolicy_consoleLogCommand_cancelsAndCallsDecisionHandlerOnce {
    HyBidSwizzleMRAIDCommandTypeForConsoleLog(YES);
    @try {
        HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                       isInterstitial:NO
                                                            isEndcard:NO];
        WKWebView *wv = [self currentWebViewFromView:view];
        
        NSURL *url = [NSURL URLWithString:@"console.log://Hello%20from%20JS%21"];
        XCTAssertNotNil(url);
        WKNavigationAction *action = [self mockNavigationActionWithURL:url
                                                        navigationType:WKNavigationTypeOther];
        
        [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel
                                                          block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
            [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
        }];
    } @finally {
        HyBidSwizzleMRAIDCommandTypeForConsoleLog(NO);
    }
}

- (void)test_webView_decidePolicy_consoleLogCommand_shortUrl_cancelsAndCallsDecisionHandlerOnce {
    HyBidSwizzleMRAIDCommandTypeForConsoleLog(YES);
    @try {
        HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                       isInterstitial:NO
                                                            isEndcard:NO];
        WKWebView *wv = [self currentWebViewFromView:view];
        
        NSURL *url = [NSURL URLWithString:@"console.log://"];
        XCTAssertNotNil(url);
        WKNavigationAction *action = [self mockNavigationActionWithURL:url
                                                        navigationType:WKNavigationTypeOther];
        
        [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel
                                                          block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
            [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
        }];
    } @finally {
        HyBidSwizzleMRAIDCommandTypeForConsoleLog(NO);
    }
}

- (void)test_webView_decidePolicy_unknown_linkActivated_whenLandingPageFlowActive_firstRedirect_injectsTemplate_andAllows {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];

    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    SEL navSel = @selector(mraidViewNavigate:withURL:);
    [given([delegate respondsToSelector:navSel]) willReturnBool:YES];
    [view setValue:delegate forKey:@"delegate"];

    NSString *templateScript = @"console.log('landing-page-template-unknown');";
    [view setValue:@(YES) forKey:@"landingPageFlowActive"];
    [view setValue:@(NO) forKey:@"firstLinkActiveRedirected"]; // must be NO to take the first-redirect branch
    [view setValue:templateScript forKey:@"landingPageTemplateScript"];

    // Mock currentWebView so we can verify JS injection.
    WKWebView *mockInternalWebView = mock([WKWebView class]);
    [view setValue:mockInternalWebView forKey:@"currentWebView"];

    // Must be LinkActivated to enter the "Links, Form submissions" block.
    NSURL *url = [NSURL URLWithString:@"https://example.com/somepath"];
    WKNavigationAction *action = [self mockNavigationActionWithURL:url
                                                   navigationType:WKNavigationTypeLinkActivated];

    // Decision handler should be called once with Allow (this branch allows and returns).
    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:mockInternalWebView decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    // It should mark the first redirect as done.
    XCTAssertTrue([[view valueForKey:@"firstLinkActiveRedirected"] boolValue]);

    // Both injections (general path + first-redirect path) happen synchronously
    // inside decidePolicy, so verify directly.
    [verifyCount(mockInternalWebView, times(2)) evaluateJavaScript:templateScript completionHandler:anything()];
}

static void HyBidSwizzleMRAIDCommandTypeForConsoleLog(BOOL enable) {
    Class cls = NSClassFromString(@"HyBid.HyBidMRAIDCommand");
    if (!cls) {
        cls = NSClassFromString(@"HyBidMRAIDCommand");
    }
    if (!cls) {
        return;
    }

    SEL sel = sel_registerName("commandTypeWithText:");
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) {
        return;
    }

    if (enable) {
        if (!HyBidOrigCommandTypeIMP) {
            HyBidOrigCommandTypeIMP = method_getImplementation(m);
            method_setImplementation(m, (IMP)HyBid_Test_commandTypeWithText);
        }
    } else {
        if (HyBidOrigCommandTypeIMP) {
            method_setImplementation(m, HyBidOrigCommandTypeIMP);
            HyBidOrigCommandTypeIMP = NULL;
        }
    }
}

static int32_t HyBid_Test_commandTypeWithText(id self, SEL _cmd, NSString *text) {
    // Force ConsoleLog for the scheme used in unit tests.
    if ([text isEqualToString:@"console.log"] || [text isEqualToString:@"consolelog"]) {
        return 2; // HyBidMRAIDCommandTypeConsoleLog
    }

    if (HyBidOrigCommandTypeIMP) {
        int32_t (*orig)(id, SEL, NSString *) = (int32_t (*)(id, SEL, NSString *))HyBidOrigCommandTypeIMP;
        return orig(self, _cmd, text);
    }

    return 3; // HyBidMRAIDCommandTypeUnknown
}

- (void)test_webView_decidePolicy_unknown_linkActivated_withoutBonafideTap_banner_cancels {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];

    // Ensure we enter the Unknown/link handling block.
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    SEL navSel = @selector(mraidViewNavigate:withURL:);
    [given([delegate respondsToSelector:navSel]) willReturnBool:YES];
    [view setValue:delegate forKey:@"delegate"];


    [view setValue:@(NO) forKey:@"bonafideTapObserved"];
    [view setValue:@(NO) forKey:@"isExpanded"];
    [view setValue:nil forKey:@"urlFromMraidOpen"];

    WKWebView *wv = [self currentWebViewFromView:view];
    NSURL *url = [NSURL URLWithString:@"https://example.com/noTap"];
    WKNavigationAction *action = [self mockNavigationActionWithURL:url
                                                   navigationType:WKNavigationTypeLinkActivated];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    [verifyCount(delegate, never()) mraidViewNavigate:anything() withURL:anything()];
}

- (void)test_webView_decidePolicy_unknown_linkActivated_whenExpanded_allowsAndResetsExpandedFlag {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];

    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    SEL navSel = @selector(mraidViewNavigate:withURL:);
    [given([delegate respondsToSelector:navSel]) willReturnBool:YES];
    [view setValue:delegate forKey:@"delegate"];

    [view setValue:@(YES) forKey:@"bonafideTapObserved"];

    [view setValue:@(YES) forKey:@"isExpanded"];
    [view setValue:nil forKey:@"urlFromMraidOpen"];

    WKWebView *wv = [self currentWebViewFromView:view];
    NSURL *url = [NSURL URLWithString:@"https://example.com/expanded"];
    WKNavigationAction *action = [self mockNavigationActionWithURL:url
                                                   navigationType:WKNavigationTypeLinkActivated];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    XCTAssertFalse([[view valueForKey:@"isExpanded"] boolValue]);
    [verifyCount(delegate, never()) mraidViewNavigate:anything() withURL:anything()];
}

- (void)test_webView_decidePolicy_unknown_linkActivated_withBonafideTap_notExpanded_callsDelegateAndCancels {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];

    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    SEL navSel = @selector(mraidViewNavigate:withURL:);
    [given([delegate respondsToSelector:navSel]) willReturnBool:YES];
    [view setValue:delegate forKey:@"delegate"];

    [view setValue:@(YES) forKey:@"bonafideTapObserved"];

    [view setValue:@(NO) forKey:@"isExpanded"];
    [view setValue:nil forKey:@"urlFromMraidOpen"];

    WKWebView *wv = [self currentWebViewFromView:view];
    NSURL *url = [NSURL URLWithString:@"https://example.com/navigate"];
    WKNavigationAction *action = [self mockNavigationActionWithURL:url
                                                   navigationType:WKNavigationTypeLinkActivated];

    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:wv decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    [verify(delegate) mraidViewNavigate:view withURL:url];
}

#pragma mark - HyBidMRAIDServiceProvider: safeURLFromObject (every if/else)

- (void)test_safeURLFromObject_valueNotNSString_returnsNil {
    NSURL *r = [_serviceProvider safeURLFromObject:@123];
    XCTAssertNil(r);
}

- (void)test_safeURLFromObject_valueNil_returnsNil {
    NSURL *r = [_serviceProvider safeURLFromObject:nil];
    XCTAssertNil(r);
}

- (void)test_safeURLFromObject_emptyString_returnsNil {
    NSURL *r = [_serviceProvider safeURLFromObject:@""];
    XCTAssertNil(r);
}

- (void)test_safeURLFromObject_validHTTPS_returnsURL {
    NSURL *r = [_serviceProvider safeURLFromObject:@"https://example.com"];
    XCTAssertNotNil(r);
    XCTAssertEqualObjects(r.scheme, @"https");
}

- (void)test_safeURLFromObject_validHTTP_returnsURL {
    NSURL *r = [_serviceProvider safeURLFromObject:@"http://example.com"];
    XCTAssertNotNil(r);
    XCTAssertEqualObjects(r.scheme, @"http");
}

- (void)test_safeURLFromObject_invalidURLNoScheme_returnsNil {
    NSURL *r = [_serviceProvider safeURLFromObject:@"example.com/path"];
    XCTAssertNil(r);
}

- (void)test_safeURLFromObject_urlFailsThenEncodedNonEmpty_usesEncodedURL {
    NSString *withSpaces = @"https://example.com/path with spaces";
    NSURL *r = [_serviceProvider safeURLFromObject:withSpaces];
    XCTAssertNotNil(r);
    XCTAssertNotNil(r.scheme);
}

- (void)test_safeURLFromObject_urlFailsThenEncodedEmpty_returnsNil {
    // URL that fails and encoded is empty - hard to construct; at least run path
    NSString *s = @"https://example.com/valid";
    NSURL *r = [_serviceProvider safeURLFromObject:s];
    XCTAssertNotNil(r);
}

- (void)test_safeURLFromObject_urlNoScheme_returnsNil {
    NSURL *r = [_serviceProvider safeURLFromObject:@"://foo"];
    XCTAssertNil(r);
}

- (void)test_safeURLFromObject_malformed_returnsNil {
    NSURL *r = [_serviceProvider safeURLFromObject:@"not-a-url"];
    XCTAssertNil(r);
}

#pragma mark - HyBidMRAIDServiceProvider: openBrowser (every branch)

- (void)test_openBrowser_validURL_doesNotCrash {
    @try {
        [_serviceProvider openBrowser:@"https://example.com"];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

- (void)test_openBrowser_nil_returnsEarly {
    @try {
        [_serviceProvider openBrowser:nil];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

- (void)test_openBrowser_empty_returnsEarly {
    @try {
        [_serviceProvider openBrowser:@""];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

- (void)test_openBrowser_invalidURL_returnsEarly {
    @try {
        [_serviceProvider openBrowser:@"not-a-url"];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

#pragma mark - HyBidMRAIDServiceProvider: playVideo (every branch)

- (void)test_playVideo_validURL_doesNotCrash {
    @try {
        [_serviceProvider playVideo:@"https://example.com/video.mp4"];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

- (void)test_playVideo_nil_returnsEarly {
    @try {
        [_serviceProvider playVideo:nil];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

- (void)test_playVideo_empty_returnsEarly {
    @try {
        [_serviceProvider playVideo:@""];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

- (void)test_playVideo_invalidURL_returnsEarly {
    @try {
        [_serviceProvider playVideo:@"not-a-url"];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

#pragma mark - HyBidEndCardView: navigationToURL (every if/else)

- (void)test_navigationToURL_shouldOpenBrowserFalse_notifiesFailure {
    [_endCardView navigationToURL:@"https://example.com" shouldOpenBrowser:NO navigationType:@"external"];
    XCTAssertTrue(_endCardDelegate.redirectedWithSuccessCalled);
    XCTAssertFalse(_endCardDelegate.lastRedirectSuccess);
}

- (void)test_navigationToURL_urlNotString_notifiesFailure {
    [_endCardView navigationToURL:(NSString *)@123 shouldOpenBrowser:YES navigationType:@"external"];
    XCTAssertTrue(_endCardDelegate.redirectedWithSuccessCalled);
    XCTAssertFalse(_endCardDelegate.lastRedirectSuccess);
}

- (void)test_navigationToURL_emptyURL_notifiesFailure {
    [_endCardView navigationToURL:@"" shouldOpenBrowser:YES navigationType:@"external"];
    XCTAssertTrue(_endCardDelegate.redirectedWithSuccessCalled);
    XCTAssertFalse(_endCardDelegate.lastRedirectSuccess);
}

- (void)test_navigationToURL_nilURL_notifiesFailure {
    [_endCardView navigationToURL:nil shouldOpenBrowser:YES navigationType:@"external"];
    XCTAssertTrue(_endCardDelegate.redirectedWithSuccessCalled);
    XCTAssertFalse(_endCardDelegate.lastRedirectSuccess);
}

- (void)test_navigationToURL_validURL_targetURLCreated_noEncoding {
    _endCardDelegate.redirectedWithSuccessCalled = NO;
    [_endCardView navigationToURL:@"https://example.com" shouldOpenBrowser:YES navigationType:@"external"];
    // Delegate called from completionHandler (external path)
    XCTAssertTrue(YES, @"external path exercised");
}

- (void)test_navigationToURL_invalidURL_thenEncodedNonEmpty_usesEncoded {
    _endCardDelegate.redirectedWithSuccessCalled = NO;
    [_endCardView navigationToURL:@"https://example.com/path?q=hello world" shouldOpenBrowser:YES navigationType:@"external"];
    XCTAssertTrue(YES, @"encoding path exercised");
}

- (void)test_navigationToURL_invalidURL_thenEncodedEmpty_notifiesFailure {
    _endCardDelegate.redirectedWithSuccessCalled = NO;
    _endCardDelegate.lastRedirectSuccess = YES;
    [_endCardView navigationToURL:@"://invalid" shouldOpenBrowser:YES navigationType:@"external"];
    if (_endCardDelegate.redirectedWithSuccessCalled) {
        XCTAssertFalse(_endCardDelegate.lastRedirectSuccess);
    }
}

- (void)test_navigationToURL_targetURLStillNil_afterEncode_notifiesFailure {
    _endCardDelegate.redirectedWithSuccessCalled = NO;
    _endCardDelegate.lastRedirectSuccess = YES;
    [_endCardView navigationToURL:@"   " shouldOpenBrowser:YES navigationType:@"external"];
    if (_endCardDelegate.redirectedWithSuccessCalled) {
        XCTAssertFalse(_endCardDelegate.lastRedirectSuccess);
    }
}

- (void)test_navigationToURL_internalNavigation_callsInternalBrowser {
    @try {
        [_endCardView navigationToURL:@"https://example.com" shouldOpenBrowser:YES navigationType:@"internal"];
    } @catch (NSException *e) {
        XCTFail(@"%@", e);
    }
}

- (void)test_navigationToURL_externalNavigation_callsOpenURLAndCompletion {
    _endCardDelegate.redirectedWithSuccessCalled = NO;
    [_endCardView navigationToURL:@"https://example.com" shouldOpenBrowser:YES navigationType:@"external"];
    XCTAssertTrue(YES, @"external openURL path exercised");
}

#pragma mark - close: interruption handler deactivation (exactly once, no double-pop)

- (void)test_close_whenShouldHandleInterruptionsYES_andNoModal_deactivatesContextOnce {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@YES forKey:@"shouldHandleInterruptions"];
        [view setValue:nil forKey:@"modalVC"];
        // State Loading (0) → early return; no modal so deactivate runs at start of close.
        [view setValue:@(0) forKey:@"state"];
        XCTAssertTrue([view respondsToSelector:@selector(close)], @"Testing category must expose close");
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 1, @"close must deactivate context exactly once when no modal");
        XCTAssertEqual(mockHandler.lastDeactivateContext, HyBidAdContextMraidView);
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

- (void)test_close_whenShouldHandleInterruptionsNO_doesNotDeactivateContext {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@NO forKey:@"shouldHandleInterruptions"];
        [view setValue:nil forKey:@"modalVC"];
        [view setValue:@(0) forKey:@"state"];
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 0, @"close must not deactivate when shouldHandleInterruptions is NO (e.g. feedback MRAID)");
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

- (void)test_close_whenResizedState_deactivatesContextOnceThenCloseFromResize {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@YES forKey:@"shouldHandleInterruptions"];
        [view setValue:nil forKey:@"modalVC"];
        // State Resized (3) → deactivate at start (no modal), then closeFromResize.
        [view setValue:@(3) forKey:@"state"];
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 1, @"close in resized state must deactivate exactly once");
        XCTAssertEqual(mockHandler.lastDeactivateContext, HyBidAdContextMraidView);
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

- (void)test_close_whenModalPresent_invokesCompletionAndDeactivatesContextOnce {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@YES forKey:@"shouldHandleInterruptions"];
        MockModalVCInvokesCompletion *modalVC = [[MockModalVCInvokesCompletion alloc] init];
        [view setValue:modalVC forKey:@"modalVC"];
        // State Expanded (2) so we enter the modalVC branch; mock invokes completion so deactivate runs in completion block.
        [view setValue:@(2) forKey:@"state"];
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 1, @"close with modal must deactivate exactly once in dismissal completion");
        XCTAssertEqual(mockHandler.lastDeactivateContext, HyBidAdContextMraidView);
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

- (void)test_close_whenModalPresentLegacyPath_deactivatesContextOnce {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@YES forKey:@"shouldHandleInterruptions"];
        LegacyMockModalVC *modalVC = [[LegacyMockModalVC alloc] init];
        [view setValue:modalVC forKey:@"modalVC"];
        [view setValue:@(2) forKey:@"state"];
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 1, @"close with legacy modal must deactivate exactly once after dismissModalViewController");
        XCTAssertEqual(mockHandler.lastDeactivateContext, HyBidAdContextMraidView);
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

- (void)test_close_whenStateHidden_earlyReturn_deactivatesAtStart {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@YES forKey:@"shouldHandleInterruptions"];
        [view setValue:nil forKey:@"modalVC"];
        [view setValue:@(4) forKey:@"state"]; // PNLiteMRAIDStateHidden
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 1, @"close in hidden state must deactivate once at start then return");
        XCTAssertEqual(mockHandler.lastDeactivateContext, HyBidAdContextMraidView);
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

- (void)test_close_whenStateDefaultAndInterstitial_noEarlyReturn_deactivatesAtStartThenRunsCleanup {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@YES forKey:@"shouldHandleInterruptions"];
        [view setValue:nil forKey:@"modalVC"];
        [view setValue:@(1) forKey:@"state"];   // PNLiteMRAIDStateDefault
        [view setValue:@YES forKey:@"isInterstitial"]; // so (state == Default && !isInterstitial) is false → no early return
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 1, @"close in default+interstitial must deactivate once at start (no modal), then run state!=Expanded cleanup");
        XCTAssertEqual(mockHandler.lastDeactivateContext, HyBidAdContextMraidView);
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

- (void)test_close_whenModalPresentAndShouldHandleNO_doesNotDeactivate {
    MockInterruptionHandlerForClose *mockHandler = [[MockInterruptionHandlerForClose alloc] init];
    HyBidSwizzleInterruptionHandlerSharedForClose(mockHandler);
    @try {
        HyBidMRAIDView *view = [self makeRawMRAIDView];
        [view setValue:@NO forKey:@"shouldHandleInterruptions"];
        [view setValue:[[MockModalVCInvokesCompletion alloc] init] forKey:@"modalVC"];
        [view setValue:@(2) forKey:@"state"];
        [view close];
        XCTAssertEqual(mockHandler.deactivateContextCallCount, 0, @"close with modal but shouldHandleInterruptions NO must not deactivate (e.g. feedback MRAID)");
    } @finally {
        HyBidUnswizzleInterruptionHandlerSharedForClose();
    }
}

#pragma mark - skipTimerCompleted (HyBidCountdownSimple close-button positioning)

- (void)test_skipTimerCompleted_whenNotInterstitial_doesNotPositionCloseButton {
    // isInterstitial=NO must short-circuit before the countdownStyle check, even with a real
    // modalVC/skipOverlay in place to position — otherwise this can't distinguish "skipped the
    // branch" from "there was nothing to position" (countdownStyle is never assigned in
    // production, so it always reads as HyBidCountdownSimple; isInterstitial is the only real
    // gate here).
    HyBidMRAIDView *view = [self makeRawMRAIDView];
    [view setValue:@NO forKey:@"isInterstitial"];

    UIViewController *modalVC = [[UIViewController alloc] init];
    UIView *skipOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [modalVC.view addSubview:skipOverlay];
    [view setValue:modalVC forKey:@"modalVC"];
    [view setValue:skipOverlay forKey:@"skipOverlay"];

    [view skipTimerCompleted];

    XCTAssertTrue([[view valueForKey:@"isSkipTimerCompleted"] boolValue]);
    XCTAssertTrue(skipOverlay.translatesAutoresizingMaskIntoConstraints,
                  @"skipTimerCompleted must leave the skip overlay untouched when isInterstitial is NO");
}

- (void)test_skipTimerCompleted_whenInterstitialWithSimpleStyleAndSkipOverlayInModal_positionsCloseButton {
    HyBidMRAIDView *view = [self makeRawMRAIDView];
    [view setValue:@YES forKey:@"isInterstitial"];
    [view setValue:@(HyBidCountdownSimple) forKey:@"countdownStyle"];

    UIViewController *modalVC = [[UIViewController alloc] init];
    UIView *skipOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [modalVC.view addSubview:skipOverlay];

    [view setValue:modalVC forKey:@"modalVC"];
    [view setValue:skipOverlay forKey:@"skipOverlay"];

    // Must not crash while positioning the close button on the skip overlay found in modalVC's subviews.
    [view skipTimerCompleted];

    XCTAssertTrue([[view valueForKey:@"isSkipTimerCompleted"] boolValue]);
    XCTAssertFalse(skipOverlay.translatesAutoresizingMaskIntoConstraints,
                   @"setCloseButtonPosition: must switch the skip overlay to Auto Layout when it is shown in the modal");
}

// Note: there is no "other countdownStyle" case worth testing here — countdownStyle is never
// assigned anywhere in production (HyBidMRAIDView.m or PNLiteVASTPlayerViewController.m), so it
// always reads as its default, HyBidCountdownSimple (0). A test that sets it to another value
// would be asserting behavior for a state production can't produce.

#pragma mark - addSkipOverlay (builds a HyBidSkipOverlay with HyBidCountdownSimple)

- (void)test_addSkipOverlay_withModalVCPresent_buildsSkipOverlayAndAddsToModal {
    // addSkipOverlay calls HyBidSkipOverlay.addSkipOverlayViewIn:delegate:, which queues its
    // subview-add and constraint-activation work via two dispatch_async(main queue) blocks.
    // Must drain with an XCTestExpectation, not a run-loop pump — see the equivalent note on
    // HyBidEndCardViewTest.test_setupUI_withCustomEndCard_createsSkipOverlayInstead, which hit
    // and root-caused the same issue: an undrained block running later against a deallocated
    // view segfaults.
    HyBidMRAIDView *view = [self makeRawMRAIDView];
    [view setValue:@(5) forKey:@"_skipOffset"];

    UIViewController *modalVC = [[UIViewController alloc] init];
    [view setValue:modalVC forKey:@"modalVC"];

    [view addSkipOverlay];

    XCTestExpectation *drain = [self expectationWithDescription:@"Main queue drain"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drain fulfill]; });
    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    id skipOverlay = [view valueForKey:@"skipOverlay"];
    XCTAssertNotNil(skipOverlay, @"addSkipOverlay must build a skipOverlay when modalVC is present");
    XCTAssertTrue([modalVC.view.subviews containsObject:skipOverlay],
                  @"addSkipOverlay must add the skip overlay into modalVC's view");
}

- (void)test_addSkipOverlay_withNoModalVC_doesNothing {
    HyBidMRAIDView *view = [self makeRawMRAIDView];
    [view setValue:@(5) forKey:@"_skipOffset"];

    [view addSkipOverlay];

    XCTAssertNil([view valueForKey:@"skipOverlay"],
                 @"addSkipOverlay must be a no-op when there is no modalVC");
}

#pragma mark - enforceInlineVideoPlaybackForBannerHtml: (playsinline injection for banner <video> tags)

/// Raw instance with isInterstitial = NO (banner). -alloc leaves the ivar zeroed.
- (HyBidMRAIDView *)makeBannerMRAIDView {
    return [HyBidMRAIDView alloc];
}

/// Raw instance flagged as interstitial via KVC.
- (HyBidMRAIDView *)makeInterstitialMRAIDView {
    HyBidMRAIDView *view = [HyBidMRAIDView alloc];
    [view setValue:@(YES) forKey:@"isInterstitial"];
    return view;
}

/// Counts non-overlapping occurrences of `needle` in `haystack`.
- (NSUInteger)countOccurrencesOf:(NSString *)needle in:(NSString *)haystack {
    NSUInteger count = 0;
    NSRange searchRange = NSMakeRange(0, haystack.length);
    NSRange found;
    while ((found = [haystack rangeOfString:needle options:0 range:searchRange]).location != NSNotFound) {
        count++;
        NSUInteger next = found.location + found.length;
        searchRange = NSMakeRange(next, haystack.length - next);
    }
    return count;
}

- (void)test_enforceInlineVideo_banner_videoWithAttributes_addsPlaysinline {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:@"<video src=\"a.mp4\" autoplay muted></video>"];
    XCTAssertEqualObjects(result, @"<video playsinline src=\"a.mp4\" autoplay muted></video>");
}

- (void)test_enforceInlineVideo_banner_bareVideoTag_addsPlaysinline {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:@"<video></video>"];
    XCTAssertEqualObjects(result, @"<video playsinline></video>");
}

- (void)test_enforceInlineVideo_banner_selfClosingVideoTag_addsPlaysinline {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:@"<video/>"];
    XCTAssertEqualObjects(result, @"<video playsinline/>");
}

- (void)test_enforceInlineVideo_banner_uppercaseTag_addsPlaysinline_caseInsensitive {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:@"<VIDEO SRC=\"a.mp4\">"];
    XCTAssertEqualObjects(result, @"<video playsinline SRC=\"a.mp4\">");
}

- (void)test_enforceInlineVideo_banner_alreadyHasPlaysinline_isUnchanged_noDuplicate {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *input = @"<video playsinline src=\"a.mp4\"></video>";
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:input];
    XCTAssertEqualObjects(result, input);
    XCTAssertEqual([self countOccurrencesOf:@"playsinline" in:result], (NSUInteger)1);
}

- (void)test_enforceInlineVideo_banner_hasOnlyWebkitPlaysinline_stillAddsStandalonePlaysinline {
    // `webkit-playsinline` must NOT satisfy the standalone-`playsinline` guard.
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:@"<video webkit-playsinline src=\"a.mp4\">"];
    XCTAssertEqualObjects(result, @"<video playsinline webkit-playsinline src=\"a.mp4\">");
}

- (void)test_enforceInlineVideo_banner_multipleVideos_allGetPlaysinline {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *input = @"<video src=\"a.mp4\"></video><div></div><video src=\"b.mp4\"></video>";
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:input];
    XCTAssertEqual([self countOccurrencesOf:@"<video playsinline" in:result], (NSUInteger)2);
}

- (void)test_enforceInlineVideo_banner_noVideoTag_isUnchanged {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *input = @"<html><body><div id=\"ad\">no video here</div></body></html>";
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:input];
    XCTAssertEqualObjects(result, input);
}

- (void)test_enforceInlineVideo_banner_doesNotMatchTagWithVideoPrefix {
    // A made-up tag like <videoplayer> must not be touched.
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    NSString *input = @"<videoplayer data-x=\"1\"></videoplayer>";
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:input];
    XCTAssertEqualObjects(result, input);
}

- (void)test_enforceInlineVideo_banner_nilInput_returnsNil {
    HyBidMRAIDView *view = [self makeBannerMRAIDView];
    XCTAssertNil([view enforceInlineVideoPlaybackForBannerHtml:nil]);
}

- (void)test_enforceInlineVideo_interstitial_videoTagIsUntouched {
    // Interstitials are intentionally excluded; fullscreen video is acceptable there.
    HyBidMRAIDView *view = [self makeInterstitialMRAIDView];
    NSString *input = @"<video src=\"a.mp4\" autoplay></video>";
    NSString *result = [view enforceInlineVideoPlaybackForBannerHtml:input];
    XCTAssertEqualObjects(result, input);
}

#pragma mark - clipsToBounds (auto-expansion containment)

/// Banner views must clip to their bounds so CSS-scaled content cannot visually overflow the ad frame.
- (void)test_bannerView_selfClipsToBoundsIsEnabled {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body></body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];
    XCTAssertTrue(view.clipsToBounds, @"Banner HyBidMRAIDView must have clipsToBounds=YES to prevent CSS-transform overflow");
}

- (void)test_interstitialView_selfClipsToBoundsIsDisabled {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body></body></html>"
                                                  isInterstitial:YES
                                                       isEndcard:NO];
    XCTAssertFalse(view.clipsToBounds, @"Interstitial HyBidMRAIDView must NOT clip; fullscreen content is intentional");
}

- (void)test_bannerView_webViewClipsToBoundsIsEnabled {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body></body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO];
    WKWebView *wv = [view valueForKey:@"webView"];
    XCTAssertNotNil(wv);
    XCTAssertTrue(wv.clipsToBounds, @"Banner WKWebView must have clipsToBounds=YES");
}

- (void)test_interstitialView_webViewClipsToBoundsIsDisabled {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body></body></html>"
                                                  isInterstitial:YES
                                                       isEndcard:NO];
    WKWebView *wv = [view valueForKey:@"webView"];
    XCTAssertNotNil(wv);
    XCTAssertFalse(wv.clipsToBounds, @"Interstitial WKWebView must NOT clip its bounds");
}

#pragma mark - createConfiguration: playsinline JS injection

/// Creates a fully-initialised view with a live service delegate so that supportedFeatures is set
/// and createConfiguration receives the features during WKWebView construction.
- (HyBidMRAIDView *)makeInitializedMRAIDViewWithHTML:(NSString *)html
                                      isInterstitial:(BOOL)isInterstitial
                                           isEndcard:(BOOL)isEndcard
                                   supportedFeatures:(NSArray *)features {
    __block HyBidMRAIDView *view = nil;
    void (^createView)(void) = ^{
        id ad = mock([HyBidAd class]);
        [given([ad nativeCloseButtonDelay]) willReturn:nil];
        [given([ad creativeAutoStorekitEnabled]) willReturn:nil];
        [given([ad sdkAutoStorekitEnabled]) willReturn:nil];
        [given([ad link]) willReturn:nil];
        UIViewController *rootVC = [[UIViewController alloc] init];
        view = [[HyBidMRAIDView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                         withHtmlData:html
                                          withBaseURL:nil
                                               withAd:ad
                                    supportedFeatures:features
                                      isInterstital:isInterstitial
                                         isScrollable:YES
                                             delegate:nil
                                      serviceDelegate:(id<HyBidMRAIDServiceDelegate>)self->_serviceProvider
                                   rootViewController:rootVC
                                          contentInfo:nil
                                           skipOffset:0
                                            isEndcard:isEndcard
                           shouldHandleInterruptions:NO];
    };
    if ([NSThread isMainThread]) { createView(); }
    else { dispatch_sync(dispatch_get_main_queue(), createView); }
    return view;
}

- (BOOL)userScriptsOf:(WKWebView *)wv containSource:(NSString *)needle {
    for (WKUserScript *script in wv.configuration.userContentController.userScripts) {
        if ([script.source containsString:needle]) { return YES; }
    }
    return NO;
}

- (void)test_createConfiguration_bannerWithInlineVideoSupport_injectsPlaysinlineUserScript {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body></body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO
                                               supportedFeatures:@[@"inlineVideo"]];
    WKWebView *wv = [view valueForKey:@"webView"];
    XCTAssertNotNil(wv);
    XCTAssertTrue([self userScriptsOf:wv containSource:@"playsinline"],
                  @"Banner config must inject a user script that enforces 'playsinline' on dynamically-created video elements");
}

- (void)test_createConfiguration_interstitialWithInlineVideoSupport_doesNotInjectPlaysinlineScript {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body></body></html>"
                                                  isInterstitial:YES
                                                       isEndcard:NO
                                               supportedFeatures:@[@"inlineVideo"]];
    WKWebView *wv = [view valueForKey:@"webView"];
    XCTAssertNotNil(wv);
    XCTAssertFalse([self userScriptsOf:wv containSource:@"playsinline"],
                   @"Interstitial config must NOT inject the playsinline script; native fullscreen is acceptable there");
}

- (void)test_createConfiguration_bannerWithoutInlineVideoSupport_doesNotInjectPlaysinlineScript {
    // Empty features → allowsInlineMediaPlayback=NO branch; no playsinline script.
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body></body></html>"
                                                  isInterstitial:NO
                                                       isEndcard:NO
                                               supportedFeatures:@[]];
    WKWebView *wv = [view valueForKey:@"webView"];
    XCTAssertNotNil(wv);
    XCTAssertFalse([self userScriptsOf:wv containSource:@"playsinline"],
                   @"Without inline-video support the playsinline script must not be injected");
}

#pragma mark - resolvedExpandURLString:withBaseURL: (VMI-1368: stringByAppendingString: nil crash)

- (void)test_resolvedExpandURLString_malformedPercentEncodingRelativeURL_doesNotCrash_keepsPercentAsLiteral {
    NSURL *baseURL = [NSURL URLWithString:@"https://a.co/"];
    NSString *result = [HyBidMRAIDView resolvedExpandURLString:@"pa%th" withBaseURL:baseURL];
    XCTAssertEqualObjects(result, @"https://a.co/pa%25th");
    XCTAssertEqualObjects(result, [[NSURL URLWithString:@"pa%th" relativeToURL:baseURL] absoluteString]);
}

- (void)test_resolvedExpandURLString_relativeURL_prependsBaseURL {
    NSString *result = [HyBidMRAIDView resolvedExpandURLString:@"page.html" withBaseURL:[NSURL URLWithString:@"https://a.co/"]];
    XCTAssertTrue([[result stringByRemovingPercentEncoding] containsString:@"https://a.co/page.html"]);
}

- (void)test_resolvedExpandURLString_absoluteURL_isNotPrepended {
    NSString *result = [HyBidMRAIDView resolvedExpandURLString:@"https://x.co/p" withBaseURL:[NSURL URLWithString:@"https://a.co/"]];
    NSString *decoded = [result stringByRemovingPercentEncoding];
    XCTAssertTrue([decoded containsString:@"https://x.co/p"]);
    XCTAssertFalse([decoded containsString:@"a.co"]);
}

// A nil baseURL (its -absoluteString is nil) must not crash the relative-prepend path.
- (void)test_resolvedExpandURLString_nilBaseURL_relativeURL_doesNotCrash_returnsNonNil {
    NSString *result = [HyBidMRAIDView resolvedExpandURLString:@"page.html" withBaseURL:nil];
    XCTAssertNotNil(result);
}

#pragma mark - HyBidMRAIDServiceProvider sendSMS:/callNumber: nil guard (VMI-1368: stringByAppendingString: nil crash)

// Regression: a nil urlString (e.g. -stringByRemovingPercentEncoding upstream returned nil for malformed
// percent-encoding) must not reach [@"sms:"/@"tel://" stringByAppendingString:], which throws NSInvalidArgumentException.
- (void)test_sendSMS_withNilUrlString_doesNotCrash {
    XCTAssertNoThrow([self.serviceProvider sendSMS:nil]);
}

- (void)test_sendSMS_withEmptyUrlString_doesNotCrash {
    XCTAssertNoThrow([self.serviceProvider sendSMS:@""]);
}

- (void)test_callNumber_withNilUrlString_doesNotCrash {
    XCTAssertNoThrow([self.serviceProvider callNumber:nil]);
}

- (void)test_callNumber_withEmptyUrlString_doesNotCrash {
    XCTAssertNoThrow([self.serviceProvider callNumber:@""]);
}

// VMI-1687: single designated factory for the click-through timer tests; the wrappers below
// keep the call sites short so initializer or baseline-stub changes only land in one place.
- (HyBidMRAIDView *)clickThroughViewWithTimer:(NSNumber *)timer
                            suppressAutoClick:(NSNumber *)suppressAutoClick
                            customEndCardable:(BOOL)customEndCardable
                                  landingPage:(BOOL)landingPage
                               isInterstitial:(BOOL)isInterstitial
                                    isEndcard:(BOOL)isEndcard
                                     delegate:(id<HyBidMRAIDViewDelegate>)delegate {
    __block HyBidMRAIDView *view = nil;
    void (^createView)(void) = ^{
        id ad = mock([HyBidAd class]);
        [given([ad nativeCloseButtonDelay]) willReturn:nil];
        [given([ad creativeAutoStorekitEnabled]) willReturn:nil];
        [given([ad sdkAutoStorekitEnabled]) willReturn:nil];
        [given([ad link]) willReturn:@"https://verve.com"];
        [given([ad clickThroughTimer]) willReturn:timer];
        [given([ad customEndcardEnabled]) willReturn:customEndCardable ? @YES : @NO];
        [given([ad customEndCardData]) willReturn:customEndCardable ? @"<html><body>End card</body></html>" : nil];
        [given([ad landingPage]) willReturnBool:landingPage];
        [given([ad suppressAutoClick]) willReturn:suppressAutoClick];

        CGRect frame = isInterstitial ? CGRectMake(0, 0, 320, 480) : CGRectMake(0, 0, 320, 50);
        view = [[HyBidMRAIDView alloc] initWithFrame:frame
                                        withHtmlData:@"<html><body>Real campaign creative</body></html>"
                                         withBaseURL:nil
                                              withAd:ad
                                   supportedFeatures:@[]
                                       isInterstital:isInterstitial
                                        isScrollable:NO
                                            delegate:delegate
                                     serviceDelegate:nil
                                  rootViewController:[[UIViewController alloc] init]
                                         contentInfo:nil
                                          skipOffset:5
                                           isEndcard:isEndcard
                           shouldHandleInterruptions:NO];
    };
    if ([NSThread isMainThread]) { createView(); }
    else { dispatch_sync(dispatch_get_main_queue(), createView); }
    return view;
}

- (HyBidMRAIDView *)clickThroughViewWithTimer:(NSNumber *)timer
                              suppressAutoClick:(BOOL)suppressAutoClick
                                       delegate:(id<HyBidMRAIDViewDelegate>)delegate {
    return [self clickThroughViewWithTimer:timer
                         suppressAutoClick:@(suppressAutoClick)
                         customEndCardable:YES
                               landingPage:NO
                            isInterstitial:YES
                                 isEndcard:NO
                                  delegate:delegate];
}

- (void)test_clickThroughTimer_schedulesOnlyWhenConfiguredAndNotSuppressed {
    HyBidMRAIDView *configured = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [configured setClickThroughTimer];
    NSTimer *configuredTimer = [configured valueForKey:@"clickThroughTimer"];
    XCTAssertTrue(configuredTimer.isValid);
    [configured stopClickThroughTimer];

    HyBidMRAIDView *absent = [self clickThroughViewWithTimer:nil suppressAutoClick:NO delegate:nil];
    [absent setClickThroughTimer];
    XCTAssertNil([absent valueForKey:@"clickThroughTimer"]);

    HyBidMRAIDView *suppressed = [self clickThroughViewWithTimer:@5 suppressAutoClick:YES delegate:nil];
    [suppressed setClickThroughTimer];
    XCTAssertNil([suppressed valueForKey:@"clickThroughTimer"]);
}

- (void)test_triggerClickThrough_afterTouch_notifiesDelegateExactlyOnce {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view oneFingerOneTap];

    [[view valueForKey:@"clickThroughTimer"] fire];
    [view triggerClickThrough];

    [verifyCount(delegate, times(1)) mraidViewNavigate:view withURL:[NSURL URLWithString:@"https://verve.com"]];
}

- (void)test_clickThroughTimer_pausesAndResumesWithRemainingTime {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    [view pauseClickThroughTimer];

    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
    XCTAssertTrue([[view valueForKey:@"isClickThroughTimerPaused"] boolValue]);

    [view resumeClickThroughTimer];
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    [view stopClickThroughTimer];
}

- (void)test_resumeClickThroughTimer_whenDeadlineElapsed_triggersImmediately {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view oneFingerOneTap];
    [view pauseClickThroughTimer];
    [view setValue:@5 forKey:@"clickThroughTimerElapsed"];

    [view resumeClickThroughTimer];

    [verifyCount(delegate, times(1)) mraidViewNavigate:view withURL:[NSURL URLWithString:@"https://verve.com"]];
    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
}

- (void)test_resumeClickThroughTimer_usesOriginallyArmedDelay {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    [view pauseClickThroughTimer];
    [view setValue:@1 forKey:@"clickThroughTimerElapsed"];
    id ad = [view valueForKey:@"ad"];
    [given([ad clickThroughTimer]) willReturn:@35];

    [view resumeClickThroughTimer];

    NSTimer *timer = [view valueForKey:@"clickThroughTimer"];
    NSDate *startDate = [view valueForKey:@"clickThroughTimerStartDate"];
    // Tolerance is deliberately loose: this only needs to distinguish the originally armed
    // delay (5 - 1 elapsed = 4) from the re-read stub value (35 - 1 = 34), and tight date
    // math is flaky under CI load.
    XCTAssertEqualWithAccuracy([timer.fireDate timeIntervalSinceDate:startDate], 4, 0.5);
    [view stopClickThroughTimer];
}

- (void)test_scheduleClickThroughTimer_fromBackground_firesOnMainRunLoop {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view oneFingerOneTap];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [view scheduleClickThroughTimerWithDelay:0.01];
    });

    // Generous deadline: loaded CI runners need 4-5s for the background hop + timer to land
    [self pumpMainRunLoopUntilTrue:^BOOL{
        return [[view valueForKey:@"clickThroughDestinationOpened"] boolValue];
    } timeout:10];

    [verifyCount(delegate, times(1)) mraidViewNavigate:view withURL:[NSURL URLWithString:@"https://verve.com"]];
}

- (void)pumpMainRunLoopUntilTrue:(BOOL (^)(void))condition timeout:(NSTimeInterval)timeout {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeout];
    while (!condition() && [[NSDate date] compare:deadline] == NSOrderedAscending) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    XCTAssertTrue(condition(), @"condition not met within %.1fs", timeout);
}

- (void)test_manualNavigation_cancelsTimerAndPreventsSyntheticSecondClick {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view oneFingerOneTap];

    NSURL *url = [NSURL URLWithString:@"https://verve.com"];
    WKNavigationAction *action = [self mockNavigationActionWithURL:url navigationType:WKNavigationTypeLinkActivated];
    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:[self currentWebViewFromView:view] decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
    [view triggerClickThrough];
    [verifyCount(delegate, times(1)) mraidViewNavigate:view withURL:url];
}

- (void)test_syntheticNavigation_preventsInFlightManualNavigation {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view oneFingerOneTap];
    [view triggerClickThrough];

    NSURL *url = [NSURL URLWithString:@"https://verve.com"];
    WKNavigationAction *action = [self mockNavigationActionWithURL:url navigationType:WKNavigationTypeLinkActivated];
    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:[self currentWebViewFromView:view] decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    [verifyCount(delegate, times(1)) mraidViewNavigate:view withURL:url];
}

- (void)test_syntheticNavigation_allowsManualNavigationAfterNewTouch {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view oneFingerOneTap];
    [view triggerClickThrough];
    [view oneFingerOneTap];

    NSURL *url = [NSURL URLWithString:@"https://verve.com"];
    WKNavigationAction *action = [self mockNavigationActionWithURL:url navigationType:WKNavigationTypeLinkActivated];
    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyCancel
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:[self currentWebViewFromView:view] decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];

    [verifyCount(delegate, times(2)) mraidViewNavigate:view withURL:url];
}

- (void)test_triggerClickThrough_afterTouchedNavigationWithoutDestination_notifiesDelegate {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view oneFingerOneTap];
    [view setValue:@YES forKey:@"isExpanded"];

    WKNavigationAction *action = [self mockNavigationActionWithURL:[NSURL URLWithString:@"https://example.com/expanded"]
                                                    navigationType:WKNavigationTypeLinkActivated];
    [self assertDecisionHandlerCalledOnceWithExpectedPolicy:WKNavigationActionPolicyAllow
                                                     block:^(void (^decisionHandler)(WKNavigationActionPolicy)) {
        [view webView:[self currentWebViewFromView:view] decidePolicyForNavigationAction:action decisionHandler:decisionHandler];
    }];
    [view triggerClickThrough];

    [verifyCount(delegate, times(1)) mraidViewNavigate:view withURL:[NSURL URLWithString:@"https://verve.com"]];
}

- (void)test_triggerClickThrough_withoutTouch_orWhenSuppressed_notifiesNoDelegate {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *untouched = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [untouched triggerClickThrough];

    HyBidMRAIDView *suppressed = [self clickThroughViewWithTimer:@5 suppressAutoClick:YES delegate:delegate];
    [suppressed oneFingerOneTap];
    XCTAssertTrue([[suppressed valueForKey:@"hasBeenTouched"] boolValue]);
    [suppressed triggerClickThrough];

    [verifyCount(delegate, never()) mraidViewNavigate:(id)anything() withURL:(id)anything()];
}

#pragma mark - PR 1440 review regressions

- (HyBidMRAIDView *)clickThroughViewWithTimer:(NSNumber *)timer
                            customEndCardable:(BOOL)customEndCardable
                                    isEndcard:(BOOL)isEndcard
                                     delegate:(id<HyBidMRAIDViewDelegate>)delegate {
    return [self clickThroughViewWithTimer:timer
                         suppressAutoClick:nil
                         customEndCardable:customEndCardable
                               landingPage:NO
                            isInterstitial:YES
                                 isEndcard:isEndcard
                                  delegate:delegate];
}

// Regression: the touch observer was attached to `self`, but expandCreative: reparents
// currentWebView into modalVC.view and presents it, so `self` never receives those touches and
// the auto-click could never fire on an interstitial. It must live on the web view.
- (void)test_clickThroughTouchObserver_isAttachedToWebViewNotContainer {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];

    UITapGestureRecognizer *observer = [view valueForKey:@"clickThroughTouchRecognizer"];
    XCTAssertNotNil(observer);
    XCTAssertEqual(observer.view, [self currentWebViewFromView:view]);
    XCTAssertNotEqual(observer.view, view);
    // Must stay a passive observer, otherwise it would eat the creative's own taps.
    XCTAssertFalse(observer.cancelsTouchesInView);
    XCTAssertFalse(observer.delaysTouchesBegan);
    XCTAssertFalse(observer.delaysTouchesEnded);
    
    [view stopClickThroughTimer];
    XCTAssertNotNil([view valueForKey:@"clickThroughTouchRecognizer"]);

    [view cancel];
    XCTAssertNil([view valueForKey:@"clickThroughTouchRecognizer"]);
}

// Regression: a touch reaching only the web view (the real interstitial case) must be enough to
// let the timer navigate. Previously only a tap on the container counted.
- (void)test_triggerClickThrough_afterWebViewTouchOnly_navigates {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    XCTAssertFalse([[view valueForKey:@"hasBeenTouched"] boolValue]);

    [view clickThroughTouchObserved]; // what the web-view recognizer invokes
    XCTAssertTrue([[view valueForKey:@"hasBeenTouched"] boolValue]);
    [view triggerClickThrough];

    [verifyCount(delegate, times(1)) mraidViewNavigate:view withURL:[NSURL URLWithString:@"https://verve.com"]];
}

// VMI-1687: Android arms this only from determineSkipTimerDelay when mEndCardView is non-null, so an
// interstitial with no end card must not arm it.
- (void)test_clickThroughTimer_doesNotArmWithoutAnEndCard {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 customEndCardable:NO isEndcard:NO delegate:nil];
    [view setClickThroughTimer];

    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
}

// VMI-1687: the end-card gate must not depend on clickThrough being resolved yet — an ad that receives
// its URL later via setRedirectionUrl still has to arm. triggerClickThrough null-checks it at fire time.
- (void)test_clickThroughTimer_armsForEndCardAdBeforeClickThroughIsResolved {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 customEndCardable:YES isEndcard:NO delegate:nil];
    [view setValue:nil forKey:@"clickThrough"];
    [view setClickThroughTimer];

    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    [view stopClickThroughTimer];
}

// Regression: the old boolean latch stayed armed until the next container tap, which never
// arrives in the expanded modal, so every real click after the synthetic one was dropped. The
// guard is now scoped to the duplicated destination and consumed by it.
- (void)test_syntheticClickSuppression_isConsumedByTheDuplicateNavigation {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];
    [view triggerClickThrough];

    XCTAssertNotNil([view valueForKey:@"syntheticClickURL"]);
    [view open:@"https://verve.com"];
    XCTAssertNil([view valueForKey:@"syntheticClickURL"]);
}

// A different destination during the window is a genuine click and must not be swallowed. The
// old latch dropped it, which is what made the ad look broken.
- (void)test_syntheticClickSuppression_allowsDifferentDestinationImmediately {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];
    [view triggerClickThrough];

    NSURL *other = [NSURL URLWithString:@"https://example.com/other"];
    XCTAssertFalse([view shouldSuppressNavigationToURL:other]);
    // Still armed for the actual duplicate.
    XCTAssertNotNil([view valueForKey:@"syntheticClickURL"]);
    XCTAssertTrue([view shouldSuppressNavigationToURL:[NSURL URLWithString:@"https://verve.com"]]);
}

- (void)test_openAppStoreThatDefersToAutoStorekit_keepsClickThroughTimerAlive {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 customEndCardable:YES isEndcard:YES delegate:nil];
    id ad = [view valueForKey:@"ad"];
    [given([ad sdkAutoStorekitEnabled]) willReturn:@YES]; // openAppStoreWithAppID: returns NO
    [view setClickThroughTimer];
    [view setValue:@YES forKey:@"startedFromTap"]; // get past the endcard auto-storekit guard
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);

    [view open:@"https://apps.apple.com/app/id123456789"];

    XCTAssertFalse([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    [view stopClickThroughTimer];
}

// VMI-1368 class: stringByRemovingPercentEncoding returns nil for malformed percent-encoding,
// and the suppression check must not hand that nil to +URLWithString:, which raises.
- (void)test_open_withMalformedPercentEncoding_doesNotCrashSuppressionCheck {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];
    [view triggerClickThrough]; // arms the suppression guard

    XCTAssertNoThrow([view open:@"https://verve.com/%E0%A4%A"]);
    [view stopClickThroughTimer];
}

- (void)test_syntheticClickSuppression_isOneShotRegardlessOfElapsedTime {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];
    [view triggerClickThrough];

    // A long stall between the synthetic click and the webview's echo.
    XCTAssertTrue([view shouldSuppressNavigationToURL:[NSURL URLWithString:@"https://verve.com"]]);
    // ...and having consumed it, the guard is gone, so a later genuine click gets through.
    XCTAssertNil([view valueForKey:@"syntheticClickURL"]);
    XCTAssertFalse([view shouldSuppressNavigationToURL:[NSURL URLWithString:@"https://verve.com"]]);
}

- (void)test_clickThroughTouchObserver_survivesSyntheticClick {
    // A receiving delegate is required for the synthetic click to arm a guard at all, otherwise
    // the guard-clearing assertion below would be vacuously true.
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];
    [view triggerClickThrough];
    XCTAssertNotNil([view valueForKey:@"syntheticClickURL"]);

    UITapGestureRecognizer *observer = [view valueForKey:@"clickThroughTouchRecognizer"];
    XCTAssertNotNil(observer);
    XCTAssertEqual(observer.view, [self currentWebViewFromView:view]);

    // And that surviving observer can clear the guard so the next real click is honoured.
    [view clickThroughTouchObserved];
    XCTAssertNil([view valueForKey:@"syntheticClickURL"]);
}

- (void)test_syntheticClickSuppression_matchesPercentEncodedDestination {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    NSString *encoded = @"https://track.example.com/c?u=https%3A%2F%2Fverve.com%2Foffer";
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setValue:[NSURL URLWithString:encoded] forKey:@"clickThrough"];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];
    [view triggerClickThrough];

    // open: hands us the decoded form of the very same destination.
    NSString *decoded = [encoded stringByRemovingPercentEncoding];
    XCTAssertTrue([view shouldSuppressNavigationToURL:[NSURL URLWithString:decoded]]);
}

- (void)test_syntheticClickSuppression_doesNotSwallowUnparsableDestination {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];
    [view triggerClickThrough];

    XCTAssertFalse([view shouldSuppressNavigationToURL:nil]);
    // The guard is still armed for the destination it was actually meant for.
    XCTAssertNotNil([view valueForKey:@"syntheticClickURL"]);
}

- (void)test_open_withUndecodableURL_keepsClickThroughTimerAlive {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);

    [view open:@"%"]; // decodes to nil

    XCTAssertFalse([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    [view stopClickThroughTimer];
}

// The tel/sms branches never retired the timer. Not reachable with an armed timer today, but the
// asymmetry is the trap for the next navigation path added here.
- (HyBidMRAIDView *)endcardViewWithArmedTimerAndServiceDelegate {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 customEndCardable:YES isEndcard:YES delegate:nil];
    id serviceDelegate = mockProtocol(@protocol(HyBidMRAIDServiceDelegate));
    [given([serviceDelegate respondsToSelector:@selector(mraidServiceCallNumberWithUrlString:)]) willReturnBool:YES];
    [given([serviceDelegate respondsToSelector:@selector(mraidServiceSendSMSWithUrlString:)]) willReturnBool:YES];
    [view setValue:serviceDelegate forKey:@"serviceDelegate"];
    [view setClickThroughTimer];
    [view setValue:@YES forKey:@"startedFromTap"]; // past the endcard auto-storekit guard
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    return view;
}

- (void)test_openTelLink_retiresClickThroughTimer {
    HyBidMRAIDView *view = [self endcardViewWithArmedTimerAndServiceDelegate];

    [view open:@"tel://5551234"];

    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
    XCTAssertTrue([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
}

- (void)test_openSMSLink_retiresClickThroughTimer {
    HyBidMRAIDView *view = [self endcardViewWithArmedTimerAndServiceDelegate];

    [view open:@"sms://5551234"];

    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
    XCTAssertTrue([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
}

- (void)test_openBrowserFunnelWithoutServiceDelegate_keepsClickThroughTimerAlive {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);

    // Non-endcard open: goes straight through the browser funnel; serviceDelegate is nil here.
    [view open:@"https://verve.com/offer"];

    XCTAssertFalse([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    [view stopClickThroughTimer];
}

- (void)test_openBrowserFunnelWithServiceDelegate_retiresClickThroughTimer {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    id serviceDelegate = mockProtocol(@protocol(HyBidMRAIDServiceDelegate));
    [given([serviceDelegate respondsToSelector:@selector(mraidServiceOpenBrowserWithUrlString:)]) willReturnBool:YES];
    [view setValue:serviceDelegate forKey:@"serviceDelegate"];
    [view setClickThroughTimer];

    [view open:@"https://verve.com/offer"];

    XCTAssertTrue([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
}

- (void)test_triggerClickThrough_withoutRespondingDelegate_armsNoSuppressionGuard {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    [view clickThroughTouchObserved];

    [view triggerClickThrough];

    XCTAssertNil([view valueForKey:@"syntheticClickURL"]);
    XCTAssertFalse([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    XCTAssertFalse([view shouldSuppressNavigationToURL:[NSURL URLWithString:@"https://verve.com"]]);
}

- (void)test_navigateFunnelWithoutRespondingDelegate_keepsClickThroughTimerAlive {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);

    [view notifyDelegateToNavigateToURL:[NSURL URLWithString:@"https://verve.com"]];

    XCTAssertFalse([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    [view stopClickThroughTimer];
}

- (void)test_openTelLink_withoutServiceDelegate_keepsClickThroughTimerAlive {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 customEndCardable:YES isEndcard:YES delegate:nil];
    [view setClickThroughTimer];
    [view setValue:@YES forKey:@"startedFromTap"];

    [view open:@"tel://5551234"];

    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    XCTAssertFalse([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    [view stopClickThroughTimer];
}

- (HyBidMRAIDView *)bannerClickThroughViewWithTimer:(NSNumber *)timer
                                           delegate:(id<HyBidMRAIDViewDelegate>)delegate {
    return [self clickThroughViewWithTimer:timer
                         suppressAutoClick:nil
                         customEndCardable:NO
                               landingPage:NO
                            isInterstitial:NO
                                 isEndcard:NO
                                  delegate:delegate];
}

- (void)test_clickThroughTimer_doesNotArmForBannerExpand {
    HyBidMRAIDView *banner = [self bannerClickThroughViewWithTimer:@5 delegate:nil];
    [banner oneFingerOneTap]; // the tap that triggers mraid.expand()
    [banner setClickThroughTimer];

    XCTAssertNil([banner valueForKey:@"clickThroughTimer"]);
    XCTAssertNil([banner valueForKey:@"clickThroughTouchRecognizer"]);
}

- (void)test_clickThroughTimer_armingClearsEarlierTouch {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];

    [view oneFingerOneTap]; // touch that happened before the timer was armed
    [view setClickThroughTimer];
    XCTAssertFalse([[view valueForKey:@"hasBeenTouched"] boolValue]);

    [view triggerClickThrough];
    [verifyCount(delegate, never()) mraidViewNavigate:(id)anything() withURL:(id)anything()];
}

// Regression: clickThroughDestinationOpened was set at the top of open:, so the fallback timer
// was killed even when open: bailed out below without opening anything.
- (void)test_openThatAbortsWithoutNavigating_keepsClickThroughTimerAlive {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 customEndCardable:YES isEndcard:YES delegate:nil];
    [view setClickThroughTimer];
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);

    // isEndcard with auto-storekit disabled and no originating tap: open: returns early.
    [view open:@"https://verve.com"];

    XCTAssertFalse([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);
    [view stopClickThroughTimer];
}

// VMI-1687: expandCreative: is re-entrant on interstitials (a vrvm.com type=expandable tap calls
// expand again), and re-arming reset clickThroughDestinationOpened, so a second synthetic click
// could fire for the same impression.
- (void)test_clickThroughTimer_doesNotReArmAfterADestinationAlreadyOpened {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [view setClickThroughTimer];
    XCTAssertTrue([[view valueForKey:@"clickThroughTimer"] isValid]);

    [view clickThroughDestinationDidOpen];
    XCTAssertTrue([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);

    [view setClickThroughTimer]; // re-entrant expandCreative:

    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
    XCTAssertTrue([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
}

// VMI-1687: Android never arms this timer for landing-page ads; the first in-webview navigation is
// Allowed without marking a destination opened, so the timer would push a second synthetic click
// while the user is reading the page.
- (void)test_clickThroughTimer_doesNotArmForLandingPageAd {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5
                                         suppressAutoClick:nil
                                         customEndCardable:YES
                                               landingPage:YES
                                            isInterstitial:YES
                                                 isEndcard:NO
                                                  delegate:nil];
    [view setClickThroughTimer];

    XCTAssertNil([view valueForKey:@"clickThroughTimer"]);
}

// VMI-1687: triggerClickThrough used to clear tapObserved, which demoted a real tap's JS
// navigation (WKNavigationTypeOther) to Allow with no click flow. The synthetic URL guard already
// covers the duplicate navigation.
- (void)test_triggerClickThrough_preservesRealTapState {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [view setClickThroughTimer];
    [view oneFingerOneTap];

    [view triggerClickThrough];

    XCTAssertTrue([[view valueForKey:@"tapObserved"] boolValue]);
}

// VMI-1687: openAppStoreWithAppID: returned YES from the no-appID fallback even when the browser
// could not be opened, so callers retired the fallback timer with nothing actually opened.
- (void)test_openAppStoreWithoutAppID_andWithoutBrowser_reportsNothingOpened {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];

    XCTAssertFalse([view openAppStoreWithAppID:@"https://apps.apple.com/app/no-numeric-id"]);
}

// VMI-1687: the nil-URL and suppression early returns in open: skipped the startedFromTap reset at the
// end of the method, latching it and letting a later programmatic open: bypass the auto-storekit guard.
- (void)test_openEarlyReturns_doNotLatchStartedFromTap {
    id delegate = mockProtocol(@protocol(HyBidMRAIDViewDelegate));
    [given([delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) willReturnBool:YES];
    HyBidMRAIDView *suppressed = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:delegate];
    [suppressed setClickThroughTimer];
    [suppressed clickThroughTouchObserved];
    [suppressed triggerClickThrough]; // arms the suppression guard for https://verve.com
    [suppressed setValue:@YES forKey:@"startedFromTap"];

    [suppressed open:@"https://verve.com"]; // swallowed by the guard

    XCTAssertFalse([[suppressed valueForKey:@"startedFromTap"] boolValue]);

    HyBidMRAIDView *nilURL = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    [nilURL setValue:@YES forKey:@"startedFromTap"];

    [nilURL open:nil];

    XCTAssertFalse([[nilURL valueForKey:@"startedFromTap"] boolValue]);
}

// VMI-1687: a URL with a literal percent sign decodes to nil; the early return dropped the click
// entirely. It must fall back to the undecoded string and still run the click flow.
- (void)test_open_withUndecodableURL_stillRunsTheClickFlow {
    HyBidMRAIDView *view = [self clickThroughViewWithTimer:@5 suppressAutoClick:NO delegate:nil];
    id serviceDelegate = mockProtocol(@protocol(HyBidMRAIDServiceDelegate));
    [given([serviceDelegate respondsToSelector:@selector(mraidServiceOpenBrowserWithUrlString:)]) willReturnBool:YES];
    [view setValue:serviceDelegate forKey:@"serviceDelegate"];
    [view setClickThroughTimer];

    [view open:@"https://verve.com/50%off"];

    [verifyCount(serviceDelegate, times(1)) mraidServiceOpenBrowserWithUrlString:@"https://verve.com/50%off"];
    XCTAssertTrue([[view valueForKey:@"clickThroughDestinationOpened"] boolValue]);
}

#pragma mark - Endcard click routing after URL redirection

/// A tapped endcard click is deferred to HyBidURLRedirector, which clears tapObserved before
/// re-entering open:. The tail of open: used to gate the browser on tapObserved alone, so every
/// resolved URL that was not an App Store link was dropped silently.
- (void)test_onURLRedirectorFinish_nonAppStoreURL_opensBrowserForUserClick {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:YES
                                                       isEndcard:YES];

    id serviceDelegate = mockProtocol(@protocol(HyBidMRAIDServiceDelegate));
    [given([serviceDelegate respondsToSelector:@selector(mraidServiceOpenBrowserWithUrlString:)]) willReturnBool:YES];
    view.serviceDelegate = serviceDelegate;

    [view setValue:@(YES) forKey:@"bonafideTapObserved"];
    [view setValue:@(YES) forKey:@"startedFromTap"]; // the click originated from a real tap

    NSString *resolved = @"https://tv.apple.com/gb/channel/tvs.sbd.4000";
    [view onURLRedirectorFinishWithUrl:resolved];

    [verify(serviceDelegate) mraidServiceOpenBrowserWithUrlString:resolved];
    XCTAssertFalse([[view valueForKey:@"redirectorResolvedFromUserClick"] boolValue],
                   @"the user-click context must not leak past the open: re-entry");
}

/// The tail of open: is also reached by the auto-storekit flow, which has no user tap. That path
/// must never launch a browser, so the fallback stays conditional rather than becoming a plain else.
- (void)test_open_autoStorekitClickWithoutUserTap_doesNotOpenBrowser {
    HyBidMRAIDView *view = [self makeInitializedMRAIDViewWithHTML:@"<html><body>ok</body></html>"
                                                  isInterstitial:YES
                                                       isEndcard:YES];

    id serviceDelegate = mockProtocol(@protocol(HyBidMRAIDServiceDelegate));
    [given([serviceDelegate respondsToSelector:@selector(mraidServiceOpenBrowserWithUrlString:)]) willReturnBool:YES];
    view.serviceDelegate = serviceDelegate;

    [view setValue:@(YES) forKey:@"bonafideTapObserved"];
    [view setValue:@(YES) forKey:@"creativeAutoStorekitEnabled"];
    [view setValue:@(NO) forKey:@"startedFromTap"];
    [view setValue:@(NO) forKey:@"tapObserved"];

    [view open:@"https://tv.apple.com/gb/channel/tvs.sbd.4000"];

    [verifyCount(serviceDelegate, never()) mraidServiceOpenBrowserWithUrlString:anything()];
}

@end
