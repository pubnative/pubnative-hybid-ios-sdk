// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"

@interface HyBidTrackingEventTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidTrackingEventTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_companion_tracking_events {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *secondAd = [vastModel ads][1];
        NSArray<HyBidVASTCreative *> *secondAdCreatives = [[secondAd inLine] creatives];
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        HyBidVASTCreative *secondAdSecondCreative = secondAdCreatives[1];
        
        HyBidVASTCompanionAds *secondCompanionAds = [secondAdFirstCreative companionAds];
        HyBidVASTCompanion *secondAdFirstCompanion = [secondCompanionAds companions][0];
        HyBidVASTLinear *secondAdLinear = [secondAdSecondCreative linear];
        
        HyBidVASTTrackingEvents *trackingEventsFromCompanion = [secondAdFirstCompanion trackingEvents];
        XCTAssertNotEqual(trackingEventsFromCompanion, nil);
        XCTAssertEqual([[trackingEventsFromCompanion events] count], 2);
        
        HyBidVASTTracking *creativeViewEvent = [trackingEventsFromCompanion events].firstObject;
        XCTAssertEqualObjects([creativeViewEvent event], HyBidVASTAdTrackingEventType_creativeView);
        
        HyBidVASTTrackingEvents *trackingEventsFromLinear = [secondAdLinear trackingEvents];
        XCTAssertNotEqual(trackingEventsFromLinear, nil);
        XCTAssertEqual([[trackingEventsFromLinear events] count], 29);
        
        HyBidVASTTracking *startEvent = [trackingEventsFromLinear events][0];
        HyBidVASTTracking *midpointEvent = [trackingEventsFromLinear events][1];
        HyBidVASTTracking *firstQuartileEvent = [trackingEventsFromLinear events][4];
        HyBidVASTTracking *muteEvent = [trackingEventsFromLinear events][9];
        HyBidVASTTracking *closeEvent = [trackingEventsFromLinear events][28];
        
        XCTAssertEqualObjects([startEvent event], HyBidVASTAdTrackingEventType_start);
        XCTAssertEqualObjects([midpointEvent event], HyBidVASTAdTrackingEventType_midpoint);
        XCTAssertEqualObjects([firstQuartileEvent event], HyBidVASTAdTrackingEventType_firstQuartile);
        XCTAssertEqualObjects([muteEvent event], HyBidVASTAdTrackingEventType_mute);
        XCTAssertEqualObjects([closeEvent event], HyBidVASTAdTrackingEventType_close);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (NSString *)readFromTxtFileNamed:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:name ofType:@"xml"];

    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        XCTFail(@"Error reading file: %@", error.localizedDescription);
        return nil;
    }

    return fileContents;
}

@end
