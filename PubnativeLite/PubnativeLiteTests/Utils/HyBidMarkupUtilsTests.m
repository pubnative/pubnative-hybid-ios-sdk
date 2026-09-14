//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidError.h"
#import "HyBidMarkupUtils.h"

// VMI-1706: a JSON ad response carrying literal VAST markup must never be sniffed as plain VAST.
static NSString *const kJSONResponseWithLiteralVASTMarkup =
    @"{\"status\":\"ok\",\"ads\":[{\"assetgroupid\":15,\"assets\":[{\"type\":\"vast2\","
    @"\"data\":{\"vast\":\"<VAST version=\\\"4.1\\\"><Ad id=\\\"1\\\"><InLine></InLine></Ad></VAST>\"}}]}]}";

@interface HyBidMarkupUtilsTests : XCTestCase
@end

@implementation HyBidMarkupUtilsTests

- (void)classifyContent:(NSString *)content
                 isVAST:(BOOL *)isVAST
            parserError:(HyBidVASTParserError **)parserError {
    __block BOOL classified = NO;
    __block HyBidVASTParserError *error = nil;

    [HyBidMarkupUtils isVastXml:content completion:^(BOOL result, HyBidVASTParserError *blockError) {
        classified = result;
        error = blockError;
    }];

    *isVAST = classified;
    *parserError = error;
}

#pragma mark - isVastXml

- (void)test_isVastXml_withJSONResponseCarryingLiteralVASTMarkup_shouldNotClassifyAsVAST {
    NSData *data = [kJSONResponseWithLiteralVASTMarkup dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil([NSJSONSerialization JSONObjectWithData:data options:0 error:nil],
                    @"The fixture must be a valid JSON body for this test to mean anything");
    XCTAssertTrue([kJSONResponseWithLiteralVASTMarkup containsString:@"<VAST"],
                  @"The fixture must carry literal, unescaped VAST markup");

    BOOL isVAST = YES;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:kJSONResponseWithLiteralVASTMarkup isVAST:&isVAST parserError:&parserError];

    XCTAssertFalse(isVAST);
    XCTAssertNil(parserError, @"A body that was never VAST must not produce error tag URLs to beacon");
}

- (void)test_isVastXml_withPlainVASTBeginningWithXMLDeclaration_shouldClassifyAsVAST {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"vast_linear" ofType:@"xml"];
    NSString *vast = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    XCTAssertNotNil(vast);

    BOOL isVAST = NO;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:vast isVAST:&isVAST parserError:&parserError];

    XCTAssertTrue(isVAST);
    XCTAssertNil(parserError);
}

- (void)test_isVastXml_withVASTPrefixedByWhitespace_shouldClassifyAsVAST {
    NSString *vast = @"\r\n\t <VAST version=\"4.1\"><Ad id=\"1\"></Ad></VAST>";

    BOOL isVAST = NO;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:vast isVAST:&isVAST parserError:&parserError];

    XCTAssertTrue(isVAST);
    XCTAssertNil(parserError, @"A VAST document carrying an ad must not report a parser error");
}

- (void)test_isVastXml_withVASTPrefixedByByteOrderMark_shouldClassifyAsVAST {
    NSString *vast = @"\uFEFF<VAST version=\"4.1\"><Ad id=\"1\"></Ad></VAST>";

    BOOL isVAST = NO;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:vast isVAST:&isVAST parserError:&parserError];

    XCTAssertTrue(isVAST);
    XCTAssertNil(parserError, @"A VAST document carrying an ad must not report a parser error");
}

// VMI-1706: leading whitespace before the XML declaration must not push a VAST body onto the JSON path.
- (void)test_isVastXml_withNewlineBeforeXMLDeclaration_shouldClassifyAsVAST {
    NSString *vast = @"\n<?xml version=\"1.0\" encoding=\"UTF-8\"?><VAST version=\"4.1\"><Ad id=\"1\"></Ad></VAST>";

    BOOL isVAST = NO;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:vast isVAST:&isVAST parserError:&parserError];

    XCTAssertTrue(isVAST);
    XCTAssertNil(parserError);
}

// VMI-1706: a self-closing <VAST/> no-ad response is still VAST and must keep the null-ad error path.
- (void)test_isVastXml_withSelfClosingVASTWithoutAds_shouldClassifyAsVASTWithNullAdError {
    BOOL isVAST = NO;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:@"<VAST version=\"4.1\"/>" isVAST:&isVAST parserError:&parserError];

    XCTAssertTrue(isVAST);
    XCTAssertEqual(parserError.code, HyBidErrorCodeNullAd);
}

// VMI-1706: the sniffer must accept what HyBidVASTParser accepts after it normalizes the <VAST> root tag.
- (void)test_isVastXml_withRawAmpersandInRootTagAttribute_shouldClassifyAsVAST {
    NSString *vast = @"<VAST version=\"4.1\" xmlns:xsi=\"http://a&b\"><Ad id=\"1\"></Ad></VAST>";

    BOOL isVAST = NO;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:vast isVAST:&isVAST parserError:&parserError];

    XCTAssertTrue(isVAST);
    XCTAssertNil(parserError);
}

- (void)test_isVastXml_withNonVASTXMLContainingNestedVAST_shouldNotClassifyAsVAST {
    BOOL isVAST = YES;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:@"<html><VAST></VAST></html>" isVAST:&isVAST parserError:&parserError];

    XCTAssertFalse(isVAST);
    XCTAssertNil(parserError, @"Markup that was never VAST must not produce error tag URLs to beacon");
}

// VMI-1706: a body with more than one XML root is not a VAST document, so it must not beacon its Error tag.
- (void)test_isVastXml_withMultipleRootElements_shouldNotClassifyAsVAST {
    NSString *markup = @"<VAST><Ad id=\"1\"></Ad><Error><![CDATA[http://adserver.com/noad.gif]]></Error></VAST><html></html>";

    BOOL isVAST = YES;
    HyBidVASTParserError *parserError = nil;
    [self classifyContent:markup isVAST:&isVAST parserError:&parserError];

    XCTAssertFalse(isVAST);
    XCTAssertNil(parserError);
}

- (void)test_isVastXml_withMalformedComment_shouldNotCrash {
    BOOL isVAST = YES;
    HyBidVASTParserError *parserError = nil;
    XCTAssertNoThrow([self classifyContent:@"<VAST><!--</VAST>" isVAST:&isVAST parserError:&parserError]);

    XCTAssertFalse(isVAST);
    XCTAssertNil(parserError);
}

- (void)test_isVastXml_withUnencodableString_shouldNotClassifyAsVASTWithoutCrashing {
    unichar unpairedSurrogate[] = {'<', 0xD800};
    NSString *unencodable = [NSString stringWithCharacters:unpairedSurrogate length:2];
    XCTAssertNil([unencodable dataUsingEncoding:NSUTF8StringEncoding]);

    BOOL isVAST = YES;
    HyBidVASTParserError *parserError = nil;
    XCTAssertNoThrow([self classifyContent:unencodable isVAST:&isVAST parserError:&parserError]);

    XCTAssertFalse(isVAST);
    XCTAssertNil(parserError);
}

@end
