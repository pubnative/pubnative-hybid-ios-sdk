// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"

@interface HyBidVASTCreativeTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTCreativeTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_adCreatives_attributes
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
        
        XCTAssertEqualObjects([firstAdFirstCreative id], @"5481");
        XCTAssertEqualObjects([secondAdFirstCreative id], @"5483");
        
        XCTAssertEqualObjects([firstAdSecondCreative adID], @"2447227");
        XCTAssertEqualObjects([secondAdSecondCreative adID], @"2447229");
        
        XCTAssertEqualObjects([firstAdFirstCreative sequence], @"1");
        XCTAssertEqualObjects([secondAdSecondCreative sequence], @"4");
        
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
