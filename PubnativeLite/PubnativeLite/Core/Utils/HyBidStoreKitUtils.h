// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidStoreKitUtils : NSObject

+ (NSMutableDictionary *)insertFidelitiesIntoDictionaryIfNeeded:(NSMutableDictionary *)dictionary;
+ (NSDictionary *)cleanUpProductParams:(NSDictionary *)productParams;

@end
