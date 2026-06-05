//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>
#import "HyBidViewabilityWebAdSession.h"

/// Unit tests for HyBidViewabilityWebAdSession sharedInstance and createOMID when viewability inactive.
@interface HyBidViewabilityWebAdSessionTests : XCTestCase
@end

@implementation HyBidViewabilityWebAdSessionTests

- (void)testSharedInstance_returnsSingleton {
    HyBidViewabilityWebAdSession *a = [HyBidViewabilityWebAdSession sharedInstance];
    HyBidViewabilityWebAdSession *b = [HyBidViewabilityWebAdSession sharedInstance];
    XCTAssertNotNil(a);
    XCTAssertEqual(a, b);
}

- (void)testCreateOMIDAdSessionforWebView_callsCreateOMID {
    // Result depends on isViewabilityMeasurementActivated and OMSDK; just assert no crash
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[[WKWebViewConfiguration alloc] init]];
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidViewabilityWebAdSession sharedInstance] createOMIDAdSessionforWebView:webView isVideoAd:NO];
    (void)wrapper;
}

@end
