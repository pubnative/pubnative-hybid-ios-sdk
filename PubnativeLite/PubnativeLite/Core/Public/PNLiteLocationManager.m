// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteLocationManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *lastKnownLocation;
@property (nonatomic, strong) CLLocationManager *manager;

@end

@implementation PNLiteLocationManager

#pragma mark NSObject

- (id)init {
    self = [super init];
    if (self) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        self.manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    }
    return self;
}

static BOOL locationUpdatesEnabled;
+ (BOOL) locationUpdatesEnabled {
    @synchronized(self) { return locationUpdatesEnabled; }
}

+ (void)setLocationUpdatesEnabled:(BOOL)enabled {
    @synchronized(self) { locationUpdatesEnabled = enabled; }
    if (locationTrackingEnabled && locationUpdatesEnabled) {
        [[PNLiteLocationManager sharedInstance].manager startUpdatingLocation];
    }
}

static BOOL locationTrackingEnabled = true;
+ (BOOL) locationTrackingEnabled {
    @synchronized(self) { return locationTrackingEnabled; }
}

+ (void)setLocationTrackingEnabled:(BOOL)enabled {
    @synchronized(self) { locationTrackingEnabled = enabled; }
}

#pragma mark PNLiteLocationManager

+ (instancetype)sharedInstance {
    static PNLiteLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PNLiteLocationManager alloc] init];
    });
    return sharedInstance;
}

+ (void)requestLocation {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if([CLLocationManager locationServicesEnabled]) {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedAlways ||
                status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                if (@available(iOS 9.0, *)) {
                    [[PNLiteLocationManager sharedInstance].manager requestLocation];
                } else {
                    [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Location tracking is not supported in this OS version. Dropping call."];
                }
            }
        }
    });
}

+ (CLLocation *)getLocation {
    [PNLiteLocationManager requestLocation];
    return [PNLiteLocationManager sharedInstance].lastKnownLocation;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Location manager failed with error: %@",error.localizedDescription]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.lastKnownLocation = locations.lastObject;
    [[PNLiteLocationManager sharedInstance].manager stopUpdatingLocation];
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    
}

@end
