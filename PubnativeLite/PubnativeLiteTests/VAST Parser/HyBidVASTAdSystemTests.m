// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"

@interface HyBidVASTAdSystemTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTAdSystemTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_adSystem_attributes
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        HyBidVASTAdSystem *firstAdSystem = [[firstAd inLine] adSystem];
        XCTAssertNotNil(firstAdSystem);
        
        HyBidVASTAdSystem *secondAdSystem = [[secondAd inLine] adSystem];
        XCTAssertNotNil(secondAdSystem);

        NSString *firstAdSystemVersion = [firstAdSystem version];
        XCTAssertEqualObjects(firstAdSystemVersion, @"1.0");
        
        NSString *secondAdSystemVersion = [secondAdSystem version];
        XCTAssertEqualObjects(secondAdSystemVersion, @"2.0");

        NSString *secondSystem = [secondAdSystem system];
        XCTAssertEqualObjects(secondSystem, @"PubNative2");
        
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
