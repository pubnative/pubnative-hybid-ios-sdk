// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAdRequest.h"
#import "HyBidAd.h"

@interface HyBidAdFeedbackParameters : NSObject

@property (nonatomic, strong) NSString *requestedZoneID;

@property (readonly) NSString *appToken;
@property (readonly) NSString *audioState;
@property (readonly) NSString *appVersion;
@property (readonly) NSString *deviceInfo;
@property (readonly) NSString *sdkVersion;
@property (readonly) NSString *zoneID;
@property (readonly) NSString *creativeID;
@property (readonly) NSString *creative;
@property (readonly) NSString *impressionBeacon;
@property (readonly) NSString *integrationType;
@property (readonly) NSString *adFormat;
@property (readonly) BOOL hasEndCard;

+ (HyBidAdFeedbackParameters *)sharedInstance;
- (void)cacheAd:(HyBidAd *)ad andAdRequest:(HyBidAdRequest *) adRequest withZoneID:(NSString *)zoneID;

@end
