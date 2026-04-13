//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidViewabilityAdSession.h"
#import "HyBidOMIDAdSessionWrapper.h"

/// Unit tests for HyBidViewabilityAdSession (sharedInstance, start/stop/fire with nil or inactive).
@interface HyBidViewabilityAdSessionTests : XCTestCase
@end

@implementation HyBidViewabilityAdSessionTests

- (void)testSharedInstance_returnsSingleton {
    HyBidViewabilityAdSession *a = [HyBidViewabilityAdSession sharedInstance];
    HyBidViewabilityAdSession *b = [HyBidViewabilityAdSession sharedInstance];
    XCTAssertNotNil(a);
    XCTAssertEqual(a, b);
}

- (void)testStartOMIDAdSession_withNilWrapper_doesNotCrash {
    // When viewability is inactive or wrapper is nil, implementation returns early
    HyBidViewabilityAdSession *session = [HyBidViewabilityAdSession sharedInstance];
    XCTAssertNoThrow([session startOMIDAdSession:nil]);
}

- (void)testStopOMIDAdSession_withNilWrapper_doesNotCrash {
    HyBidViewabilityAdSession *session = [HyBidViewabilityAdSession sharedInstance];
    XCTAssertNoThrow([session stopOMIDAdSession:nil]);
}

- (void)testFireOMIDImpressionOccuredEvent_withNilWrapper_doesNotCrash {
    HyBidViewabilityAdSession *session = [HyBidViewabilityAdSession sharedInstance];
    XCTAssertNoThrow([session fireOMIDImpressionOccuredEvent:nil]);
}

- (void)testFireOMIDAdLoadEvent_withNilWrapper_doesNotCrash {
    HyBidViewabilityAdSession *session = [HyBidViewabilityAdSession sharedInstance];
    XCTAssertNoThrow([session fireOMIDAdLoadEvent:nil]);
}

- (void)testAddFriendlyObstruction_withNilView_doesNotCrash {
    UIView *view = nil;
    HyBidOMIDAdSessionWrapper *wrapper = [[HyBidOMIDAdSessionWrapper alloc] initWithAdSession:nil];
    HyBidViewabilityAdSession *session = [HyBidViewabilityAdSession sharedInstance];
    XCTAssertNoThrow([session addFriendlyObstruction:view
                                    toOMIDAdSession:wrapper
                                         withReason:@"test"
                                     isInterstitial:NO]);
}

@end
