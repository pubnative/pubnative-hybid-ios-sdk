//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidVASTModel.h"
#import "HyBidVASTParser.h"
#import "HyBidXMLEx.h"
#import "HyBidVASTCompanionAds.h"

@interface HyBidVAST42SupportTests : XCTestCase

@property (nonatomic, strong) HyBidVASTAd *ad;

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVAST42SupportTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)test_withValidData_shouldGet_Valid_ImpressionPropertyValues
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
      //  XCTAssertEqual(vastError, HyBidVASTParserError_None);

        NSArray *impressions = [[firstAd inLine] impressions];
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

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
      //  XCTAssertEqual(vastError, HyBidVASTParserError_None);

        NSArray *creatives = [[firstAd inLine] creatives];
        XCTAssertNotEqual([creatives count], 0);

        HyBidVASTCreative *firstCreative = [creatives firstObject];
        NSString *ID = [firstCreative id];
        NSString *expectedID = @"5481";
        XCTAssertEqualObjects(ID, expectedID);

        NSString *adID = [firstCreative adID];
        NSString *expectedAdID = @"2447226";
        XCTAssertEqualObjects(adID, expectedAdID);

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

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
      //  XCTAssertEqual(vastError, HyBidVASTParserError_None);

        NSArray *creatives = [[firstAd inLine] creatives];
        XCTAssertNotEqual([creatives count], 0);

        HyBidVASTCreative *firstCreative = [creatives firstObject];

        NSArray<HyBidVASTUniversalAdId *> *universalAdIds = [firstCreative universalAdIds];
        HyBidVASTUniversalAdId *firstAdID = [universalAdIds firstObject];
        HyBidVASTUniversalAdId *secondAdID = [universalAdIds lastObject];

        NSString *firstIdRegistry = [firstAdID idRegistry];
        NSString *secondIdRegistry = [secondAdID idRegistry];

        NSString *expectedFirstIdRegistry = @"Ad-ID1";

        XCTAssertEqualObjects(firstIdRegistry, expectedFirstIdRegistry);

        NSString *firstIdValue = [firstAdID universalAdId];

        NSString *expectedFirstIdValue = @"8465";

        XCTAssertEqualObjects(firstIdValue, expectedFirstIdValue);

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

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
       // XCTAssertEqual(vastError, HyBidVASTParserError_None);

        HyBidVASTCreative *firstCreative = [[[firstAd inLine] creatives] lastObject];
        HyBidVASTLinear *linear = [firstCreative linear];

        // Duration
        NSString *duration = [linear duration];
        NSString *expectedDuration = @"00:00:14";
        XCTAssertEqualObjects(duration, expectedDuration);

        // Skip Offset
        NSString *skipOffset = [linear skipOffset];
        NSString *expectedSkipOffset = @"00:00:05";
        XCTAssertEqualObjects(skipOffset, expectedSkipOffset);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)test_init_withValidData_shouldGetCreative_CompanionAds
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
      //  XCTAssertEqual(vastError, HyBidVASTParserError_None);

        HyBidVASTCreative *firstCreative = [[[firstAd inLine] creatives] firstObject];
        HyBidVASTCompanionAds *companionAds = [firstCreative companionAds];

        XCTAssertNotNil(companionAds);

        HyBidVASTCompanion *firstCompanion = [companionAds companions][0];

        NSString *width = [firstCompanion width];
        NSString *expectedWidth = @"100";
        XCTAssertEqualObjects(width, expectedWidth);

        NSString *height = [firstCompanion height];
        NSString *expectedHeight = @"150";
        XCTAssertEqualObjects(height, expectedHeight);

        NSString *assetWidth = [firstCompanion assetWidth];
        NSString *expectedAssetWidth = @"250";
        XCTAssertEqualObjects(assetWidth, expectedAssetWidth);

        NSString *assetHeight = [firstCompanion assetHeight];
        NSString *expectedAssetHeight = @"200";
        XCTAssertEqualObjects(assetHeight, expectedAssetHeight);

        NSString *expandedWidth = [firstCompanion expandedWidth];
        NSString *expectedExpandedWidth = @"350";
        XCTAssertEqualObjects(expandedWidth, expectedExpandedWidth);

        NSString *expandedHeight = [firstCompanion expandedHeight];
        NSString *expectedExpandedHeight = @"250";
        XCTAssertEqualObjects(expandedHeight, expectedExpandedHeight);

        // Second Companion
        HyBidVASTCompanion *secondCompanion = [companionAds companions][1];

        NSString *secondHeight = [secondCompanion height];
        NSString *expectedSecondHeight = @"480";
        XCTAssertEqualObjects(secondHeight, expectedSecondHeight);

        NSString *secondWidth = [secondCompanion width];
        NSString *expectedSecondWidth = @"720";
        XCTAssertEqualObjects(secondWidth, expectedSecondWidth);

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

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
      //  XCTAssertEqual(vastError, HyBidVASTParserError_None);

        HyBidVASTCreative *firstCreative = [[[firstAd inLine] creatives] lastObject];
        HyBidVASTLinear *linear = [firstCreative linear];

        NSArray<HyBidVASTIcon *> *icons = [linear icons];
        XCTAssertNotEqual([icons count], 0);

        HyBidVASTIcon *firstIcon = [icons firstObject];

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

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
      //  XCTAssertEqual(vastError, HyBidVASTParserError_None);

        HyBidVASTCreative *firstCreative = [[[firstAd inLine] creatives] lastObject];
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

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
      //  XCTAssertEqual(vastError, HyBidVASTParserError_None);

        HyBidVASTCreative *firstCreative = [[[firstAd inLine] creatives] lastObject];
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

