//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidJSBeaconLoader : NSObject

+ (void)loadBeacon:(NSString *)payload completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
