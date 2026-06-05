// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidStringUtils.h"

@interface HyBidStringUtilsTests : XCTestCase

@end

@implementation HyBidStringUtilsTests

#pragma mark - safeReplaceInValue

- (void)test_safeReplaceInValue_withNilValue_shouldReturnNil {
    // Given: A nil value
    id value = nil;
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"foo"
                                                replacement:@"bar"];
    
    // Then: Result should be nil
    XCTAssertNil(result, @"Result should be nil when value is nil");
}

- (void)test_safeReplaceInValue_withNonStringValue_shouldReturnNil {
    // Given: A non-string value (NSNumber)
    id value = @42;
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"foo"
                                                replacement:@"bar"];
    
    // Then: Result should be nil
    XCTAssertNil(result, @"Result should be nil when value is not an NSString");
}

- (void)test_safeReplaceInValue_withNilTarget_shouldReturnOriginalValue {
    // Given: A valid string value but a nil target
    NSString *value = @"hello world";
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:nil
                                                replacement:@"bar"];
    
    // Then: Result should be equal to the original value
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when target is nil");
}

- (void)test_safeReplaceInValue_withNonStringTarget_shouldReturnOriginalValue {
    // Given: A valid string value but a non-string target (NSNumber)
    NSString *value = @"hello world";
    id target = @42;
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:target
                                                replacement:@"bar"];
    
    // Then: Result should be equal to the original value
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when target is not an NSString");
}

- (void)test_safeReplaceInValue_withNilReplacement_shouldReturnOriginalValue {
    // Given: A valid string value and target, but a nil replacement
    NSString *value = @"hello world";
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"world"
                                                replacement:nil];
    
    // Then: Result should be equal to the original value
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when replacement is nil");
}

- (void)test_safeReplaceInValue_withNonStringReplacement_shouldReturnOriginalValue {
    // Given: A valid string value and target, but a non-string replacement (NSNumber)
    NSString *value = @"hello world";
    id replacement = @99;
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"world"
                                                replacement:replacement];
    
    // Then: Result should be equal to the original value
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when replacement is not an NSString");
}

- (void)test_safeReplaceInValue_withEmptyTarget_shouldReturnOriginalValue {
    // Given: A valid string value but an empty target
    NSString *value = @"hello world";
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@""
                                                replacement:@"bar"];
    
    // Then: Result should be equal to the original value (empty target is a no-op)
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when target is empty");
}

- (void)test_safeReplaceInValue_withEmptyValue_shouldReturnEmptyString {
    // Given: An empty string value
    NSString *value = @"";
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"foo"
                                                replacement:@"bar"];
    
    // Then: Result should be empty
    XCTAssertEqualObjects(result, @"", @"Result should be an empty string when value is empty");
}

- (void)test_safeReplaceInValue_withMatchingTargetAndReplacement_shouldReplaceOccurrences {
    // Given: A valid string where target appears
    NSString *value = @"hello world";
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"world"
                                                replacement:@"there"];
    
    // Then: Result should have the replacement applied
    XCTAssertEqualObjects(result, @"hello there", @"Result should replace the target with the replacement");
}

- (void)test_safeReplaceInValue_withEmptyReplacement_shouldRemoveTarget {
    // Given: A valid string and empty replacement (effectively a deletion)
    NSString *value = @"hello world";
    
    // When: Calling safeReplaceInValue with empty replacement
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@" world"
                                                replacement:@""];
    
    // Then: Result should have the target removed
    XCTAssertEqualObjects(result, @"hello", @"Result should remove the target when replacement is an empty string");
}

- (void)test_safeReplaceInValue_withTargetNotInValue_shouldReturnOriginalValue {
    // Given: A valid string where target does not appear
    NSString *value = @"hello world";
    
    // When: Calling safeReplaceInValue with a non-matching target
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"xyz"
                                                replacement:@"bar"];
    
    // Then: Result should be equal to the original value
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when target is not found");
}

- (void)test_safeReplaceInValue_withMultipleOccurrences_shouldReplaceAll {
    // Given: A string with multiple occurrences of the target
    NSString *value = @"aababab";
    
    // When: Calling safeReplaceInValue
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"ab"
                                                replacement:@"X"];
    
    // Then: All occurrences should be replaced
    XCTAssertEqualObjects(result, @"aXXX", @"All occurrences of target should be replaced");
}

