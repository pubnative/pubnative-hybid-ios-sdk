// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidKeychain.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidKeychain

+ (BOOL)checkOSStatus:(OSStatus)status {
    return status == noErr;
}

+ (NSMutableDictionary *)keychainQueryForKey:(NSString *)key
{
    return [
            @{
                (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                (__bridge id)kSecAttrService : key,
                (__bridge id)kSecAttrAccount : key,
                (__bridge id)kSecAttrAccessible : (__bridge id)kSecAttrAccessibleAfterFirstUnlock
            } mutableCopy
            ];
}

+ (BOOL)saveObject:(id)object forKey:(NSString *)key
{
    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key];
    [self deleteObjectForKey:key];
    
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:true error:nil] forKey:(__bridge id)kSecValueData];
    return [self checkOSStatus:SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL)];
}

+ (id)loadObjectForKey:(NSString *)key
{
    id object = nil;
    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key];
    
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    CFDataRef keyData = NULL;
    
    if ([self checkOSStatus:SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData)]) {
        @try {
            object = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:(__bridge NSData *)keyData error:nil];
        } @catch (NSException *exception) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Unarchiving for key %@ failed with exception %@"];
            object = nil;
        } @finally {}
    }
    
    if (keyData) {
        CFRelease(keyData);
    }
    
    return object;
}

+ (BOOL)deleteObjectForKey:(NSString *)key
{
    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key];
    return [self checkOSStatus:SecItemDelete((__bridge CFDictionaryRef)keychainQuery)];
}

@end
