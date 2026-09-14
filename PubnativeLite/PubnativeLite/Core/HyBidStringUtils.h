//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidStringUtils : NSObject

+ (nullable NSString *)safeReplaceInValue:(id _Nullable)value
                                   target:(id _Nullable)target
                              replacement:(id _Nullable)replacement;
+ (nullable NSString *)safeTrimInValue:(id _Nullable)value
                          characterSet:(NSCharacterSet * _Nullable)characterSet;
+ (nullable NSString *)safeAppendInValue:(id _Nullable)value
                              withString:(id _Nullable)string;
+ (nullable NSString *)safeRegexReplaceInValue:(id _Nullable)value
                                       pattern:(id _Nullable)pattern
                                  withTemplate:(id _Nullable)templateString
                                       options:(NSRegularExpressionOptions)options;
@end

NS_ASSUME_NONNULL_END
