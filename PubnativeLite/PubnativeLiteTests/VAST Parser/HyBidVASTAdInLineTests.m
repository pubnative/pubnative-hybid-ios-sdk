//
//  Copyright © 2021 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"

@interface HyBidVASTAdInLineTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTAdInLineTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_InLine_Elements
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];

        // Ad Title
        NSString *firstAdTitle = [[firstAd inLine] adTitle];
        XCTAssertEqualObjects(firstAdTitle, @"PubNative Mobile Video");

        NSString *secondAdTitle = [[secondAd inLine] adTitle];
        XCTAssertEqualObjects(secondAdTitle, @"PubNative Mobile Video Two");

        // Ad Serving ID
        NSString *firstdServingID = [[firstAd inLine] adServingID];
        XCTAssertEqualObjects(firstdServingID, @"a532d16d-4d7f-4440-bd29-2ec0e693fc80");

        NSString *secondAdServingID = [[secondAd inLine] adServingID];
        XCTAssertEqualObjects(secondAdServingID, @"a532d16d-4d7f-4440-bd29-2ec0e693fc10");

        // Ad Description
        NSString *firstAdDescription = [[firstAd inLine] description];
        XCTAssertEqualObjects(firstAdDescription, @"Advanced Mobile Monetization");
        
        NSString *secondAdDescription = [[secondAd inLine] description];
        XCTAssertEqualObjects(secondAdDescription, @"Advanced Mobile Monetization2");

        NSString *firstAdvertiser = [[firstAd inLine] advertiser];
        XCTAssertEqualObjects(firstAdvertiser, @"IAB Sample Company");
        
        NSString *secondAdvertiser = [[secondAd inLine] advertiser];
        XCTAssertEqualObjects(secondAdvertiser, @"IAB Sample Company2");

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