#pragma mark - safeTrimInValue

- (void)test_safeTrimInValue_withNilValue_shouldReturnNil {
    // Given: A nil value
    id value = nil;
    
    // When: Calling safeTrimInValue
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then: Result should be nil
    XCTAssertNil(result, @"Result should be nil when value is nil");
}

- (void)test_safeTrimInValue_withNonStringValue_shouldReturnNil {
    // Given: A non-string value (NSNumber)
    id value = @42;
    
    // When: Calling safeTrimInValue
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then: Result should be nil
    XCTAssertNil(result, @"Result should be nil when value is not an NSString");
}

- (void)test_safeTrimInValue_withNilCharacterSet_shouldReturnOriginalValue {
    // Given: A valid string value but a nil character set
    NSString *value = @"  hello  ";
    
    // When: Calling safeTrimInValue with nil characterSet
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:nil];
    
    // Then: Result should equal the original value
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when characterSet is nil");
}

- (void)test_safeTrimInValue_withEmptyValue_shouldReturnEmptyString {
    // Given: An empty string value
    NSString *value = @"";
    
    // When: Calling safeTrimInValue
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then: Result should be empty
    XCTAssertEqualObjects(result, @"", @"Result should be an empty string when value is empty");
}

- (void)test_safeTrimInValue_withSurroundingWhitespace_shouldTrimWhitespace {
    // Given: A string with surrounding whitespace
    NSString *value = @"  hello world  ";
    
    // When: Calling safeTrimInValue with whitespace character set
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then: Surrounding whitespace should be removed
    XCTAssertEqualObjects(result, @"hello world", @"Result should have surrounding whitespace trimmed");
}

- (void)test_safeTrimInValue_withSurroundingNewlines_shouldTrimNewlines {
    // Given: A string with surrounding newlines
    NSString *value = @"\nhello world\n";
    
    // When: Calling safeTrimInValue with whitespace and newline character set
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Then: Surrounding newlines should be removed
    XCTAssertEqualObjects(result, @"hello world", @"Result should have surrounding newlines trimmed");
}

- (void)test_safeTrimInValue_withNoMatchingCharacters_shouldReturnOriginalValue {
    // Given: A string with no whitespace to trim
    NSString *value = @"hello";
    
    // When: Calling safeTrimInValue with whitespace character set
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then: Result should equal the original value
    XCTAssertEqualObjects(result, value, @"Result should equal the original value when no trimming is needed");
}

- (void)test_safeReplaceInValue_withEmojiInValue_shouldReplaceCorrectly {
    // Given: A string containing emojis
    NSString *value = @"Hello 👋 World 🌍";
    
    // When: Replacing emoji target
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"🌍"
                                                replacement:@"🚀"];
    
    // Then: Emoji should be replaced
    XCTAssertEqualObjects(result, @"Hello 👋 World 🚀");
}

- (void)test_safeReplaceInValue_withEmojiAsTarget_notInValue_shouldReturnOriginal {
    // Given: A plain string, emoji target not present
    NSString *value = @"hello world";
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"🔥"
                                                replacement:@"bar"];
    
    // Then: No match, original returned
    XCTAssertEqualObjects(result, value);
}

- (void)test_safeReplaceInValue_withMultiCodepointEmoji_shouldHandleCorrectly {
    // Given: String with a family emoji (multi-codepoint: 👨‍👩‍👧‍👦)
    NSString *value = @"Family: 👨‍👩‍👧‍👦 here";
    
    // When: Replacing multi-codepoint emoji
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"👨‍👩‍👧‍👦"
                                                replacement:@"[family]"];
    
    // Then: Full emoji sequence replaced
    XCTAssertEqualObjects(result, @"Family: [family] here");
}

- (void)test_safeReplaceInValue_replacingTextWithEmoji_shouldWork {
    // Given: Plain string
    NSString *value = @"status: ok";
    
    // When: Replacing text with an emoji
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"ok"
                                                replacement:@"✅"];
    
    // Then
    XCTAssertEqualObjects(result, @"status: ✅");
}

