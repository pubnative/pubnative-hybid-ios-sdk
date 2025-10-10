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

@interface ATOMManager : NSObject

+ (void)fireAdSessionEventWithData:(HyBidAdSessionData *)data;
+ (HyBidAdSessionData *)createAdSessionDataFromRequest:(HyBidAdRequest * _Nullable)request
                                                    ad:(HyBidAd *)ad;
+ (void)reportAdSessionDataSharedEventWithAdSessionDict:(NSDictionary<NSString *, id> *)adSessionDict;

@end
