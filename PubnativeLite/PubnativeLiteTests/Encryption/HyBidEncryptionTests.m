//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidEncryption.h"

@interface HyBidEncryptionTests : XCTestCase
@end

@implementation HyBidEncryptionTests

#pragma mark - Encrypt tests

- (void)test_encrypt_withValidInputs_shouldReturnNonNilResult {
    NSString *plainText = @"test string";
    NSString *key = @"1234567890abcdef";
    NSString *iv = @"1234567890abcdef";

    NSString *encrypted = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];

    XCTAssertNotNil(encrypted);
    XCTAssertGreaterThan(encrypted.length, 0);
}

- (void)test_encrypt_withSameInput_shouldProduceSameResult {
    NSString *plainText = @"Hello World";
    NSString *key = @"1234567890abcdef";
    NSString *iv = @"1234567890abcdef";

    NSString *first = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];
    NSString *second = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];

    XCTAssertEqualObjects(first, second);
}

- (void)test_encrypt_withDifferentKeys_shouldProduceDifferentResults {
    NSString *plainText = @"same text";
    NSString *key1 = @"key1key1key1key1";
    NSString *key2 = @"key2key2key2key2";
    NSString *iv = @"iviviviviviviviv";

    NSString *encrypted1 = [HyBidEncryption encrypt:plainText withKey:key1 andWithIV:iv];
    NSString *encrypted2 = [HyBidEncryption encrypt:plainText withKey:key2 andWithIV:iv];

    XCTAssertNotEqualObjects(encrypted1, encrypted2);
}

#pragma mark - Decrypt tests

- (void)test_decrypt_withEncryptedString_shouldReturnOriginalString {
    NSString *plainText = @"Hello, World!";
    NSString *key = @"1234567890abcdef1234567890abcdef";
    NSString *iv = @"1234567890abcdef";

    NSString *encrypted = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];
    XCTAssertNotNil(encrypted);

    NSString *decrypted = [HyBidEncryption decrypt:encrypted withKey:key andWithIV:iv];
    XCTAssertEqualObjects(decrypted, plainText);
}

- (void)test_decrypt_withNewlineInEncryptedString_shouldStripAndDecrypt {
    NSString *plainText = @"test";
    NSString *key = @"1234567890abcdef1234567890abcdef";
    NSString *iv = @"1234567890abcdef";

    NSString *encrypted = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];
    NSString *encryptedWithNewline = [NSString stringWithFormat:@"%@\n", encrypted];

    NSString *decrypted = [HyBidEncryption decrypt:encryptedWithNewline withKey:key andWithIV:iv];
    XCTAssertEqualObjects(decrypted, plainText);
}

- (void)test_decrypt_withTabInEncryptedString_shouldStripAndDecrypt {
    NSString *plainText = @"data";
    NSString *key = @"1234567890abcdef1234567890abcdef";
    NSString *iv = @"1234567890abcdef";

    NSString *encrypted = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];
    NSString *encryptedWithTab = [NSString stringWithFormat:@"%@\t", encrypted];

    NSString *decrypted = [HyBidEncryption decrypt:encryptedWithTab withKey:key andWithIV:iv];
    XCTAssertEqualObjects(decrypted, plainText);
}

#pragma mark - Round-trip tests

- (void)test_encryptDecrypt_roundTrip_withShortString {
    NSString *plainText = @"Hi";
    NSString *key = @"mySecretKey12345";
    NSString *iv = @"myInitVector1234";

    NSString *encrypted = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];
    NSString *decrypted = [HyBidEncryption decrypt:encrypted withKey:key andWithIV:iv];

    XCTAssertEqualObjects(decrypted, plainText);
}

- (void)test_encryptDecrypt_roundTrip_withLongString {
    NSString *plainText = @"This is a longer test string with special chars: !@#$%^&*() 1234567890";
    NSString *key = @"MySecretKey12345";
    NSString *iv = @"InitVector12345!";

    NSString *encrypted = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];
    NSString *decrypted = [HyBidEncryption decrypt:encrypted withKey:key andWithIV:iv];

    XCTAssertEqualObjects(decrypted, plainText);
}

- (void)test_encryptDecrypt_roundTrip_withNumericString {
    NSString *plainText = @"1234567890";
    NSString *key = @"key1234567890key";
    NSString *iv = @"iv12345678901234";

    NSString *encrypted = [HyBidEncryption encrypt:plainText withKey:key andWithIV:iv];
    NSString *decrypted = [HyBidEncryption decrypt:encrypted withKey:key andWithIV:iv];

    XCTAssertEqualObjects(decrypted, plainText);
}

@end