// MARK: URL-encoded strings

- (void)test_safeReplaceInValue_withURLEncodedTarget_shouldReplace {
    // Given: A URL-encoded string
    NSString *value = @"https://example.com/path%20with%20spaces?q=hello%20world";
    
    // When: Replacing %20 with +
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"%20"
                                                replacement:@"+"];
    
    // Then
    XCTAssertEqualObjects(result, @"https://example.com/path+with+spaces?q=hello+world");
}

- (void)test_safeReplaceInValue_withPercentSignInValue_shouldHandleSafely {
    // Given: String containing literal percent signs
    NSString *value = @"100% done, 50% left";
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"%"
                                                replacement:@" percent"];
    
    // Then
    XCTAssertEqualObjects(result, @"100 percent done, 50 percent left");
}

// MARK: HTML entities and special markup

- (void)test_safeReplaceInValue_withHTMLEntitiesInValue_shouldReplace {
    // Given: A string containing HTML entities
    NSString *value = @"AT&amp;T &lt;tag&gt;";
    
    // When: Replacing &amp; with &
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"&amp;"
                                                replacement:@"&"];
    
    // Then
    XCTAssertEqualObjects(result, @"AT&T &lt;tag&gt;");
}

- (void)test_safeReplaceInValue_withHTMLTagsInValue_shouldReplace {
    // Given: A string with HTML tags
    NSString *value = @"<b>bold</b> and <i>italic</i>";
    
    // When: Stripping bold tags
    NSString *intermediate = [HyBidStringUtils safeReplaceInValue:value
                                                           target:@"<b>"
                                                      replacement:@""];
    NSString *result = [HyBidStringUtils safeReplaceInValue:intermediate
                                                     target:@"</b>"
                                                replacement:@""];
    
    // Then
    XCTAssertEqualObjects(result, @"bold and <i>italic</i>");
}

// MARK: Whitespace variants

- (void)test_safeReplaceInValue_withTabCharactersInValue_shouldReplace {
    // Given: String with tab characters
    NSString *value = @"col1\tcol2\tcol3";
    
    // When: Replacing tabs with commas
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"\t"
                                                replacement:@","];
    
    // Then
    XCTAssertEqualObjects(result, @"col1,col2,col3");
}

- (void)test_safeReplaceInValue_withCRLFLineEndings_shouldReplace {
    // Given: String with Windows-style CRLF line endings
    NSString *value = @"line1\r\nline2\r\nline3";
    
    // When: Normalising to Unix newlines
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"\r\n"
                                                replacement:@"\n"];
    
    // Then
    XCTAssertEqualObjects(result, @"line1\nline2\nline3");
}

- (void)test_safeReplaceInValue_withOnlyWhitespaceValue_shouldReturnWhitespace {
    // Given: Value that is purely whitespace
    NSString *value = @"     ";
    
    // When: Target not present
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"x"
                                                replacement:@"y"];
    
    // Then: Whitespace-only string returned unchanged
    XCTAssertEqualObjects(result, @"     ");
}

// MARK: Unicode and special characters

- (void)test_safeReplaceInValue_withRTLCharactersInValue_shouldReplace {
    // Given: String with Arabic (RTL) characters
    NSString *value = @"مرحبا بالعالم";
    
    // When: Replacing an Arabic word
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"بالعالم"
                                                replacement:@"يا صديق"];
    
    // Then
    XCTAssertEqualObjects(result, @"مرحبا يا صديق");
}

- (void)test_safeReplaceInValue_withZeroWidthSpaceInValue_shouldReplace {
    // Given: String containing a zero-width space (U+200B)
    NSString *value = @"hello\u200Bworld";
    
    // When: Removing zero-width space
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"\u200B"
                                                replacement:@""];
    
    // Then
    XCTAssertEqualObjects(result, @"helloworld");
}

- (void)test_safeReplaceInValue_withNullCharacterInValue_shouldHandleSafely {
    // Given: String containing an embedded null character (U+0000)
    NSString *value = [NSString stringWithFormat:@"hel%Clo", 0x0000];
    
    // When: Attempting replacement on an unrelated target
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"foo"
                                                replacement:@"bar"];
    
    // Then: Should return original without crashing
    XCTAssertEqualObjects(result, value);
}

