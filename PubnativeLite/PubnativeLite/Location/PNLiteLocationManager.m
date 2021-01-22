//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNLiteLocationManager.h"
#import "HyBidLogger.h"

@interface PNLiteLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *lastKnownLocation;
@property (nonatomic, strong) CLLocationManager *manager;

@end

@implementation PNLiteLocationManager

#pragma mark NSObject

+ (void)load {
    [PNLiteLocationManager requestLocation];
}

- (id)init {
    self = [super init];
    if (self) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer;
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

@end