- (void)test_ClickThroughContentAndId_ParsingWorksAndIsCovered {
    NSString *xml = @"<ClickThrough id=\"blog\">https://iabtechlab.com</ClickThrough>";
    HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
    HyBidXMLElementEx *root = [parser rootElement];
    
    // The root here IS the ClickThrough node
    XCTAssertNotNil(root);
    XCTAssertEqualObjects([root name], @"ClickThrough");
    XCTAssertEqualObjects([root attribute:@"id"], @"blog");
    XCTAssertEqualObjects([root value], @"https://iabtechlab.com");
    
    // Now: test through the model
    HyBidVASTClickThrough *model = [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:root];
    XCTAssertNotNil(model);
    XCTAssertEqualObjects([model id], @"blog");
    XCTAssertEqualObjects([model content], @"https://iabtechlab.com");
}

- (void)test_ClickThroughNoId_ReturnsNilForId {
    NSString *xml = @"<ClickThrough>https://noid.com</ClickThrough>";
    HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
    HyBidXMLElementEx *root = [parser rootElement];
    XCTAssertNotNil(root);
    XCTAssertNil([root attribute:@"id"]);
    HyBidVASTClickThrough *model = [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:root];
    XCTAssertNil([model id]);
    XCTAssertEqualObjects([model content], @"https://noid.com");
}

- (void)test_ClickThroughEmptyContent_ReturnsEmptyString {
    NSString *xml = @"<ClickThrough id=\"empty\"></ClickThrough>";
    HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
    HyBidXMLElementEx *root = [parser rootElement];
    XCTAssertNotNil(root);
    XCTAssertEqualObjects([root attribute:@"id"], @"empty");
    XCTAssertEqualObjects([root value], @"");
    HyBidVASTClickThrough *model = [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:root];
    XCTAssertEqualObjects([model id], @"empty");
    XCTAssertEqualObjects([model content], @"");
}

- (void)test_ClickThroughNilElement_ReturnsNilModel {
    HyBidVASTClickThrough *model = [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:nil];
    XCTAssertNil(model);
}

- (void)test_clickThroughContent_withEncodedUrl_decodesSuccessfully
{
    // Given: an encoded clickthrough value
    NSString *encodedURL = @"https%3A%2F%2Ftest.com%2Ffoo%3Fbar%3Dbaz";
    NSString *xml = [NSString stringWithFormat:@"<ClickThrough>%@</ClickThrough>", encodedURL];
    HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
    HyBidXMLElementEx *element = [parser rootElement];
    HyBidVASTClickThrough *clickThrough = [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:element];
    NSDictionary *attributes = [element attributes];
    XCTAssertNotNil(attributes);
    // When: simulating your app logic
    NSString *rawURL = [clickThrough content];
    NSString *throughClickURL = nil;
    if (rawURL.length > 0) {
        NSString *decoded = [rawURL stringByRemovingPercentEncoding];
        throughClickURL = decoded != nil ? decoded : rawURL;
    }
    
    // Then: it should be decoded
    XCTAssertEqualObjects(throughClickURL, @"https://test.com/foo?bar=baz");
}

