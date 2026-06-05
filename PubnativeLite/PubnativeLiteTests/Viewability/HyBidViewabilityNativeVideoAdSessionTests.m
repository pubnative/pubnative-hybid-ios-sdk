//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidViewabilityNativeVideoAdSession.h"
#import "HyBidOMIDAdSessionWrapper.h"

/// Fake OMID session used to cover wrapAndSetupOMIDSession:forView: when OMSDK is not linked.
/// Implements setMainAdView: and eventFilter so OMSDK code paths (e.g. getAdEvents) don't crash when OMSDK is linked.
@interface FakeOMIDAdSession : NSObject
@end
@implementation FakeOMIDAdSession
- (void)setMainAdView:(UIView *)view { (void)view; }
- (id)eventFilter { return nil; }
@end

/// Unit tests for HyBidViewabilityNativeVideoAdSession sharedInstance.
@interface HyBidViewabilityNativeVideoAdSessionTests : XCTestCase
@end

@implementation HyBidViewabilityNativeVideoAdSessionTests

- (void)testSharedInstance_returnsSingleton {
    HyBidViewabilityNativeVideoAdSession *a = [HyBidViewabilityNativeVideoAdSession sharedInstance];
    HyBidViewabilityNativeVideoAdSession *b = [HyBidViewabilityNativeVideoAdSession sharedInstance];
    XCTAssertNotNil(a);
    XCTAssertEqual(a, b);
}

- (void)testCreateOMIDAdSessionforNativeVideo_whenViewabilityInactive_returnsNil {
    UIView *view = [[UIView alloc] init];
    NSMutableArray *scripts = [NSMutableArray array];
    id result = [[HyBidViewabilityNativeVideoAdSession sharedInstance] createOMIDAdSessionforNativeVideo:view withScript:scripts];
    XCTAssertNil(result);
}

- (void)testSharedInstance_createOMID_doesNotCrash {
    // Exercise createOMID path (when viewability active may return wrapper; when inactive nil)
    UIView *view = [[UIView alloc] init];
    id result = [[HyBidViewabilityNativeVideoAdSession sharedInstance] createOMIDAdSessionforNativeVideo:view withScript:[NSMutableArray array]];
    (void)result;
}

/// Covers the block that runs when omidAdSession is non-nil: wrapper alloc, setMainAdView, getAdEvents, getMediaEvents.
/// Uses a fake session and the private wrapAndSetupOMIDSession:forView: so the path is hit without OMSDK linked.
- (void)testWrapAndSetupOMIDSession_forView_returnsWrapperAndSetsAdEvents {
    HyBidViewabilityNativeVideoAdSession *session = [HyBidViewabilityNativeVideoAdSession sharedInstance];
    FakeOMIDAdSession *fakeOMIDSession = [[FakeOMIDAdSession alloc] init];
    UIView *view = [[UIView alloc] init];

    SEL sel = NSSelectorFromString(@"wrapAndSetupOMIDSession:forView:");
    XCTAssertTrue([session respondsToSelector:sel], @"Private helper must exist for test.");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id result = [session performSelector:sel withObject:fakeOMIDSession withObject:view];
#pragma clang diagnostic pop

    XCTAssertNotNil(result, @"wrapAndSetupOMIDSession:forView: should return a wrapper.");
    XCTAssertTrue([result isKindOfClass:[HyBidOMIDAdSessionWrapper class]], @"Result should be HyBidOMIDAdSessionWrapper.");
    HyBidOMIDAdSessionWrapper *wrapper = (HyBidOMIDAdSessionWrapper *)result;
    XCTAssertEqual(wrapper.adSession, fakeOMIDSession, @"Wrapper should hold the fake session.");
}

// MARK: - fireOMID* coverage (early return when viewability inactive; exercises method bodies)
// fireOMIDAdLoadEvent is private (calls fireOMIDAdLoadEventWithSkipOffset:-1); we test the public selector only.
- (void)testFireOMIDAdLoadEventWithSkipOffset_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDAdLoadEventWithSkipOffset:5]);
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDAdLoadEventWithSkipOffset:-1]);
}

- (void)testFireOMIDStartEventWithDuration_withVolume_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDStartEventWithDuration:30 withVolume:1.0]);
}

- (void)testFireOMIDFirstQuartileEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDFirstQuartileEvent]);
}

- (void)testFireOMIDMidpointEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDMidpointEvent]);
}

- (void)testFireOMIDThirdQuartileEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDThirdQuartileEvent]);
}

- (void)testFireOMIDCompleteEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDCompleteEvent]);
}

- (void)testFireOMIDPauseEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDPauseEvent]);
}

- (void)testFireOMIDResumeEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDResumeEvent]);
}

- (void)testFireOMIDBufferStartEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDBufferStartEvent]);
}

- (void)testFireOMIDBufferFinishEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDBufferFinishEvent]);
}

- (void)testFireOMIDVolumeChangeEventWithVolume_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDVolumeChangeEventWithVolume:0.5]);
}

- (void)testFireOMIDSkippedEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDSkippedEvent]);
}

- (void)testFireOMIDClickedEvent_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDClickedEvent]);
}

- (void)testFireOMIDPlayerStateEventWithFullscreenInfo_doesNotCrash {
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDPlayerStateEventWithFullscreenInfo:YES]);
    XCTAssertNoThrow([[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDPlayerStateEventWithFullscreenInfo:NO]);
}

@end
