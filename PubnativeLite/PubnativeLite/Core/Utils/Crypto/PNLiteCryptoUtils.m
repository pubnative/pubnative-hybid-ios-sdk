// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteCryptoUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PNLiteCryptoUtils

+ (NSString *)md5WithString:(NSString *)text {
    if (text.length <= 0) { return nil; }
    
    const char *cStringToHash = text.UTF8String;
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStringToHash, (CC_LONG)(strlen(cStringToHash)), hash);
    NSMutableString *hashString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [hashString appendFormat:@"%02X", hash[i]];
    }
    NSString *result = [NSString stringWithString:hashString];
    return result;
}

+ (NSString *)sha1WithString:(NSString *)text {
    const char *cstr = [text cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:text.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
