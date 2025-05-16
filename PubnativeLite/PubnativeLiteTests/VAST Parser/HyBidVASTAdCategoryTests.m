// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"

@interface HyBidVASTAdCategoryTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTAdCategoryTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_adCategory
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        HyBidVASTAdCategory *firstAdCategory = [[[firstAd inLine] categories] firstObject];
        HyBidVASTAdCategory *secondAdCategory = [[[secondAd inLine] categories] firstObject];
        
        // Authority attribute
        NSString *firstAuthority = [firstAdCategory authority];
        XCTAssertEqualObjects(firstAuthority, @"https://www.iabtechlab.com/categoryauthority");
        
        NSString *secondAuthority = [secondAdCategory authority];
        XCTAssertEqualObjects(secondAuthority, @"https://www.iabtechlab.com/categoryauthority2");
        
        // Content value
        NSString *firstCategoryValue = [firstAdCategory category];
        XCTAssertEqualObjects(firstCategoryValue, @"AD CONTENT description category");
        
        NSString *secondCategoryValue = [secondAdCategory category];
        XCTAssertEqualObjects(secondCategoryValue, @"AD CONTENT description category2");
        
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
