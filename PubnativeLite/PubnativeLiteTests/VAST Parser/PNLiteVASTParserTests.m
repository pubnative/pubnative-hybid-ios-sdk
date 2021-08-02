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
#import "PNLiteVASTParser.h"
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNLiteVASTXMLUtil.h"

NSString *const vastXML_URL = @"https://raw.githubusercontent.com/InteractiveAdvertisingBureau/VAST_Samples/master/VAST%201-2.0%20Samples/Inline_LinearRegular_VAST2.0.xml";

@interface PNLiteVASTParserTests : XCTestCase

@property (nonatomic, strong) PNLiteVASTParser *parser;

@end

@implementation PNLiteVASTParserTests

- (void)setUp {
    self.parser = [[PNLiteVASTParser alloc] init];
}

- (void)test_parseWithUrl_withValidURL_shouldCallbackSuccess
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];
    
    [self.parser parseWithUrl:[[NSURL alloc] initWithString:vastXML_URL] completion:^(PNLiteVASTModel *vastModel, PNLiteVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        XCTAssertEqual(vastError, PNLiteVASTParserError_None);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_parseWithUrl_withInvalidURL_shouldCallbackFail
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];
    
    [self.parser parseWithUrl:nil completion:^(PNLiteVASTModel *vastModel, PNLiteVASTParserError vastError) {
        XCTAssertNil(vastModel);
        XCTAssertNotEqual(vastError, PNLiteVASTParserError_None);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_parseWithData_withValidData_shouldCallbackSuccess
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:@"vast_mock_success" ofType:@"txt"];
    
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        XCTFail(@"Error reading file: %@", error.localizedDescription);
    }
    
    NSData *vastData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(PNLiteVASTModel *vastModel, PNLiteVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        XCTAssertEqual(vastError, PNLiteVASTParserError_None);

        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_parseWithData_withInvalidData_shouldCallbackFail
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:@"vast_mock_fail" ofType:@"txt"];

    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        XCTFail(@"Error reading file: %@", error.localizedDescription);
    }

    NSData *vastData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];

    [self.parser parseWithData:vastData completion:^(PNLiteVASTModel *vastModel, PNLiteVASTParserError vastError) {
        XCTAssertNil(vastModel);
        XCTAssertNotEqual(vastError, PNLiteVASTParserError_None);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_parseWithData_withNullData_shouldCallbackFail
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = NULL;

    [self.parser parseWithData:vastData completion:^(PNLiteVASTModel *vastModel, PNLiteVASTParserError vastError) {
        XCTAssertNil(vastModel);
        XCTAssertNotEqual(vastError, PNLiteVASTParserError_None);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)tearDown {
    self.parser = nil;
}

@end
