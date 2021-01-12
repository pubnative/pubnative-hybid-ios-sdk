//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidEncryption.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation HyBidEncryption

+(NSData *)cryptOperation:(CCOperation)operation forData: (NSData *)data withKey: (NSString *)key andWithIV: (NSString *)iv
{
    char keys[kCCKeySizeAES256 + 1];
    [key getCString:keys maxLength:sizeof(keys) encoding:NSUTF8StringEncoding];

    unsigned long bytes_to_pad = sizeof(keys) - [key length];
    if (bytes_to_pad > 0) {
        char byte = bytes_to_pad;
        for (unsigned long i = sizeof(keys) - bytes_to_pad; i < sizeof(keys); i++)
        keys[i] = byte;
    }
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus status = CCCrypt(operation, kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     keys, kCCKeySizeAES256,
                                     [iv UTF8String],
                                     [data bytes], dataLength,
                                     buffer, bufferSize,
                                     &numBytesDecrypted);
    if (status == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

+(NSData *)AES256EncryptForData: (NSData *)data withKey: (NSString *)key andWithIV: (NSString *)iv
{
    return [self cryptOperation:kCCEncrypt forData:data withKey:key andWithIV:iv];
}

+(NSData *)AES256DecryptForData: (NSData *)data withKey: (NSString *)key andWithIV: (NSString *)iv
{
    return [self cryptOperation:kCCDecrypt forData:data withKey:key andWithIV:iv];
}

+(NSString *)encrypt:(NSString *)string withKey: (NSString *)key andWithIV: (NSString *)iv
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataEncrypted = [self AES256EncryptForData:data withKey:key andWithIV:iv];
    NSString *strRecordEncrypted = [dataEncrypted base64EncodedStringWithOptions:0];
    
    return strRecordEncrypted;
}

+(NSString *)decrypt:(NSString *)string withKey: (NSString *)key andWithIV: (NSString *)iv
{
    if([string containsString:@"\n"] || [string containsString:@"\t"]) {
        string = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSData *dataDecrypted = [self AES256DecryptForData:keyData withKey:key andWithIV:iv];
    NSString *receivedDataDecryptString = [[NSString alloc]initWithData:dataDecrypted encoding:NSUTF8StringEncoding];
    
    return receivedDataDecryptString;
}

@end
