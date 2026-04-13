//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import "HyBidVASTTrackingEvents.h"
#import "HyBidXMLElementEx.h"
#import "HyBidVASTTracking.h"

@interface HyBidVASTTrackingEventsTest : XCTestCase
@end

@implementation HyBidVASTTrackingEventsTest

- (void)test_initWithNilTrackingEventsXMLElement_returnsNil {
    HyBidVASTTrackingEvents *events = [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:nil];
    XCTAssertNil(events, @"Should return nil if input XML element is nil");
}

- (void)test_initWithValidTrackingEventsXMLElement_setsProperty {
    HyBidXMLElementEx *mockElement = mock([HyBidXMLElementEx class]);
    HyBidVASTTrackingEvents *events = [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:mockElement];
    XCTAssertNotNil(events, @"Object should not be nil when initialized with a valid element");
}

- (void)test_events_returnsArrayOfTrackingObjects {
    // Arrange
    HyBidXMLElementEx *mockTrackingEventsElement = mock([HyBidXMLElementEx class]);
    HyBidXMLElementEx *child1 = mock([HyBidXMLElementEx class]);
    HyBidXMLElementEx *child2 = mock([HyBidXMLElementEx class]);
    NSArray *childElements = @[child1, child2];

    [given([mockTrackingEventsElement query:@"/Tracking"]) willReturn:childElements];

    // Act
    HyBidVASTTrackingEvents *events = [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:mockTrackingEventsElement];
    NSArray *results = [events events];

    // Assert
    XCTAssertEqual(results.count, 2, @"Should return two tracking objects");
    XCTAssertTrue([results[0] isKindOfClass:[HyBidVASTTracking class]]);
    XCTAssertTrue([results[1] isKindOfClass:[HyBidVASTTracking class]]);
}

- (void)test_events_returnsEmptyArrayIfNoTrackingElements {
    HyBidXMLElementEx *mockTrackingEventsElement = mock([HyBidXMLElementEx class]);
    [given([mockTrackingEventsElement query:@"/Tracking"]) willReturn:@[]];

    HyBidVASTTrackingEvents *events = [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:mockTrackingEventsElement];
    NSArray *result = [events events];
    XCTAssertNotNil(result, @"Should return an array");
    XCTAssertEqual(result.count, 0, @"Should return empty array when no tracking nodes");
}

@end
