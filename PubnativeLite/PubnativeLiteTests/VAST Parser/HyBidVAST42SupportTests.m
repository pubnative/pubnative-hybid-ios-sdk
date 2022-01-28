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
#import "HyBidVASTModel.h"
#import "HyBidVASTParser.h"

@interface HyBidVAST42SupportTests : XCTestCase

@property (nonatomic, strong) HyBidVASTAd *ad;

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVAST42SupportTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)test_init_withValidData_shouldGetAdType
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTAdType adType = [firstAd adType];
        HyBidVASTAdType expectedAdType = HyBidVASTAdType_INLINE;
        XCTAssertEqual(adType, expectedAdType);
        XCTAssertNotEqual(adType, HyBidVASTAdType_WRAPPER);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_withValidData_shouldGet_Valid_VASTAdPropertyValues
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        NSString *adID = [firstAd id];
        NSString *expectedAdID = @"223626102";
        XCTAssertEqualObjects(adID, expectedAdID);
        
        NSString *adSequence = [firstAd sequence];
        NSString *expectedAdSequence = @"1";
        XCTAssertEqualObjects(adSequence, expectedAdSequence);
        
        BOOL isConditionalAd = [firstAd isConditionalAd];
        BOOL expectedIsConditionalAd = YES;
        XCTAssertEqual(isConditionalAd, expectedIsConditionalAd);
        
        NSString *adTitle = [firstAd adTitle];
        NSString *expectedAdTitle = @"PubNative Mobile Video";
        XCTAssertEqualObjects(adTitle, expectedAdTitle);
        
        NSString *adServingID = [firstAd adServingID];
        NSString *expectedAdServingID = @"a532d16d-4d7f-4440-bd29-2ec0e693fc80";
        XCTAssertEqualObjects(adServingID, expectedAdServingID);
        
        NSString *adDescription = [firstAd adDescription];
        NSString *expectedAdDescription = @"Advanced Mobile Monetization";
        XCTAssertEqualObjects(adDescription, expectedAdDescription);
        
        NSString *advertiser = [firstAd advertiser];
        NSString *expectedAdvertiser = @"IAB Sample Company";
        XCTAssertEqualObjects(advertiser, expectedAdvertiser);
        
        HyBidVASTAdCategory *category = [firstAd category];
        
        NSString *authority = [category authority];
        NSString *expectedAuthority = @"https://www.iabtechlab.com/categoryauthority";
        XCTAssertEqualObjects(authority, expectedAuthority);
        
        NSString *categoryValue = [category category];
        NSString *expectedCategoryValue = @"AD CONTENT description category";
        XCTAssertEqualObjects(categoryValue, expectedCategoryValue);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_withValidData_shouyldGet_Valid_VASTAdSystemPropertyValues
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTAdSystem *adSystem = [firstAd adSystem];
        XCTAssertNotNil(adSystem);
        
        NSString *adSystemVersion = [adSystem version];
        NSString *expectedAdSystemVersion = @"1.0";
        XCTAssertEqualObjects(adSystemVersion, expectedAdSystemVersion);
        
        NSString *system = [adSystem system];
        NSString *expectedSystem = @"PubNative";
        XCTAssertEqualObjects(system, expectedSystem);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_withValidData_shouldGet_Valid_ImpressionPropertyValues
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        NSArray *impressions = [firstAd impressions];
        XCTAssertNotEqual([impressions count], 0);
        
        HyBidVASTImpression *firstImpression = [impressions firstObject];
        NSString *impressionID = [firstImpression id];
        NSString *expectedImpressionID = @"Impression-ID1";
        XCTAssertEqualObjects(impressionID, expectedImpressionID);
        
        HyBidVASTImpression *fourthImpression = [impressions lastObject];
        NSString *fourthImpressionID = [fourthImpression id];
        NSString *expectedFourthImpressionID = @"Impression-ID4";
        XCTAssertEqualObjects(fourthImpressionID, expectedFourthImpressionID);
        
        NSString *impressionURL = [firstImpression url];
        NSString *expectedImpressionURL = @"https://got.pubnative.net/impression?aid=1039073&t=5zPfS_J4M2rcOLoGaeeyHsjJxHfbRYnCaHvmTdgyodM1FzSRjb6R8A3cxUGQd-LqFnwas81gIu0t9l27-fNsCv9BRsgUXxcpQljamzGQEOaKLRrv83IjQrwbSzu6IOBoO08Muj8B8lvPA8gWxeZnuqRx0_bZ3HnC2ShAtFkddlHwk3XgrHK25Zmnp1SPnEdrgqcCwS1knL8d0s5EioYNBYTOSSRTqTrsbq9rsJ2USjPyf7N-ktN200IaoGf9HWYe6oNAgiUZkTAfRx1lLPSNfk0IsKPT6TIW3zRxEdw-R0qsuMrm8GfXk5ZavYeCISYxqgoOxYrmV7j3EALxdfd3iMIncZRGgN8ucMiAzFbC_IIzOG9Mq6pX3eQi14iM_e03Noonlo6RnQhoXsG9M6KTJOBH5RJcU60v6NLwKJhzgUywSKlUbIc0rk_vhnzvgbIgEk4_mE6eO-yw-UOgOdJXX3SicEDPJK3JZ0iNTr-4NznH5abC6asaIJBZ1TjvKeKPow2_kYWx3wIYndb2mOXoUeMdH43y6wVqD-RdfFN-Xvgo4wEcOCbNzswczHR70XrAxbPg4-q6gxOj6EKaogJsdb9bHU55yeTZITycYRs8RjDNoc9N61wZfjXUfFRJQG89JSrLACoxuZiw6gdr-RaIvRYaHKALwwlU5out3tVSGdDvSXdEoChGZtyJJn3YzkcVoBksCFRHvLSPivQeFE_47BGNxWUAt3AChT9j9M7dny6l97DgT1RN1XEXcK7Qb_6OoQuOStl5qCPvpEoxzoY8V10-yx0Y-JmStrb8dBjULr2de6XXjvXjEg9sYlQpks-pBPHHxGUB9ZcpNVRzv250DXfEA7Ck0jZi099_KupUL3uvBzx4v-VVB9VdMXjq5vEHJjqL5ppZ-GKAyr63EEu9A7GVMoJofdg-Au4epGNIxZ_zuHHgg5WPMeytLeGUhHoY4u5GE9l5GlwpRsdwpL32eTkHCcbEKHGiL8w&px=1&ap=${AUCTION_PRICE}";
        XCTAssertEqualObjects(impressionURL, expectedImpressionURL);
        
        NSString *fourthImpressionURL = [fourthImpression url];
        NSString *expectedFourthImpressionURL = @"https://backend.europe-west4gcp0.pubnative.net/mockdsp//v1/tracker/iurl?app_id=1039073&beacon=vast2&p=0.131";
        XCTAssertEqualObjects(fourthImpressionURL, expectedFourthImpressionURL);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetCreatives
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        NSArray *creatives = [firstAd creatives];
        XCTAssertNotEqual([creatives count], 0);
        
        HyBidVASTCreative *firstCreative = [creatives firstObject];
        NSString *ID = [firstCreative id];
        NSString *expectedID = @"5481";
        XCTAssertEqualObjects(ID, expectedID);
        
        NSString *adID = [firstCreative adID];
        NSString *expectedAdID = @"2447226";
        XCTAssertEqualObjects(adID, expectedAdID);
        
        NSString *apiFramework = [firstCreative apiFramework];
        NSString *expectedApiFramework = nil;
        XCTAssertEqualObjects(apiFramework, expectedApiFramework);
        
        HyBidVASTCreative *secondCreative = [[firstAd creatives] lastObject];
        NSString *secondApiFramework = [secondCreative apiFramework];
        NSString *expectedSecondApiFramework = @"TEST";
        XCTAssertEqualObjects(secondApiFramework, expectedSecondApiFramework);
        
        NSString *sequence = [firstCreative sequence];
        NSString *expectedSequence = @"1";
        XCTAssertEqualObjects(sequence, expectedSequence);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetCreative_UniversalAdIDs
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];
    
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        NSArray *creatives = [firstAd creatives];
        XCTAssertNotEqual([creatives count], 0);
        
        HyBidVASTCreative *firstCreative = [creatives firstObject];
        
        NSArray<HyBidVASTUniversalAdId *> *universalAdIds = [firstCreative universalAdIds];
        HyBidVASTUniversalAdId *firstAdID = [universalAdIds firstObject];
        HyBidVASTUniversalAdId *secondAdID = [universalAdIds lastObject];
        
        NSString *firstIdRegistry = [firstAdID idRegistry];
        NSString *secondIdRegistry = [secondAdID idRegistry];
        
        NSString *expectedFirstIdRegistry = @"Ad-ID";
        NSString *expectedSecondIdRegistry = @"FOO-ID";
        
        XCTAssertEqualObjects(firstIdRegistry, expectedFirstIdRegistry);
        XCTAssertEqualObjects(secondIdRegistry, expectedSecondIdRegistry);
        
        NSString *firstIdValue = [firstAdID idValue];
        NSString *secondIdValue = [secondAdID idValue];
        
        NSString *expectedFirstIdValue = @"8465";
        NSString *expectedSecondIdValue = @"6666465";
        
        XCTAssertEqualObjects(firstIdValue, expectedFirstIdValue);
        XCTAssertEqualObjects(secondIdValue, expectedSecondIdValue);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetCreative_Linear
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTCreative *firstCreative = [[firstAd creatives] firstObject];
        HyBidVASTLinear *linear = [firstCreative linear];
        
        // Duration
        NSString *duration = [linear duration];
        NSString *expectedDuration = @"00:00:14";
        XCTAssertEqualObjects(duration, expectedDuration);
        
        // Skip Offset
        NSString *skipOffset = [linear skipOffset];
        NSString *expectedSkipOffset = @"00:00:05";
        XCTAssertEqualObjects(skipOffset, expectedSkipOffset);
        
        NSArray* events = [linear trackingEvents];
        NSLog(@"events: %@", events.description);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetCreative_Linear_Icons
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTCreative *firstCreative = [[firstAd creatives] firstObject];
        HyBidVASTLinear *linear = [firstCreative linear];
        
        NSArray<HyBidVASTIcon *> *icons = [[linear icons] icons];
        XCTAssertNotEqual([icons count], 0);
        
        HyBidVASTIcon *firstIcon = [icons firstObject];
        
        XCTAssertEqualObjects([firstIcon apiFramework], @"Test Api Framework");
        XCTAssertEqualObjects([firstIcon duration], @"00:00:16");
        XCTAssertEqualObjects([firstIcon height], @"16");
        XCTAssertEqualObjects([firstIcon width], @"20");
        XCTAssertEqualObjects([firstIcon offset], @"00:00:03");
        XCTAssertEqualObjects([firstIcon xPosition], @"left");
        XCTAssertEqualObjects([firstIcon yPosition], @"top");
        XCTAssertEqualObjects([firstIcon pxRatio], @"1");
        XCTAssertEqualObjects([firstIcon program], @"AdChoices");
        XCTAssertNotEqual([[firstIcon iconViewTracking] count], 0);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetCreative_Linear_AdParameters
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTCreative *firstCreative = [[firstAd creatives] firstObject];
        HyBidVASTLinear *linear = [firstCreative linear];
        
        HyBidVASTAdParameters *adParameters = [linear adParameters];
        
        NSString *xmlEncoded = [adParameters xmlEncoded];
        NSString *expectedXmlEncoded = @"true";
        XCTAssertEqualObjects(xmlEncoded, expectedXmlEncoded);
        
        NSString *content = [adParameters content];
        NSString *expectedContent = @"Test Ad Parameter";
        XCTAssertEqualObjects(content, expectedContent);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetMediaFiles
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTCreative *firstCreative = [[firstAd creatives] firstObject];
        HyBidVASTLinear *linear = [firstCreative linear];
        HyBidVASTMediaFiles *mediaFiles = [linear mediaFiles];

        XCTAssertTrue([[mediaFiles mediaFiles] count] != 0);
        
        HyBidVASTMediaFile *firstMediaFile = [[mediaFiles mediaFiles] firstObject];
        
        NSString *height = [firstMediaFile height];
        NSString *expectedHeight = @"720";
        XCTAssertEqualObjects(height, expectedHeight);
        
        NSString *width = [firstMediaFile width];
        NSString *expectedWidth = @"1280";
        XCTAssertEqualObjects(width, expectedWidth);
        
        NSString *delivery = [firstMediaFile delivery];
        NSString *expectedDelivery = @"progressive";
        XCTAssertEqualObjects(delivery, expectedDelivery);
        
        NSString *type = [firstMediaFile type];
        NSString *expectedType = @"video/mp4";
        XCTAssertEqualObjects(type, expectedType);
        
        NSString *url = [firstMediaFile url];
        NSString *expectedURL = @"https://pubnative-assets.s3.amazonaws.com/static/PNVideoMockup.mp4";
        XCTAssertEqualObjects(url, expectedURL);
        
        HyBidVASTMediaFile *secondMediaFile = [[mediaFiles mediaFiles] lastObject];
        
        NSString *secondHeight = [secondMediaFile height];
        NSString *expectedSecondHeight = @"750";
        XCTAssertEqualObjects(secondHeight, expectedSecondHeight);
        
        NSString *secondUrl = [secondMediaFile url];
        NSString *expectedSecondUrl = @"TEST_URL";
        XCTAssertEqualObjects(secondUrl, expectedSecondUrl);
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetVideoClicks
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTCreative *firstCreative = [[firstAd creatives] firstObject];
        HyBidVASTLinear *linear = [firstCreative linear];
        HyBidVASTVideoClicks *clicks = [linear videoClicks];
        
        XCTAssertTrue([[clicks allClicks] count] == 5);
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_withValidData_shouldGet_Valid_AdVerificationPropertyValues
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        NSArray *adVerifications = [firstAd adVerifications];
        XCTAssertNotEqual([adVerifications count], 0);
        
        HyBidVASTVerification *firstAdVerification = [firstAd adVerifications][0];
        HyBidVASTVerification *secondAdVerification = [firstAd adVerifications][2];
        
        NSString *firstVendor = [firstAdVerification vendor];
        XCTAssertNil(firstVendor);
        
        NSString *secondVendor = [secondAdVerification vendor];
        NSString *expectedSecondVendor = @"company.com-omid";
        XCTAssertEqualObjects(secondVendor, expectedSecondVendor);
        
        NSArray<HyBidVASTJavaScriptResource *> *javaScriptResources = [firstAdVerification javaScriptResource];
        XCTAssertNotEqual([javaScriptResources count], 0);
        
        NSArray<HyBidVASTExecutableResource *> *executableResources = [firstAdVerification executableResource];
        XCTAssertNotEqual([executableResources count], 0);
        
        // First JS Resource
        HyBidVASTJavaScriptResource *firstJavaScriptResource = [javaScriptResources firstObject];
        XCTAssertNotNil(firstJavaScriptResource);
        
        // Second JS Resource
        HyBidVASTJavaScriptResource *secondJavaScriptResource = [javaScriptResources lastObject];
        XCTAssertNotNil(secondJavaScriptResource);
        
        // First Executable Resource
        HyBidVASTExecutableResource *firstExecutableResource = [executableResources firstObject];
        XCTAssertNotNil(firstExecutableResource);
        
        // First JS API Framework
        NSString *apiFramework = [firstJavaScriptResource apiFramework];
        NSString *expectedApiFramework = @"omid";
        XCTAssertEqualObjects(apiFramework, expectedApiFramework);
        
        // Second JS API Framework
        NSString *secondApiFramework = [secondJavaScriptResource apiFramework];
        NSString *expectedSecondApiFramework = nil;
        XCTAssertEqualObjects(secondApiFramework, expectedSecondApiFramework);
        
        // First Executable API Framework
        NSString *firstExecutableApiFramework = [firstExecutableResource apiFramework];
        NSString *expectedFirstExecutableApiFramework = @"omid2";
        XCTAssertEqualObjects(firstExecutableApiFramework, expectedFirstExecutableApiFramework);
        
        // First Executable Language
        NSString *firstExecutableLanguage = [firstExecutableResource language];
        NSString *expectedFirstExecutableLanguage = @"html";
        XCTAssertEqualObjects(firstExecutableLanguage, expectedFirstExecutableLanguage);
        
        // Browser Optional
        NSString *browserOptional = [firstJavaScriptResource browserOptional];
        NSString *expectedBrowserOptional = @"true";
        XCTAssertEqualObjects(browserOptional, expectedBrowserOptional);
        
        // First Content URL
        NSString *firstUrl = [firstJavaScriptResource url];
        NSString *expectedFirstUrl = @"https://verificationcompany1.com/verification_script1.js";
        XCTAssertEqualObjects(firstUrl, expectedFirstUrl);
        
        // Second Content URL
        NSString *secondUrl = [secondJavaScriptResource url];
        NSString *expectedSecondUrl = @"https://verificationcompany.com/untrusted.js";
        XCTAssertEqualObjects(secondUrl, expectedSecondUrl);
        
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetTrackingEventsFromLinear
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
        XCTAssertEqual(vastError, HyBidVASTParserError_None);
        
        HyBidVASTCreative *firstCreative = [[firstAd creatives] firstObject];
        HyBidVASTLinear *linear = [firstCreative linear];
        
        // Skip Offset
        NSString *skipOffset = [linear skipOffset];
        NSString *expectedSkipOffset = @"00:00:05";
        XCTAssertEqualObjects(skipOffset, expectedSkipOffset);
        
        NSArray* events = [linear trackingEvents];
        
        XCTAssertNotNil(events.firstObject);
        XCTAssertEqual(events.count, 29);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}


- (void)tearDown {
//    self.ad = nil;
}

// MARK: - Helper Methods

- (NSString *)readFromTxtFileNamed:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:name ofType:@"txt"];

    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        XCTFail(@"Error reading file: %@", error.localizedDescription);
        return nil;
    }

    return fileContents;
}


@end
