//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>
#import "HyBidVRVAdJIBridge.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif
#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

@interface HyBidVRVAdJIBridgeTests : XCTestCase
@end

@implementation HyBidVRVAdJIBridgeTests

- (void)test_injectIntoController_withValidController_doesNotCrash {
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    XCTAssertNoThrow([HyBidVRVAdJIBridge injectIntoController:controller]);
}

- (void)test_injectIntoController_withNilController_doesNotCrash {
    XCTAssertNoThrow([HyBidVRVAdJIBridge injectIntoController:nil]);
}

- (void)test_injectIntoController_controllerIsNotNilAfterCall {
    // Verify the controller object still exists after the call (no crashes, no nil side-effects)
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [HyBidVRVAdJIBridge injectIntoController:controller];
    XCTAssertNotNil(controller);
}

@end
