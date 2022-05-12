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

@interface HyBidVASTCompanionTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTCompanionTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_companion_attributes
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
        
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        
        HyBidVASTCompanionAds *firstCompanionAds = [firstAdFirstCreative companionAds];
        HyBidVASTCompanionAds *secondCompanionAds = [secondAdFirstCreative companionAds];
        
        XCTAssertNotNil(firstCompanionAds);
        XCTAssertNotNil(secondCompanionAds);
        
        HyBidVASTCompanion *firstAdFirstCompanion = [firstCompanionAds companions][0];
        HyBidVASTCompanion *secondAdFirstCompanion = [secondCompanionAds companions][0];
        
        // ID
        XCTAssertEqualObjects([firstAdFirstCompanion id], @"1232");
        
        // Width
        XCTAssertEqualObjects([firstAdFirstCompanion width], @"100");
        XCTAssertEqualObjects([secondAdFirstCompanion width], @"101");
        
        // Height
        XCTAssertEqualObjects([secondAdFirstCompanion height], @"151");
        
        // Asset Height
        XCTAssertEqualObjects([firstAdFirstCompanion assetHeight], @"200");
        
        // Asset Width
        XCTAssertEqualObjects([secondAdFirstCompanion assetWidth], @"251");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_companion_static_resources
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
        
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        
        HyBidVASTCompanionAds *firstCompanionAds = [firstAdFirstCreative companionAds];
        HyBidVASTCompanionAds *secondCompanionAds = [secondAdFirstCreative companionAds];
        
        XCTAssertNotNil(firstCompanionAds);
        XCTAssertNotNil(secondCompanionAds);
        
        HyBidVASTCompanion *firstAdFirstCompanion = [firstCompanionAds companions][0];
        HyBidVASTCompanion *secondAdSecondCompanion = [secondCompanionAds companions][1];
        
        NSArray<HyBidVASTStaticResource *> *firstCompanionStaticResources = [firstAdFirstCompanion staticResources];
        NSArray<HyBidVASTStaticResource *> *thirdCompanionStaticResources = [secondAdSecondCompanion staticResources];
        
        XCTAssertTrue([firstCompanionStaticResources count] == 1);
        XCTAssertTrue([thirdCompanionStaticResources count] == 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_companion_tracking_events
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *secondAd = [vastModel ads][1];
        NSArray<HyBidVASTCreative *> *secondAdCreatives = [[secondAd inLine] creatives];
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        HyBidVASTCompanionAds *secondCompanionAds = [secondAdFirstCreative companionAds];
        HyBidVASTCompanion *secondAdFirstCompanion = [secondCompanionAds companions][0];
        
        HyBidVASTTrackingEvents *trackingEvents = [secondAdFirstCompanion trackingEvents];
        XCTAssertNotEqual(trackingEvents, nil);
        XCTAssertEqual([[trackingEvents events] count], 2);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_companion_click_through
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *firstAd = [vastModel ads][0];
        
        NSArray<HyBidVASTCreative *> *firstAdCreatives = [[firstAd inLine] creatives];
        HyBidVASTCreative *firstAdFirstCreative = firstAdCreatives[0];
        HyBidVASTCompanionAds *firstCompanionAds = [firstAdFirstCreative companionAds];
        HyBidVASTCompanion *firstAdFirstCompanion = [firstCompanionAds companions][0];
        HyBidVASTCompanionClickThrough *companionClickThrough = [firstAdFirstCompanion companionClickThrough];
        
        XCTAssertNotNil(companionClickThrough);
        XCTAssertEqualObjects([companionClickThrough content], @"https://pubnative.net1");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_companion_html_resource
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        // Ads
        HyBidVASTAd *secondAd = [vastModel ads][1];
        NSArray<HyBidVASTCreative *> *secondAdCreatives = [[secondAd inLine] creatives];
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        HyBidVASTCompanionAds *secondCompanionAds = [secondAdFirstCreative companionAds];
        HyBidVASTCompanion *secondAdFirstCompanion = [secondCompanionAds companions][0];
        
        NSArray<HyBidVASTHTMLResource *> *htmlResources = [secondAdFirstCompanion htmlResources];
        XCTAssertNotEqual([htmlResources count], 0);
        
        HyBidVASTHTMLResource *firstHtmlResource = [secondAdFirstCompanion htmlResources][0];
        XCTAssertEqualObjects([firstHtmlResource content], @"<img src=\"https://cdn.pubnative.net/widget/v3/assets/easyforecast_320x480.jpg\">");
        
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
