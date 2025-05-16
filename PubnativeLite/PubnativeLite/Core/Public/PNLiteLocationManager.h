// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <CoreLocation/CoreLocation.h>

@interface PNLiteLocationManager : NSObject

+ (BOOL) locationUpdatesEnabled;
+ (BOOL) locationTrackingEnabled;
// setLocationUpdates: Allowing SDK to update location , default is false.
+ (void) setLocationUpdatesEnabled:(BOOL)enabled;
// setLocationTracking: Allowing SDK to track user location , default is true.
+ (void) setLocationTrackingEnabled:(BOOL)enabled;
+ (CLLocation *)getLocation;

@end
