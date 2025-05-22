// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"

@interface HyBidVASTUniversalAdIdTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTUniversalAdIdTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_adCreative_AdUniversalID_attributes
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        NSArray<HyBidVASTCreative *> *firstAdCreatives = [[firstAd inLine] creatives];
        NSArray<HyBidVASTCreative *> *secondAdCreatives = [[secondAd inLine] creatives];
        
        HyBidVASTCreative *firstAdFirstCreative = firstAdCreatives[0];
        HyBidVASTCreative *firstAdSecondCreative = firstAdCreatives[1];
        
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        HyBidVASTCreative *secondAdSecondCreative = secondAdCreatives[1];
        
        XCTAssertNotNil(firstAdFirstCreative);
        XCTAssertNotNil(firstAdSecondCreative);
        XCTAssertNotNil(secondAdFirstCreative);
        XCTAssertNotNil(secondAdSecondCreative);
        
        XCTAssertEqualObjects([[firstAdFirstCreative universalAdIds][0] universalAdId], @"8465");
        XCTAssertEqualObjects([[firstAdSecondCreative universalAdIds][0] universalAdId], @"8466");
        
        XCTAssertEqualObjects([[secondAdFirstCreative universalAdIds][0] universalAdId], @"8467");
        XCTAssertEqualObjects([[secondAdSecondCreative universalAdIds][0] universalAdId], @"8468");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_adCreative_AdUniversalID_values
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        NSArray<HyBidVASTCreative *> *firstAdCreatives = [[firstAd inLine] creatives];
        NSArray<HyBidVASTCreative *> *secondAdCreatives = [[secondAd inLine] creatives];
        
        HyBidVASTCreative *firstAdFirstCreative = firstAdCreatives[0];
        HyBidVASTCreative *firstAdSecondCreative = firstAdCreatives[1];
        
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        HyBidVASTCreative *secondAdSecondCreative = secondAdCreatives[1];
        
        XCTAssertNotNil(firstAdFirstCreative);
        XCTAssertNotNil(firstAdSecondCreative);
        XCTAssertNotNil(secondAdFirstCreative);
        XCTAssertNotNil(secondAdSecondCreative);
        
        XCTAssertEqualObjects([[firstAdFirstCreative universalAdIds][0] idRegistry], @"Ad-ID1");
        XCTAssertEqualObjects([[firstAdSecondCreative universalAdIds][0] idRegistry], @"Ad-ID2");
        
        XCTAssertEqualObjects([[secondAdFirstCreative universalAdIds][0] idRegistry], @"Foo-ID1");
        XCTAssertEqualObjects([[secondAdSecondCreative universalAdIds][0] idRegistry], @"FOO-ID2");
        
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
