//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import "HyBidStringUtils.h"

@implementation HyBidStringUtils

+ (nullable NSString *)safeReplaceInValue:(id _Nullable)value
                                   target:(id _Nullable)target
                              replacement:(id _Nullable)replacement
{
    if (![value isKindOfClass:[NSString class]]) { return nil; }
    if (![target isKindOfClass:[NSString class]]) { return [(NSString *)value copy]; }
    if (![replacement isKindOfClass:[NSString class]]) { return [(NSString *)value copy]; }
    
    NSString *sourceString = (NSString *)value;
    NSString *targetString = (NSString *)target;
    NSString *replacementString = (NSString *)replacement;

    if (sourceString.length == 0 || targetString.length == 0) {
        return sourceString;
    }

    return [sourceString stringByReplacingOccurrencesOfString:targetString
                                                   withString:replacementString];
}

+ (nullable NSString *)safeTrimInValue:(id _Nullable)value
                          characterSet:(NSCharacterSet * _Nullable)characterSet
{
    if (![value isKindOfClass:[NSString class]]) { return nil; }
    if (![characterSet isKindOfClass:[NSCharacterSet class]]) { return [(NSString *)value copy]; }
    
    NSString *string = [(NSString *)value copy];
    if (string.length == 0) { return string; }

    return [string stringByTrimmingCharactersInSet:(NSCharacterSet * _Nonnull)characterSet];
}

+ (nullable NSString *)safeAppendInValue:(id _Nullable)value
                              withString:(id _Nullable)string
{
    NSString *base = [value isKindOfClass:[NSString class]] ? (NSString *)value : nil;
    NSString *suffix = [string isKindOfClass:[NSString class]] ? (NSString *)string : nil;

    if (base && suffix) {
        return [base stringByAppendingString:suffix];
    } else if (base) {
        return [base copy];
    } else {
        return [suffix copy];
    }
}

@end
