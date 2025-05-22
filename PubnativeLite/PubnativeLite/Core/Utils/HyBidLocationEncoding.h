// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidLocationEncoding : NSObject

+ (CLLocation *)decodeLocation:(NSString *)enc;
+ (NSString *)encodeLocation:(CLLocation *)loc;

@end

NS_ASSUME_NONNULL_END
