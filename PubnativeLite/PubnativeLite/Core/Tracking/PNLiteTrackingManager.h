// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

@interface PNLiteTrackingManager : NSObject

+ (void)trackWithURL:(NSURL *)url withType:(NSString *)type forAd:(HyBidAd *)ad;

@end
