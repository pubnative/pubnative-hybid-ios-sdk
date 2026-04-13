//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidViewabilityNativeAdSession.h"
#import "HyBidOMIDAdSessionWrapper.h"

/// Fake session that responds to eventFilter so getAdEvents (OMSDK path) does not crash when OMSDK is linked.
@interface FakeOMIDSessionForNativeAdSessionTests : NSObject
@end
@implementation FakeOMIDSessionForNativeAdSessionTests
- (id)eventFilter { return nil; }
@end

/// Unit tests for HyBidViewabilityNativeAdSession sharedInstance and createOMID when viewability inactive.
@interface HyBidViewabilityNativeAdSessionTests : XCTestCase
@end

@implementation HyBidViewabilityNativeAdSessionTests

- (void)testSharedInstance_returnsSingleton {
    HyBidViewabilityNativeAdSession *a = [HyBidViewabilityNativeAdSession sharedInstance];
    HyBidViewabilityNativeAdSession *b = [HyBidViewabilityNativeAdSession sharedInstance];
    XCTAssertNotNil(a);
    XCTAssertEqual(a, b);
}

- (void)testCreateOMIDAdSessionforNative_withViewability_callsCreateOMID {
    // When viewability is active (e.g. in test env with OMSDK), may return wrapper; when inactive, returns nil.
    UIView *view = [[UIView alloc] init];
    NSMutableArray *scripts = [NSMutableArray array];
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidViewabilityNativeAdSession sharedInstance] createOMIDAdSessionforNative:view withScript:scripts];
    // Just assert the method returns without crashing; result depends on isViewabilityMeasurementActivated and OMSDK
    (void)wrapper;
}

// MARK: - fireOMIDAdLoadEvent: coverage (HyBidViewabilityNativeAdSession override: getAdEvents, loadedWithError, error logging)

- (void)testFireOMIDAdLoadEvent_nilWrapper_doesNotCrash {
    HyBidViewabilityNativeAdSession *session = [HyBidViewabilityNativeAdSession sharedInstance];
    XCTAssertNoThrow([session fireOMIDAdLoadEvent:nil]);
}

- (void)testFireOMIDAdLoadEvent_nonNilWrapper_doesNotCrash {
    // Covers: omidAdSessionWrapper non-nil → getAdEvents, optional loadedWithError, optional error log.
    // Use fake session with eventFilter so getAdEvents does not crash when OMSDK is linked.
    id fakeSession = [[FakeOMIDSessionForNativeAdSessionTests alloc] init];
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:fakeSession];
    HyBidViewabilityNativeAdSession *session = [HyBidViewabilityNativeAdSession sharedInstance];
    XCTAssertNoThrow([session fireOMIDAdLoadEvent:wrapper]);
}

@end
