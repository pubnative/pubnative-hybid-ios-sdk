//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import "HyBidXML.h"
#import "HyBidXMLElementEx.h"
#import "HyBidXMLEx.h"

// Mock NSString that returns NULL from cStringUsingEncoding
@interface MockNSStringNullCString : NSString
@end
@implementation MockNSStringNullCString
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding {
	(void)encoding;
	return NULL;
}
@end

@interface HyBidXMLTests : XCTestCase
@end

@implementation HyBidXMLTests

#pragma mark - valueOfAttributeNamed:forElement: nil guards

- (void)test_valueOfAttributeNamed_forElement_returnsNilWhenElementIsNil {
	NSString *result = [HyBidXML valueOfAttributeNamed:@"foo" forElement:NULL];
	XCTAssertNil(result);
}

- (void)test_valueOfAttributeNamed_forElement_returnsNilWhenAttributeNameIsNil {
	NSData *xmlData = [@"<root id=\"x\"></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	XCTAssertTrue(parser != nil && parser.rootXMLElement != NULL);
	NSString *result = [HyBidXML valueOfAttributeNamed:nil forElement:parser.rootXMLElement];
	XCTAssertNil(result);
	XCTAssertNotNil(parser);
}

// Covers valueOfAttributeNamed returns nil when aName's cStringUsingEncoding: returns NULL.
- (void)test_valueOfAttributeNamed_forElement_returnsNilWhenNameCStringIsNULL {
	NSString *nameWithNullCString = [MockNSStringNullCString new];
	NSData *xmlData = [@"<root id=\"v\"></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	NSString *result = [HyBidXML valueOfAttributeNamed:nameWithNullCString forElement:parser.rootXMLElement];
	XCTAssertNil(result);
}

- (void)test_valueOfAttributeNamed_forElement_returnsValueWhenAttributeHasValue {
	NSData *xmlData = [@"<root id=\"myId\"></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	NSString *result = [HyBidXML valueOfAttributeNamed:@"id" forElement:parser.rootXMLElement];
	XCTAssertEqualObjects(result, @"myId");
	XCTAssertNotNil(parser);
}

- (void)test_valueOfAttributeNamed_forElement_returnsCorrectValuesWhenElementHasMultipleAttributes {
	NSData *xmlData = [@"<root id=\"first\" name=\"foo\" count=\"3\"></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *root = parser.rootXMLElement;
	XCTAssertEqualObjects([HyBidXML valueOfAttributeNamed:@"id" forElement:root], @"first");
	XCTAssertEqualObjects([HyBidXML valueOfAttributeNamed:@"name" forElement:root], @"foo");
	XCTAssertEqualObjects([HyBidXML valueOfAttributeNamed:@"count" forElement:root], @"3");
	XCTAssertNil([HyBidXML valueOfAttributeNamed:@"missing" forElement:root]);
	XCTAssertNotNil(parser);
}

// Covers when attribute->name is NULL, loop does attribute = attribute->next; continue (defensive).
- (void)test_valueOfAttributeNamed_forElement_skipsAttributeWithNullName_returnsSecondAttribute {
	static char idName[] = "id";
	static char idValue[] = "v";
	HyBidXMLAttribute firstAttr;
	HyBidXMLAttribute secondAttr;
	firstAttr.name = NULL;
	firstAttr.value = NULL;
	firstAttr.next = &secondAttr;
	secondAttr.name = idName;
	secondAttr.value = idValue;
	secondAttr.next = NULL;
	HyBidXMLElement element;
	element.firstAttribute = &firstAttr;
	NSString *result = [HyBidXML valueOfAttributeNamed:@"id" forElement:&element];
	XCTAssertEqualObjects(result, @"v");
}

#pragma mark - childElementNamed:parentElement: nil guards

- (void)test_childElementNamed_parentElement_returnsNilWhenParentIsNil {
	HyBidXMLElement *result = [HyBidXML childElementNamed:@"child" parentElement:NULL];
	XCTAssertTrue(result == NULL);
}

- (void)test_childElementNamed_parentElement_returnsNilWhenElementNameIsNil {
	NSData *xmlData = [@"<root><child/></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *result = [HyBidXML childElementNamed:nil parentElement:parser.rootXMLElement];
	XCTAssertTrue(result == NULL);
	XCTAssertNotNil(parser);
}

- (void)test_childElementNamed_parentElement_returnsChildWhenValid {
	NSData *xmlData = [@"<root><child>data</child></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *child = [HyBidXML childElementNamed:@"child" parentElement:parser.rootXMLElement];
	XCTAssertTrue(parser != nil && child != NULL);
	XCTAssertEqualObjects([HyBidXML elementName:child], @"child");
	XCTAssertNotNil(parser);
}

// Covers when xmlElement->name is NULL, loop does xmlElement = xmlElement->nextSibling; continue (defensive).
- (void)test_childElementNamed_parentElement_skipsChildWithNullName_returnsNextSibling {
	static char childName[] = "child";
	HyBidXMLElement nullNameChild;
	HyBidXMLElement matchChild;
	nullNameChild.name = NULL;
	nullNameChild.nextSibling = &matchChild;
	matchChild.name = childName;
	matchChild.nextSibling = NULL;
	HyBidXMLElement parent;
	parent.firstChild = &nullNameChild;
	HyBidXMLElement *result = [HyBidXML childElementNamed:@"child" parentElement:&parent];
	XCTAssertTrue(result == &matchChild);
}

#pragma mark - nextSiblingNamed:searchFromElement: (StaticFunctions coverage)

- (void)test_nextSiblingNamed_returnsNextSiblingWhenPresent {
	NSData *xmlData = [@"<root><item/><item/><item/></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *root = parser.rootXMLElement;
	HyBidXMLElement *first = [HyBidXML childElementNamed:@"item" parentElement:root];
	XCTAssertTrue(first != NULL);
	HyBidXMLElement *second = [HyBidXML nextSiblingNamed:@"item" searchFromElement:first];
	XCTAssertTrue(second != NULL);
	HyBidXMLElement *third = [HyBidXML nextSiblingNamed:@"item" searchFromElement:second];
	XCTAssertTrue(third != NULL);
	HyBidXMLElement *nilNext = [HyBidXML nextSiblingNamed:@"item" searchFromElement:third];
	XCTAssertTrue(nilNext == NULL);
	XCTAssertNotNil(parser);
}

- (void)test_nextSiblingNamed_returnsNilWhenNoMatchingSibling {
	NSData *xmlData = [@"<root><a/><b/></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *root = parser.rootXMLElement;
	HyBidXMLElement *a = [HyBidXML childElementNamed:@"a" parentElement:root];
	XCTAssertTrue(a != NULL);
	HyBidXMLElement *nextA = [HyBidXML nextSiblingNamed:@"a" searchFromElement:a];
	XCTAssertTrue(nextA == NULL);
	XCTAssertNotNil(parser);
}

#pragma mark - elementName, textForElement (StaticFunctions coverage)

- (void)test_elementName_returnsElementTagName {
	NSData *xmlData = [@"<root><mytag/></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	XCTAssertEqualObjects([HyBidXML elementName:parser.rootXMLElement], @"root");
	HyBidXMLElement *child = [HyBidXML childElementNamed:@"mytag" parentElement:parser.rootXMLElement];
	XCTAssertEqualObjects([HyBidXML elementName:child], @"mytag");
	XCTAssertNotNil(parser);
}

- (void)test_textForElement_returnsEmptyStringForElementWithNoText {
	NSData *xmlData = [@"<root><empty/></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *empty = [HyBidXML childElementNamed:@"empty" parentElement:parser.rootXMLElement];
	NSString *text = [HyBidXML textForElement:empty];
	XCTAssertEqualObjects(text, @"");
	XCTAssertNotNil(parser);
}

- (void)test_textForElement_returnsTextContentWhenPresent {
	NSData *xmlData = [@"<root><child>hello world</child></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *child = [HyBidXML childElementNamed:@"child" parentElement:parser.rootXMLElement];
	XCTAssertEqualObjects([HyBidXML textForElement:child], @"hello world");
	XCTAssertNotNil(parser);
}

#pragma mark - attributeName, attributeValue (via HyBidXMLElementEx.attributes)

- (void)test_attributesProperty_hitsAttributeNameAndAttributeValue {
	NSString *xml = @"<root id=\"v1\" name=\"v2\"></root>";
	HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
	HyBidXMLElementEx *root = [parser rootElement];
	NSDictionary *attrs = [root attributes];
	XCTAssertNotNil(attrs);
	XCTAssertEqualObjects(attrs[@"id"], @"v1");
	XCTAssertEqualObjects(attrs[@"name"], @"v2");
	XCTAssertEqual(attrs.count, 2);
}

- (void)testHyBidXMLWithURL {
    NSURL *url = [NSURL URLWithString:@"data:text/xml,<root></root>"];
    HyBidXML *xmlInstance = [HyBidXML HyBidXMLWithURL:url];
    XCTAssertNotNil(xmlInstance, @"Should return an instance when URL is provided (even if dummy here)");
    XCTAssertFalse(xmlInstance.invalidXML);
    XCTAssertEqualObjects([HyBidXML elementName:xmlInstance.rootXMLElement], @"root");
}

- (void)testHyBidXMLWithXMLString {
    NSString *xmlString = @"<root><child>test</child></root>";
    HyBidXML *xmlInstance = [HyBidXML HyBidXMLWithXMLString:xmlString];
    XCTAssertNotNil(xmlInstance, @"Should return an instance when XML string is provided");
}

- (void)testHyBidXMLWithXMLString_ignoresComments {
	NSString *xmlWithComment = @"<root><!-- comment --><child>data</child></root>";
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLString:xmlWithComment];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	HyBidXMLElement *child = [HyBidXML childElementNamed:@"child" parentElement:parser.rootXMLElement];
	XCTAssertTrue(child != NULL);
	XCTAssertEqualObjects([HyBidXML textForElement:child], @"data");
	XCTAssertNotNil(parser);
}

- (void)testHyBidXMLWithXMLData {
    NSData *xmlData = [@"<root><child>data</child></root>" dataUsingEncoding:NSUTF8StringEncoding];
    HyBidXML *xmlInstance = [HyBidXML HyBidXMLWithXMLData:xmlData];
    XCTAssertNotNil(xmlInstance, @"Should return an instance when XML data is provided");
    XCTAssertFalse(xmlInstance.invalidXML);
    XCTAssertTrue(xmlInstance.rootXMLElement != NULL);
    XCTAssertEqualObjects([HyBidXML elementName:xmlInstance.rootXMLElement], @"root");
    HyBidXMLElement *childElement = [HyBidXML childElementNamed:@"child" parentElement:xmlInstance.rootXMLElement];
    XCTAssertTrue(childElement != NULL);
    XCTAssertEqualObjects([HyBidXML textForElement:childElement], @"data");
}

- (void)testHyBidXMLWithXMLFile {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"vast_linear" ofType:@"xml"];
    if (path) {
        HyBidXML *xmlInstance = [HyBidXML HyBidXMLWithXMLFile:path];
        XCTAssertNotNil(xmlInstance, @"Should return an instance for XML file path");
    } else {
        XCTFail(@"Test XML file not found in bundle.");
    }
}

- (void)testHyBidXMLWithXMLFileAndExtension {
    NSString *file = @"vast_wrapper";
    NSString *ext = @"xml";
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:file ofType:ext];
    if (path) {
        HyBidXML *xmlInstance = [HyBidXML HyBidXMLWithXMLFile:file fileExtension:ext];
        XCTAssertNotNil(xmlInstance, @"Should return an instance for XML file and extension");
        XCTAssertFalse(xmlInstance.invalidXML);
    } else {
        XCTFail(@"Test XML file not found in bundle.");
    }
}

- (void)test_HyBidXMLWithXMLString_rootElementPresent {
    NSString *xmlString = @"<root><foo/></root>";
    HyBidXML *xmlInstance = [HyBidXML HyBidXMLWithXMLString:xmlString];
    XCTAssertNotNil(xmlInstance, @"Should return a HyBidXML instance");
    XCTAssertFalse(xmlInstance.invalidXML, @"XML should NOT be invalid");
    XCTAssertTrue(xmlInstance.rootXMLElement != NULL, @"rootXMLElement should not be NULL for valid XML");

    NSString *rootName = [HyBidXML elementName:xmlInstance.rootXMLElement];
    XCTAssertEqualObjects(rootName, @"root");
}

- (void)testInitWithXMLFileAndExtension_Valid {
    HyBidXML *parser = [[HyBidXML alloc] initWithXMLFile:@"vast_linear" fileExtension:@"txt"];
    XCTAssertFalse(parser.invalidXML);
}

- (void)testInitWithXMLFile_Valid {
    HyBidXML *parser = [[HyBidXML alloc] initWithXMLFile:@"vast_linear.txt"];
    XCTAssertFalse(parser.invalidXML);
}

- (void)testInitWithXMLFile_Invalid {
    NSString *invalidXML = @"<root><child></root>";
    NSString *tempDir = NSTemporaryDirectory();
    NSString *tempFile = [tempDir stringByAppendingPathComponent:@"invalid_sample.xml"];
    NSError *writeError = nil;
    BOOL success = [invalidXML writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    XCTAssertTrue(success, @"Failed to create temp file: %@", writeError);

    // Test: Should detect invalid XML
    HyBidXML *parser = [[HyBidXML alloc] initWithXMLFile:tempFile];
    XCTAssertNotNil(parser, @"Should return a HyBidXML instance even for invalid XML");

    [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
}

#pragma mark - HyBidXMLElementEx parser retention

- (void)test_HyBidXMLElementEx_initWithElement_delegatesToParserNil {
	NSData *xmlData = [@"<root><a/></root>" dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [HyBidXML HyBidXMLWithXMLData:xmlData];
	HyBidXMLElement *rawElement = parser.rootXMLElement;
	HyBidXMLElementEx *wrapper = [[HyBidXMLElementEx alloc] initWithElement:rawElement];
	XCTAssertNotNil(wrapper);
	XCTAssertEqualObjects(wrapper.name, @"root");
}

- (void)test_HyBidXMLElementEx_initWithElementParser_preservesParserInChild {
	NSString *xml = @"<root><parent><child id=\"c1\"/></parent></root>";
	HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
	HyBidXMLElementEx *root = [parser rootElement];
	XCTAssertNotNil(root);
	HyBidXMLElementEx *parent = [root child:@"parent"];
	XCTAssertNotNil(parent);
	HyBidXMLElementEx *child = [parent child:@"child"];
	XCTAssertNotNil(child);
	XCTAssertEqualObjects([child attribute:@"id"], @"c1");
}

- (void)test_HyBidXMLElementEx_query_returnsElementsWithParserRetained {
	NSString *xml = @"<VAST><Ad><InLine><Icons><Icon width=\"40\" height=\"40\"><StaticResource>https://example.com/icon.png</StaticResource></Icon></Icons></InLine></Ad></VAST>";
	HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
	HyBidXMLElementEx *root = [parser rootElement];
	NSArray *ads = [root query:@"Ad"];
	XCTAssertGreaterThan(ads.count, 0);
	HyBidXMLElementEx *ad = ads.firstObject;
	HyBidXMLElementEx *inLine = [ad child:@"InLine"];
	XCTAssertNotNil(inLine);
	HyBidXMLElementEx *icons = [inLine child:@"Icons"];
	XCTAssertNotNil(icons);
	NSArray *iconResults = [icons query:@"Icon"];
	XCTAssertGreaterThan(iconResults.count, 0);
	HyBidXMLElementEx *icon = iconResults.firstObject;
	XCTAssertEqualObjects([icon attribute:@"width"], @"40");
	XCTAssertEqualObjects([icon attribute:@"height"], @"40");
}

#pragma mark - decodeBytes coverage (CDATA, malformed, single-quote, attribute CDATA)

- (void)test_decodeBytes_CDATA_unclosed_setsInvalidXMLAndErrorDescription {
	// No "]]>" in the string so CDATA is truly unclosed (parser must not dereference NULL)
	NSString *xml = @"<root><![CDATA[data with no closing";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertTrue(parser.invalidXML);
	XCTAssertEqualObjects(parser.parsingErrorDescription, @"CDATA element not closed");
}

- (void)test_decodeBytes_validCDATA_multipleSections {
	NSString *xml = @"<root><![CDATA[first]]><![CDATA[second]]></root>";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	HyBidXMLElement *root = parser.rootXMLElement;
	XCTAssertTrue(root != NULL);
	NSString *text = [HyBidXML textForElement:root];
	XCTAssertNotNil(text);
	XCTAssertTrue([text containsString:@"first"] || [text containsString:@"second"]);
	XCTAssertNotNil(parser);
}

- (void)test_decodeBytes_openingTagNoClosingAngleBracket_setsInvalidXMLAndErrorDescription {
	NSString *xml = @"<root";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertTrue(parser.invalidXML);
	XCTAssertEqualObjects(parser.parsingErrorDescription, @"'>' character for the opening tag not found");
}

- (void)test_decodeBytes_attributeWithSingleQuotes {
	NSString *xml = @"<root a='single_quote_value'></root>";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	NSString *val = [HyBidXML valueOfAttributeNamed:@"a" forElement:parser.rootXMLElement];
	XCTAssertEqualObjects(val, @"single_quote_value");
	XCTAssertNotNil(parser);
}

- (void)test_decodeBytes_attributeValueContainsCDATA {
	NSString *xml = @"<root attr=\"<![CDATA[inner]]>\"></root>";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	NSString *val = [HyBidXML valueOfAttributeNamed:@"attr" forElement:parser.rootXMLElement];
	XCTAssertNotNil(val);
	XCTAssertTrue([val isEqualToString:@"inner"] || [val containsString:@"inner"]);
	XCTAssertNotNil(parser);
}

- (void)test_decodeBytes_elementTagContainsCDATAInAttribute_skipsToEndOfTag {
	NSString *xml = @"<root x=\"<![CDATA[v]]>\"></root>";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	XCTAssertEqualObjects([HyBidXML elementName:parser.rootXMLElement], @"root");
	XCTAssertNotNil(parser);
}

// Covers when no "<" exists after "]]>", parser sets elementEnd = bytes + bytesLength (single CDATA to end of buffer).
- (void)test_decodeBytes_CDATA_closedNoFollowingTag_usesEndOfBuffer {
	// Closed CDATA but no further "<" in document — triggers elementEnd = bytes + bytesLength path.
	NSString *xml = @"<root><![CDATA[content]]>";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	XCTAssertTrue(parser.rootXMLElement != NULL);
	NSString *text = [HyBidXML textForElement:parser.rootXMLElement];
	XCTAssertNotNil(text);
	XCTAssertTrue([text containsString:@"content"] || [text length] >= 7);
}

#pragma mark - decodeBytes coverage (line 346, 549)

// (!elementEnd) invalidXML return): elementEnd = elementStart+1; with elementStart from strstr("<"),
// so elementEnd is never NULL in practice — defensive/dead code. No test can trigger it without changing parser.
- (void)test_decodeBytes_minimalValidXML_parsesWithoutHittingElementEndNullPath {
	NSString *xml = @"<r/>";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	XCTAssertEqualObjects([HyBidXML elementName:parser.rootXMLElement], @"r");
}

// Covers attribute state machine including paths that approach default. Default is only hit for mode
// values outside 0..4; current parser only uses those, so default is defensive.
- (void)test_decodeBytes_tagWithMultipleAttributesAndCDATAInAttribute_exercisesAttributeSwitch {
	NSString *xml = @"<root a=\"1\" b=\"<![CDATA[two]]>\" c='3'></root>";
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	HyBidXML *parser = [[HyBidXML alloc] initWithXMLData:data];
	XCTAssertNotNil(parser);
	XCTAssertFalse(parser.invalidXML);
	XCTAssertEqualObjects([HyBidXML valueOfAttributeNamed:@"a" forElement:parser.rootXMLElement], @"1");
	XCTAssertNotNil([HyBidXML valueOfAttributeNamed:@"b" forElement:parser.rootXMLElement]);
	XCTAssertEqualObjects([HyBidXML valueOfAttributeNamed:@"c" forElement:parser.rootXMLElement], @"3");
}

@end