- (void)test_clickThroughContent_withPlainUrl_returnsDirectly
{
    // Given: a plain (not encoded) URL
    NSString *plainURL = @"https://plain.com";
    NSString *xml = [NSString stringWithFormat:@"<ClickThrough>%@</ClickThrough>", plainURL];
    HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
    HyBidXMLElementEx *element = [parser rootElement];
    HyBidVASTClickThrough *clickThrough = [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:element];
    
    // When: simulating your app logic
    NSString *rawURL = [clickThrough content];
    NSString *throughClickURL = nil;
    if (rawURL.length > 0) {
        NSString *decoded = [rawURL stringByRemovingPercentEncoding];
        throughClickURL = decoded != nil ? decoded : rawURL;
    }
    
    // Then: it should equal the plain URL
    XCTAssertEqualObjects(throughClickURL, plainURL);
}

- (void)test_clickThroughContent_withEmptyUrl_doesNotSet
{
    // Given: empty clickthrough
    NSString *xml = @"<ClickThrough></ClickThrough>";
    HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
    HyBidXMLElementEx *element = [parser rootElement];
    HyBidVASTClickThrough *clickThrough = [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:element];
    
    // When: simulating your app logic
    NSString *rawURL = [clickThrough content];
    NSString *throughClickURL = @"initial";
    if (rawURL.length > 0) {
        NSString *decoded = [rawURL stringByRemovingPercentEncoding];
        throughClickURL = decoded != nil ? decoded : rawURL;
    }
    
    // Then: throughClickURL should still be initial (untouched)
    XCTAssertEqualObjects(throughClickURL, @"initial");
}


- (void)test_withValidData_shouldGet_Valid_AdVerificationPropertyValues
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];

    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
    //    XCTAssertEqual(vastError, HyBidVASTParserError_None);

        NSArray *adVerifications = [[firstAd inLine] adVerifications];
        XCTAssertNotEqual([adVerifications count], 0);

        HyBidVASTVerification *firstAdVerification = adVerifications[0];
        HyBidVASTVerification *secondAdVerification = adVerifications[1];
        HyBidVASTVerification *thirdAdVerification = adVerifications[2];

        NSString *firstVendor = [firstAdVerification vendor];
        XCTAssertNil(firstVendor);

        NSString *secondVendor = [thirdAdVerification vendor];
        NSString *expectedSecondVendor = @"company.com-omid";
        XCTAssertEqualObjects(secondVendor, expectedSecondVendor);

        NSArray<HyBidVASTJavaScriptResource *> *javaScriptResources = [firstAdVerification javaScriptResource];
        XCTAssertNotEqual([javaScriptResources count], 0);

        NSArray<HyBidVASTExecutableResource *> *executableResources = [secondAdVerification executableResource];
        XCTAssertNotEqual([executableResources count], 0);

        // First JS Resource
        HyBidVASTJavaScriptResource *firstJavaScriptResource = javaScriptResources[0];
        XCTAssertNotNil(firstJavaScriptResource);

        // First Executable Resource
        HyBidVASTExecutableResource *firstExecutableResource = [executableResources firstObject];
        XCTAssertNotNil(firstExecutableResource);

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

    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError* vastError) {
        XCTAssertNotNil(vastModel);

        HyBidVASTAd *firstAd = [[vastModel ads] firstObject];
        XCTAssertNotNil(firstAd);
       // XCTAssertEqual(vastError, HyBidVASTParserError_None);

        HyBidVASTCreative *firstCreative = [[[firstAd inLine] creatives] lastObject];
        HyBidVASTLinear *linear = [firstCreative linear];

        // Skip Offset
        NSString *skipOffset = [linear skipOffset];
        NSString *expectedSkipOffset = @"00:00:05";
        XCTAssertEqualObjects(skipOffset, expectedSkipOffset);

        NSArray* events = [[linear trackingEvents] events];

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
