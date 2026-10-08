//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>
#import "HyBidJSBeaconLoader.h"

static BOOL hyBidWebKitWarmedUp = NO;

/// Exercises HyBidJSBeaconLoader's real WKWebView round-trip - the path that
/// HyBidAdTrackerRequestTest/HyBidNativeAdTests stub out to stay deterministic in CI.
@interface HyBidJSBeaconLoaderTests : XCTestCase <WKNavigationDelegate>
@property (nonatomic, strong) XCTestExpectation *warmUpExpectation;
@end

@implementation HyBidJSBeaconLoaderTests

- (void)setUp {
    [super setUp];
    if (hyBidWebKitWarmedUp) { return; }
    // The first WKWebView on a freshly booted simulator (as on CI) takes 10s+ to spin up WebKit,
    // longer than the loader's own timeout. Pay that cost once so the tests measure the loader.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration new]];
    webView.navigationDelegate = self;
    self.warmUpExpectation = [self expectationWithDescription:@"WebKit warm-up"];
    [webView loadHTMLString:@"<html></html>" baseURL:nil];
    [self waitForExpectationsWithTimeout:60 handler:nil];
    webView.navigationDelegate = nil;
    hyBidWebKitWarmedUp = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.warmUpExpectation fulfill];
}

- (void)testLoadBeacon_withScriptTag_completesWithNoError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"beacon load completes"];
    __block NSError *capturedError = [NSError errorWithDomain:@"unset" code:0 userInfo:nil];

    [HyBidJSBeaconLoader loadBeacon:@"<script>var x = 1;</script>" completion:^(NSError * _Nullable error) {
        capturedError = error;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:15 handler:nil];
    XCTAssertNil(capturedError);
}

- (void)testLoadBeacon_withStalledLoad_completesWithTimeoutError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"beacon load times out"];
    __block NSError *capturedError = nil;

    // Blocks the page's main thread so didFinishNavigation never fires.
    [HyBidJSBeaconLoader loadBeacon:@"<script>while (true) {}</script>" completion:^(NSError * _Nullable error) {
        capturedError = error;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:20 handler:nil];
    XCTAssertEqualObjects(capturedError.domain, NSURLErrorDomain);
    XCTAssertEqual(capturedError.code, NSURLErrorTimedOut);
}

@end
