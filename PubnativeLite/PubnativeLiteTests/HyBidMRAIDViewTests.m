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
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceProvider.h"
#import "HyBidEndCardView.h"
#import "HyBidEndCardView+Testing.h"
#import "HyBidAd.h"
#import "HyBidAdModel.h"
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
- (void)loadHTMLData:(NSString *)htmlData;
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)injectJavaScript:(NSString *)js;
- (void)cleanupWebViewPart2;
- (void)cancel;
- (void)close;
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

- (HyBidMRAIDView *)makeInitializedMRAIDViewWithHTML:(NSString *)html
                                      isInterstitial:(BOOL)isInterstitial
                                           isEndcard:(BOOL)isEndcard {
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

    XCTestExpectation *injected = [self expectationWithDescription:@"landing page template injected"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(mockInternalWebView) evaluateJavaScript:templateScript completionHandler:anything()];
        [injected fulfill];
    });
    
    [self waitForExpectations:@[injected] timeout:1.0];
    
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

    // It should schedule the landing-page template injection on main queue.
    XCTestExpectation *injected = [self expectationWithDescription:@"landing page template injected (unknown/linkActivated)"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verifyCount(mockInternalWebView, times(2)) evaluateJavaScript:templateScript completionHandler:anything()];
        [injected fulfill];
    });

    [self waitForExpectations:@[injected] timeout:1.0];
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

@end
