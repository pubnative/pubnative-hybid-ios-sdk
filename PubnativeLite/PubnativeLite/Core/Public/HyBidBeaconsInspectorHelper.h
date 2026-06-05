//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidBeaconsInspectorHelper : NSObject

+ (void)adBeaconDictionariesFromLastResponseWithCompletion:(void (^_Nullable)(NSArray<NSDictionary<NSString *, id> *> * _Nullable))completion;

+ (void)adBeaconDictionariesFromResponse:(nullable NSString *)response completion:(void (^_Nullable)(NSArray<NSDictionary<NSString *, id> *> *_Nullable))completion;

@end
