//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <Foundation/Foundation.h>

@class HyBidAdSessionData;
@class HyBidAdRequest;
@class HyBidAd;

@interface HyBidATOMManager : NSObject

+ (void)fireAdSessionEventWithData:(HyBidAdSessionData *)data;
+ (HyBidAdSessionData *)createAdSessionDataFromRequest:(HyBidAdRequest * _Nullable)request
                                                    ad:(HyBidAd *)ad;
+ (void)reportAdSessionDataSharedEventWithAdSessionDict:(NSDictionary<NSString *, id> *)adSessionDict;

#if __has_include(<ATOM/ATOM-Swift.h>)
+ (NSString * _Nullable)getATOMValueForKey:(NSString * _Nonnull)key;

+ (BOOL)setATOMValue:(id _Nonnull)value forKey:(NSString * _Nonnull)key;

+ (void)deleteATOMValueForKey:(NSString * _Nonnull)key;
#endif

@end
