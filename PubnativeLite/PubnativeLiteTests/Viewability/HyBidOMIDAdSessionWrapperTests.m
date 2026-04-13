//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidOMIDAdSessionWrapper.h"

/// Fake session that responds to eventFilter so getAdEvents (OMSDK path) does not crash when OMSDK is linked.
@interface FakeOMIDSessionForWrapperTests : NSObject
@end
@implementation FakeOMIDSessionForWrapperTests
- (id)eventFilter { return nil; }
@end

/// Unit tests for HyBidOMIDAdSessionWrapper to improve coverage (init, no-op when session is nil).
@interface HyBidOMIDAdSessionWrapperTests : XCTestCase
@end

@implementation HyBidOMIDAdSessionWrapperTests

- (void)testInitWithAdSession_nilSession_storesNil {
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:nil];
    XCTAssertNotNil(wrapper);
    XCTAssertNil(wrapper.adSession);
}

- (void)testInitWithAdSession_validSession_storesSession {
    id fakeSession = [NSObject new];
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:fakeSession];
    XCTAssertNotNil(wrapper);
    XCTAssertEqual(wrapper.adSession, fakeSession);
}

- (void)testAddFriendlyObstruction_nilSession_doesNotCrash {
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:nil];
    UIView *view = [[UIView alloc] init];
    XCTAssertNoThrow([wrapper addFriendlyObstruction:view withReason:@"test" isInterstitial:NO]);
}

- (void)testAddFriendlyObstruction_nilView_doesNotCrash {
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:[NSObject new]];
    XCTAssertNoThrow([wrapper addFriendlyObstruction:nil withReason:@"test" isInterstitial:YES]);
}

- (void)testStartAdSession_nilSession_doesNotCrash {
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:nil];
    XCTAssertNoThrow([wrapper startAdSession]);
}

- (void)testStopAdSession_nilSession_doesNotCrash {
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:nil];
    XCTAssertNoThrow([wrapper stopAdSession]);
}

- (void)testFireAdLoadEvent_nilSession_doesNotCrash {
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:nil];
    XCTAssertNoThrow([wrapper fireAdLoadEvent]);
}

- (void)testFireAdLoadEvent_nonNilSession_noAdEvents_coversElseBranch {
    // When getAdEvents returns nil (or fake doesn't create real ad events), implementation logs and returns (else branch).
    // Use a fake that responds to eventFilter so OMSDK's getAdEvents path doesn't crash when OMSDK is linked.
    id fakeSession = [[FakeOMIDSessionForWrapperTests alloc] init];
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:fakeSession];
    XCTAssertNoThrow([wrapper fireAdLoadEvent]);
}

@end
