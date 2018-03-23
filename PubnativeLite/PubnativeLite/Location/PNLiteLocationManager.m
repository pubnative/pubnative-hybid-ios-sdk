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

@interface PNLiteLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *lastKnownLocation;
@property (nonatomic, strong) CLLocationManager *manager;

@end

@implementation PNLiteLocationManager

#pragma mark NSObject

+ (void)load
{
    [PNLiteLocationManager requestLocation];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
    return self;
}

#pragma mark PNLiteLocationManager

+ (instancetype)sharedInstance
{
    static PNLiteLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PNLiteLocationManager alloc] init];
    });
    return sharedInstance;
}

+ (void)requestLocation
{
    if([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedAlways ||
            status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            if (@available(iOS 9.0, *)) {
                [[PNLiteLocationManager sharedInstance].manager requestLocation];
            } else {
                NSLog(@"PNLiteLocationManager - Location tracking is not supported in this OS version. Dropping call.");
            }
        }
    }
}

+ (CLLocation *)getLocation
{
    [PNLiteLocationManager requestLocation];
    return [PNLiteLocationManager sharedInstance].lastKnownLocation;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"PNLiteLocationManager - Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.lastKnownLocation = locations.lastObject;
}

@end
