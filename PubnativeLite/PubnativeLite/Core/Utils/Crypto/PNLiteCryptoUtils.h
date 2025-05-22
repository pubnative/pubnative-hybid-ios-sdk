// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface PNLiteCryptoUtils : NSObject

+ (NSString *)md5WithString:(NSString *)text;
+ (NSString *)sha1WithString:(NSString *)text;

@end
