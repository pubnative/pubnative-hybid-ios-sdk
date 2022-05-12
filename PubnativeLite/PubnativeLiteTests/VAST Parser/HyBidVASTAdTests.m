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

@interface HyBidVASTAdTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTAdTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_init_withValidData_shouldGetAdType
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        // Ad checks
        XCTAssertNotNil(firstAd);
        XCTAssertNotNil(secondAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        // Ad Type
        HyBidVASTAdType firstAdType = [firstAd adType];
        HyBidVASTAdType expectedFirstAdType = HyBidVASTAdType_INLINE;
        XCTAssertEqual(firstAdType, expectedFirstAdType);
        XCTAssertNotEqual(firstAdType, HyBidVASTAdType_WRAPPER);
        
        HyBidVASTAdType secondAdType = [secondAd adType];
        HyBidVASTAdType expectedSecondAdType = HyBidVASTAdType_INLINE;
        XCTAssertEqual(secondAdType, expectedSecondAdType);
        XCTAssertNotEqual(secondAdType, HyBidVASTAdType_WRAPPER);
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_withValidData_shouldGet_Valid_VASTAdAttributes
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        // IDs
        NSString *firstAdID = [firstAd id];
        XCTAssertEqualObjects(firstAdID, @"223626102");
        
        NSString *secondAdID = [secondAd id];
        XCTAssertEqualObjects(secondAdID, @"223626103");
        
        // Sequences
        NSString *firstAdSequence = [firstAd sequence];
        XCTAssertEqualObjects(firstAdSequence, @"1");
        
        NSString *secondAdSequence = [secondAd sequence];
        XCTAssertEqualObjects(secondAdSequence, @"2");

        // isConditional
        BOOL firstIsConditionalAd = [firstAd isConditionalAd];
        XCTAssertEqual(firstIsConditionalAd, YES);
        
        BOOL secondIsConditionalAd = [secondAd isConditionalAd];
        XCTAssertEqual(secondIsConditionalAd, NO);

//        // Ad Title
//        NSString *firstAdTitle = [firstAd adTitle];
//        XCTAssertEqualObjects(firstAdTitle, @"PubNative Mobile Video");
//
//        NSString *secondAdTitle = [secondAd adTitle];
//        XCTAssertEqualObjects(secondAdTitle, @"PubNative Mobile Video Two");
//
//        // adServingID
//        NSString *firstdServingID = [firstAd adServingID];
//        XCTAssertEqualObjects(firstdServingID, @"a532d16d-4d7f-4440-bd29-2ec0e693fc80");
//
//        NSString *secondAdServingID = [secondAd adServingID];
//        XCTAssertEqualObjects(secondAdServingID, @"a532d16d-4d7f-4440-bd29-2ec0e693fc10");
//
//        NSString *adDescription = [firstAd adDescription];
//        NSString *expectedAdDescription = @"Advanced Mobile Monetization";
//        XCTAssertEqualObjects(adDescription, expectedAdDescription);
//
//        NSString *advertiser = [firstAd advertiser];
//        NSString *expectedAdvertiser = @"IAB Sample Company";
//        XCTAssertEqualObjects(advertiser, expectedAdvertiser);
//
//        HyBidVASTAdCategory *category = [firstAd category];
//
//        NSString *authority = [category authority];
//        NSString *expectedAuthority = @"https://www.iabtechlab.com/categoryauthority";
//        XCTAssertEqualObjects(authority, expectedAuthority);
//
//        NSString *categoryValue = [category category];
//        NSString *expectedCategoryValue = @"AD CONTENT description category";
//        XCTAssertEqualObjects(categoryValue, expectedCategoryValue);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_inlineAd
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];
    
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        // InLine Ads
        HyBidVASTAdInline *firstInlineAd = [firstAd inLine];
        XCTAssertNotNil(firstInlineAd);
        
        HyBidVASTAdInline *secondInlineAd = [secondAd inLine];
        XCTAssertNotNil(secondInlineAd);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_wrapperAd
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];
    
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        // Wrapper Ads
        HyBidVASTAdWrapper *firstWrapperAd = [firstAd wrapper];
        XCTAssertNil(firstWrapperAd);
        
        HyBidVASTAdWrapper *secondWrapperAd = [secondAd wrapper];
        XCTAssertNil(secondWrapperAd);
        
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