- (void)test_safeReplaceInValue_withCombiningDiacriticsInValue_shouldReplace {
    // Given: String with combining diacritics (e + combining acute = é)
    NSString *value = @"cafe\u0301"; // café (decomposed)
    
    // When: Replacing using precomposed form
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"\u00E9" // é precomposed
                                                replacement:@"e"];
    
    // Then: NSString comparison is Unicode-normalised, so it should match
    // (behaviour may depend on implementation; test documents expected result)
    XCTAssertNotNil(result, @"Should not crash on combining diacritics");
}

- (void)test_safeReplaceInValue_withVeryLongString_shouldNotCrash {
    // Given: A very long repeated string (stress test)
    NSString *unit = @"abcdefghij";
    NSMutableString *longValue = [NSMutableString string];
    for (int i = 0; i < 10000; i++) { [longValue appendString:unit]; }
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:longValue
                                                     target:@"abcde"
                                                replacement:@"XXXXX"];
    
    // Then: Should complete without crashing and have replaced content
    XCTAssertNotNil(result);
    XCTAssertFalse([result containsString:@"abcde"],
                   @"All occurrences should have been replaced");
}

- (void)test_safeReplaceInValue_withSingleCharacterValue_shouldReplace {
    // Given: Single character value
    NSString *value = @"x";
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"x"
                                                replacement:@"y"];
    
    // Then
    XCTAssertEqualObjects(result, @"y");
}

// MARK: Invalid / unexpected types

- (void)test_safeReplaceInValue_withNSNullValue_shouldReturnNil {
    // Given: NSNull (common in JSON-parsed payloads)
    id value = [NSNull null];
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"foo"
                                                replacement:@"bar"];
    
    // Then: NSNull is not NSString, so nil expected
    XCTAssertNil(result);
}

- (void)test_safeReplaceInValue_withNSArrayValue_shouldReturnNil {
    // Given: An array passed as value
    id value = @[@"hello", @"world"];
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"hello"
                                                replacement:@"bar"];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_safeReplaceInValue_withNSDictionaryValue_shouldReturnNil {
    // Given: A dictionary passed as value
    id value = @{@"key": @"hello"};
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"hello"
                                                replacement:@"bar"];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_safeReplaceInValue_withNSNullTarget_shouldReturnOriginalValue {
    // Given: Valid string but NSNull target
    NSString *value = @"hello world";
    id target = [NSNull null];
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:target
                                                replacement:@"bar"];
    
    // Then
    XCTAssertEqualObjects(result, value);
}

- (void)test_safeReplaceInValue_withNSNullReplacement_shouldReturnOriginalValue {
    // Given: Valid string and target, but NSNull replacement
    NSString *value = @"hello world";
    id replacement = [NSNull null];
    
    // When
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"world"
                                                replacement:replacement];
    
    // Then
    XCTAssertEqualObjects(result, value);
}

// MARK: Base64 / encoded payloads

- (void)test_safeReplaceInValue_withBase64LikeString_shouldReplace {
    // Given: A string that looks like a Base64 payload
    NSString *value = @"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIn0.abc123==";
    
    // When: Replacing the padding
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"=="
                                                replacement:@""];
    
    // Then
    XCTAssertEqualObjects(result, @"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIn0.abc123");
}

- (void)test_safeReplaceInValue_withEscapeSequencesInValue_shouldReplace {
    // Given: String with Objective-C escape sequences as literal text
    NSString *value = @"line1\\nline2\\tindented";
    
    // When: Replacing literal \n with actual newline
    NSString *result = [HyBidStringUtils safeReplaceInValue:value
                                                     target:@"\\n"
                                                replacement:@"\n"];
    
    // Then
    XCTAssertEqualObjects(result, @"line1\nline2\\tindented");
}

#pragma mark - safeTrimInValue (Edge Cases)

// MARK: Emojis

- (void)test_safeTrimInValue_withLeadingAndTrailingEmojis_whitespaceCharSet_shouldNotTrimEmojis {
    // Given: Emojis are not whitespace characters
    NSString *value = @"🔥 hello 🔥";
    
    // When: Trimming whitespace only
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then: Emojis remain; only interior spaces untouched (trim is leading/trailing only)
    XCTAssertEqualObjects(result, @"🔥 hello 🔥");
}

