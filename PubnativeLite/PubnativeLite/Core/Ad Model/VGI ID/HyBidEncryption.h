// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidEncryption: NSObject

+(NSString *)encrypt:(NSString *)string withKey: (NSString *)key andWithIV: (NSString *)iv;
+(NSString *)decrypt:(NSString *)string withKey: (NSString *)key andWithIV: (NSString *)iv;

@end
