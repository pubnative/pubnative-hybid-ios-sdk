//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"
#import "HyBidXMLEx.h"

@interface HyBidVASTWrapperTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTWrapperTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_wrapper_parser {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    // Replace whatever VASTAdTagURI is in the XML with the local bundle file so
    // the test is network-independent and reliable on CI.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *inlinePath = [bundle pathForResource:@"vast_wrapper_inline" ofType:@"xml"];
    NSURL *inlineFileURL = [NSURL fileURLWithPath:inlinePath];

    NSString *vastString = [self readFromTxtFileNamed:@"vast_wrapper"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=<VASTAdTagURI><!\\[CDATA\\[).*?(?=\\]\\]></VASTAdTagURI>)"
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:nil];
    vastString = [regex stringByReplacingMatchesInString:vastString
                                                 options:0
                                                   range:NSMakeRange(0, vastString.length)
                                            withTemplate:inlineFileURL.absoluteString];
    NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *vastError) {
        XCTAssertNotNil(vastModel);
        
        NSOrderedSet *vastSet = [[NSOrderedSet alloc] initWithArray:vastModel.vastArray];
        NSArray* vastArray = [[NSMutableArray alloc] initWithArray:[vastSet array]];
        XCTAssertEqual(vastArray.count, 2);
        
        for (NSData *vast in vastArray) {
            NSString *xml = [[NSString alloc] initWithData:vast encoding:NSUTF8StringEncoding];
            HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
            NSArray *result = [[parser rootElement] query:@"Ad"];
            
            for (int i = 0; i < [result count]; i++) {
                HyBidVASTAd * ad;
                if (result[i]) {
                    ad = [[HyBidVASTAd alloc] initWithXMLElement:result[i]];
                }
                if (vast == vastArray[0]) {
                    XCTAssertNotNil([ad wrapper]);

                    HyBidVASTAdWrapper *wrapper = [ad wrapper];
                    XCTAssertEqualObjects([[wrapper adSystem] system], @"Criteo");
                    XCTAssertTrue(wrapper.impressions.count >= 1);
                    XCTAssertNotNil(wrapper.errors);
          
                    HyBidVASTCreative *creative = wrapper.creatives.firstObject;
                    XCTAssertNotNil(creative.linear);
                    HyBidVASTLinear *linear = creative.linear;
                    XCTAssertTrue(linear.videoClicks.clickTrackings.count > 0);
                }
                if (vast == vastArray[1]) {
                    XCTAssertNotNil([ad inLine]);
                }
            }
        }
        
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
