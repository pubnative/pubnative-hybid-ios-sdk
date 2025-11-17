// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidDeeplinkHandler.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidDeeplinkHandlerTests : XCTestCase

@end

@implementation HyBidDeeplinkHandlerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Test initialization with valid deeplink and fallback

- (void)test_initWithLink_withValidDeeplinkAndFallback_shouldBeCapable {
    // Given: A valid link with both deeplinkUrl and fallbackUrl
    NSString *link = @"vrvdl://?deeplinkUrl=myapp://product/123&fallbackUrl=https://example.com/product/123";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should be capable
    XCTAssertTrue(handler.isCapable, @"Handler should be capable with valid deeplink and fallback");
    XCTAssertNotNil(handler.deeplinkURL, @"Deeplink URL should not be nil");
    XCTAssertNotNil(handler.fallbackURL, @"Fallback URL should not be nil");
    XCTAssertEqualObjects(handler.deeplinkURL.absoluteString, @"myapp://product/123");
    XCTAssertEqualObjects(handler.fallbackURL.absoluteString, @"https://example.com/product/123");
}

#pragma mark - Test initialization with only deeplink (no fallback) - Priority 1

- (void)test_initWithLink_withOnlyValidDeeplink_shouldBeCapable {
    // Given: A valid link with only deeplinkUrl (no fallbackUrl)
    NSString *link = @"vrvdl://?deeplinkUrl=myapp://product/456";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should still be capable (this is the bug fix)
    XCTAssertTrue(handler.isCapable, @"Handler should be capable with only valid deeplink URL");
    XCTAssertNotNil(handler.deeplinkURL, @"Deeplink URL should not be nil");
    XCTAssertNil(handler.fallbackURL, @"Fallback URL should be nil when not provided");
    XCTAssertEqualObjects(handler.deeplinkURL.absoluteString, @"myapp://product/456");
}

#pragma mark - Test initialization with empty fallback

- (void)test_initWithLink_withValidDeeplinkAndEmptyFallback_shouldBeCapable {
    // Given: A valid link with deeplinkUrl and empty fallbackUrl
    NSString *link = @"vrvdl://?deeplinkUrl=myapp://product/789&fallbackUrl=";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should be capable with nil fallback
    XCTAssertTrue(handler.isCapable, @"Handler should be capable with valid deeplink and empty fallback");
    XCTAssertNotNil(handler.deeplinkURL, @"Deeplink URL should not be nil");
    XCTAssertNil(handler.fallbackURL, @"Fallback URL should be nil when empty");
    XCTAssertEqualObjects(handler.deeplinkURL.absoluteString, @"myapp://product/789");
}

#pragma mark - Test initialization with invalid deeplink

- (void)test_initWithLink_withNoDeeplink_shouldNotBeCapable {
    // Given: A link with only fallbackUrl (no deeplinkUrl)
    NSString *link = @"vrvdl://?fallbackUrl=https://example.com/product";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should not be capable
    XCTAssertFalse(handler.isCapable, @"Handler should not be capable without deeplink URL");
    XCTAssertNil(handler.deeplinkURL, @"Deeplink URL should be nil");
}

- (void)test_initWithLink_withInvalidDeeplinkScheme_shouldNotBeCapable {
    // Given: A link with deeplinkUrl missing scheme
    NSString *link = @"vrvdl://?deeplinkUrl=product/123&fallbackUrl=https://example.com/product";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should not be capable
    XCTAssertFalse(handler.isCapable, @"Handler should not be capable with invalid deeplink scheme");
}

- (void)test_initWithLink_withEmptyDeeplink_shouldNotBeCapable {
    // Given: A link with empty deeplinkUrl
    NSString *link = @"vrvdl://?deeplinkUrl=&fallbackUrl=https://example.com/product";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should not be capable
    XCTAssertFalse(handler.isCapable, @"Handler should not be capable with empty deeplink URL");
}

#pragma mark - Test initialization with invalid fallback (when present)

- (void)test_initWithLink_withValidDeeplinkAndInvalidFallback_shouldNotBeCapable {
    // Given: A link with valid deeplinkUrl but invalid fallbackUrl (no scheme)
    NSString *link = @"vrvdl://?deeplinkUrl=myapp://product/123&fallbackUrl=example.com/product";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should not be capable (fallback must be valid if present)
    XCTAssertFalse(handler.isCapable, @"Handler should not be capable with invalid fallback URL");
}

#pragma mark - Test initialization with wrong wrapper scheme

- (void)test_initWithLink_withWrongScheme_shouldNotBeCapable {
    // Given: A link with wrong scheme (not vrvdl)
    NSString *link = @"http://?deeplinkUrl=myapp://product/123&fallbackUrl=https://example.com/product";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should not be capable
    XCTAssertFalse(handler.isCapable, @"Handler should not be capable with wrong wrapper scheme");
}

#pragma mark - Test initialization with nil or empty link

- (void)test_initWithLink_withNilLink_shouldNotBeCapable {
    // Given: A nil link
    NSString *link = nil;
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should not be capable
    XCTAssertFalse(handler.isCapable, @"Handler should not be capable with nil link");
}

- (void)test_initWithLink_withEmptyLink_shouldNotBeCapable {
    // Given: An empty link
    NSString *link = @"";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should not be capable
    XCTAssertFalse(handler.isCapable, @"Handler should not be capable with empty link");
}

#pragma mark - Test URL encoding

- (void)test_initWithLink_withEncodedURLs_shouldDecodeCorrectly {
    // Given: A link with URL-encoded parameters
    NSString *link = @"vrvdl://?deeplinkUrl=myapp%3A%2F%2Fproduct%2F123&fallbackUrl=https%3A%2F%2Fexample.com%2Fproduct%2F123";
    
    // When: Initializing the handler
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:link];
    
    // Then: Handler should decode URLs correctly
    XCTAssertTrue(handler.isCapable, @"Handler should handle URL-encoded parameters");
    XCTAssertEqualObjects(handler.deeplinkURL.absoluteString, @"myapp://product/123");
    XCTAssertEqualObjects(handler.fallbackURL.absoluteString, @"https://example.com/product/123");
}

@end
