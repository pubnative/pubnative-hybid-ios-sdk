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
@end

NS_ASSUME_NONNULL_END
