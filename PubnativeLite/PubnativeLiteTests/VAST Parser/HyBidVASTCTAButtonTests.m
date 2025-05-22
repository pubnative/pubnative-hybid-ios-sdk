// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"
#import "HyBidVASTCTAButton.h"

@interface HyBidVASTCTAButtonTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTCTAButtonTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_cta_button_values
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_cta_button_example"] dataUsingEncoding:NSUTF8StringEncoding];
        
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        
        HyBidVASTCTAButton *ctaButton = [[firstAd inLine] ctaButton];
        
        XCTAssertNotNil(ctaButton);
        XCTAssertNotNil([ctaButton htmlData]);
        
        HyBidVASTTrackingEvents *trackingEvents = [ctaButton trackingEvents];
        XCTAssertNotNil(trackingEvents);
        XCTAssertNotEqual([[trackingEvents events] count], 0);
        
        HyBidVASTTracking *firstEvent = [[trackingEvents events] firstObject];
        XCTAssertEqualObjects([firstEvent event], @"CTAClick");
        XCTAssertEqualObjects([firstEvent url], @"https://got.pubnative.net/video/event");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

// MARK: - Helper Methods

- (NSString *)readFromTxtFileNamed:(NSString *)name
{
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
