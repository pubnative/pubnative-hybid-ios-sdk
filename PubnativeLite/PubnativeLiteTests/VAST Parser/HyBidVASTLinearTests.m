// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"

@interface HyBidVASTLinearTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTLinearTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_adLinear {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_linear"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [vastModel ads][0];
        
        XCTAssertEqualObjects([[[firstAd inLine] adSystem] system], @"Liftoff");
        XCTAssertEqualObjects([[firstAd inLine] adTitle], @"277051");
        
        NSArray<HyBidVASTCreative *> *firstAdCreatives = [[firstAd inLine] creatives];
        
        HyBidVASTCreative *firstAdFirstCreative = firstAdCreatives[0];
        HyBidVASTCreative *firstAdSecondCreative = firstAdCreatives[1];
        
        
        XCTAssertNotNil([firstAdFirstCreative linear]);
        XCTAssertNotNil([firstAdSecondCreative companionAds]);
        
        XCTAssertEqualObjects(firstAdFirstCreative.linear.duration, @"00:00:43");
        
        XCTAssertEqual(firstAdFirstCreative.linear.mediaFiles.mediaFiles.count, 1);
        HyBidVASTMediaFile *mediaFile = firstAdFirstCreative.linear.mediaFiles.mediaFiles.firstObject;
        XCTAssertEqualObjects([mediaFile width], @"360");
        XCTAssertEqualObjects([mediaFile height], @"640");
        XCTAssertEqualObjects(mediaFile.type, @"video/mp4");
        XCTAssertTrue([mediaFile.url hasSuffix:@".mp4"]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

// MARK: - Helper Methods

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