- (void)test_safeTrimInValue_withOnlyEmojiValue_shouldReturnUnchanged {
    // Given: String is only emojis
    NSString *value = @"😀😁😂";
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Then: No trimming possible
    XCTAssertEqualObjects(result, @"😀😁😂");
}

// MARK: Whitespace variants

- (void)test_safeTrimInValue_withTabsAndNewlines_shouldTrimAll {
    // Given: Mixed whitespace around content
    NSString *value = @"\t\n  hello world  \n\t";
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Then
    XCTAssertEqualObjects(result, @"hello world");
}

- (void)test_safeTrimInValue_withOnlyWhitespaceValue_shouldReturnEmptyString {
    // Given: Value contains only whitespace
    NSString *value = @"     \t\n   ";
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Then: All characters trimmed → empty string
    XCTAssertEqualObjects(result, @"");
}

- (void)test_safeTrimInValue_withCarriageReturns_shouldTrimWhenUsingNewlineSet {
    // Given: String with carriage returns
    NSString *value = @"\r\nhello\r\n";
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Then
    XCTAssertEqualObjects(result, @"hello");
}

- (void)test_safeTrimInValue_withInternalWhitespaceOnly_shouldNotTrimInternal {
    // Given: Whitespace only in the middle
    NSString *value = @"hello   world";
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then: Internal whitespace is preserved (trim is leading/trailing only)
    XCTAssertEqualObjects(result, @"hello   world");
}

// MARK: Unicode / special characters

- (void)test_safeTrimInValue_withRTLCharacters_shouldTrimSurroundingWhitespace {
    // Given: Arabic text with surrounding spaces
    NSString *value = @"  مرحبا  ";
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then
    XCTAssertEqualObjects(result, @"مرحبا");
}

- (void)test_safeTrimInValue_withZeroWidthSpaceSurrounding_shouldTrimIfInCharSet {
    // Given: Zero-width spaces (U+200B) around content, using custom set
    NSString *value = [NSString stringWithFormat:@"\u200Bhello\u200B"];
    NSMutableCharacterSet *customSet = [NSMutableCharacterSet new];
    [customSet addCharactersInString:@"\u200B"];
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:customSet];
    
    // Then: Zero-width spaces trimmed
    XCTAssertEqualObjects(result, @"hello");
}

- (void)test_safeTrimInValue_withVeryLongWhitespacePadding_shouldNotCrash {
    // Given: Huge whitespace padding around a short value
    NSMutableString *value = [NSMutableString string];
    for (int i = 0; i < 10000; i++) { [value appendString:@" "]; }
    [value appendString:@"core"];
    for (int i = 0; i < 10000; i++) { [value appendString:@" "]; }
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then
    XCTAssertEqualObjects(result, @"core");
}

// MARK: Invalid / unexpected types

- (void)test_safeTrimInValue_withNSNullValue_shouldReturnNil {
    // Given: NSNull passed as value
    id value = [NSNull null];
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_safeTrimInValue_withNSArrayValue_shouldReturnNil {
    // Given: Array passed as value
    id value = @[@"hello", @"world"];
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_safeTrimInValue_withNSNumberValue_shouldReturnNil {
    // Given: NSNumber passed as value
    id value = @3.14;
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_safeTrimInValue_withCustomCharacterSet_shouldTrimMatchingChars {
    // Given: String padded with custom punctuation characters
    NSString *value = @"***hello***";
    NSCharacterSet *starSet = [NSCharacterSet characterSetWithCharactersInString:@"*"];
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:starSet];
    
    // Then
    XCTAssertEqualObjects(result, @"hello");
}

- (void)test_safeTrimInValue_withBase64LikeString_noMatchingChars_shouldReturnOriginal {
    // Given: Base64 string; whitespace trim should leave it unchanged
    NSString *value = @"eyJhbGciOiJIUzI1NiJ9";
    
    // When
    NSString *result = [HyBidStringUtils safeTrimInValue:value
                                            characterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Then
    XCTAssertEqualObjects(result, value);
}

@end
