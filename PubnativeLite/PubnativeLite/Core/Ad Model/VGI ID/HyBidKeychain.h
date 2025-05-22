// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidKeychain : NSObject

+ (BOOL)saveObject:(id)object forKey:(NSString *)key;
+ (id)loadObjectForKey:(NSString *)key;
+ (BOOL)deleteObjectForKey:(NSString *)key;

@end
