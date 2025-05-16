// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidNavigatorGeolocation.h"

@interface HyBidNavigatorGeolocation ()   <WKScriptMessageHandler, CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    NSInteger listenerCount;
    WKWebView* webView;
}

@end

@implementation HyBidNavigatorGeolocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        listenerCount = 0;
        webView = nil;
    }
    return self;
}

-(void)assignWebView:(WKWebView*) externalwebView {
    if (webView) {
        [webView.configuration.userContentController addScriptMessageHandler:self name:@"listenerAdded"];
        [webView.configuration.userContentController addScriptMessageHandler:self name:@"listenerRemoved"];
        webView = externalwebView;
    }
}

-(BOOL) locationServicesIsEnabled {
    if (locationManager) {
        return CLLocationManager.locationServicesEnabled;
    } else {
        return NO;
    }
}

-(BOOL)authorizationStatusNeedRequest: (CLAuthorizationStatus) status {
    return status == kCLAuthorizationStatusNotDetermined;
}

-(BOOL)authorizationStatusIsGranted: (CLAuthorizationStatus) status {
    return status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse;
}

-(BOOL)authorizationStatusIsDenied: (CLAuthorizationStatus) status {
    return status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied;
}

-(void)onLocationServicesIsDisabled {
    if (webView) {
        [webView evaluateJavaScript:@"navigator.geolocation.helper.error(2, 'Location services disabled');" completionHandler:^(id result, NSError *error) {}];
    }
}

-(void)onAuthorizationStatusNeedRequest {
    // The HyBid SDK should never prompt for location permission
    //[locationManager requestWhenInUseAuthorization];
}

-(void)onAuthorizationStatusIsGranted {
    // The creative should not trigger location updates
    //[locationManager startUpdatingLocation];
}

-(void)onAuthorizationStatusIsDenied {
    if (webView) {
        [webView evaluateJavaScript:@"navigator.geolocation.helper.error(1, 'App does not have location permission');" completionHandler:^(id result, NSError *error) {}];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"listenerAdded"]) {
        listenerCount += 1;
        
        if (![self locationServicesIsEnabled]) {
            [self onLocationServicesIsDisabled];
        } else if (@available(iOS 14.0, *)) {
            if ([self authorizationStatusIsDenied: locationManager.authorizationStatus]) {
                [self onAuthorizationStatusIsDenied];
            } else if ([self authorizationStatusNeedRequest:locationManager.authorizationStatus]) {
                [self onAuthorizationStatusNeedRequest];
            } else if ([self authorizationStatusIsGranted:locationManager.authorizationStatus]) {
                [self onAuthorizationStatusIsGranted];
            }
        } else {
            //No fallback for earlier versions
        }
    } else if ([message.name isEqualToString:@"listenerRemoved"]) {
        listenerCount -= 1;
        
        if (listenerCount == 0) {
            // Creative should never trigger location updates
            //[locationManager stopUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (listenerCount > 0) {
        if ([self authorizationStatusIsDenied:status]) {
            [self onAuthorizationStatusIsDenied];
        } else if ([self authorizationStatusIsGranted:status]) {
            [self onAuthorizationStatusIsGranted];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (webView && locations && [locations lastObject]) {
        CLLocation* location = [locations lastObject];
        NSString* expression = [NSString stringWithFormat: @"navigator.geolocation.helper.success('%@', %f, %f, %f, %f, %f, %f, %f);", location.timestamp, location.coordinate.latitude, location.coordinate.longitude, location.altitude, location.horizontalAccuracy, location.verticalAccuracy, location.course, location.speed];
        [webView evaluateJavaScript:expression completionHandler:^(id result, NSError *error) {}];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (webView) {
        NSString* expression = [NSString stringWithFormat:@"navigator.geolocation.helper.error(2, 'Failed to get position (%@)');", [error localizedDescription]];
        [webView evaluateJavaScript:expression completionHandler:^(id result, NSError *error) {}];
    }
}

-(NSString*) getJavaScriptToEvaluate {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *geolocationJSPath = [bundle pathForResource:@"navigation_geolocation" ofType:@"js"];
    if (!geolocationJSPath) {
        return @"";
    }
    
    NSData *geolocationJsData = [NSData dataWithContentsOfFile:geolocationJSPath];
    return [[NSString alloc] initWithData:geolocationJsData encoding:NSUTF8StringEncoding];
}

@end
