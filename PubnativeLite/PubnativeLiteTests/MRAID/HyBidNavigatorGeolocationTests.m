//
//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HyBidNavigatorGeolocation.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface HyBidNavigatorGeolocation (Testing) <CLLocationManagerDelegate>
@end

@interface HyBidNavigatorGeolocationTests : XCTestCase
@end

@implementation HyBidNavigatorGeolocationTests

// VMI-1734: the navigator.geolocation bridge must hand the creative 2-decimal lat/lon.
- (void)test_didUpdateLocations_sendsRoundedCoordinates_notRawCoordinates {
    HyBidNavigatorGeolocation *geolocation = [[HyBidNavigatorGeolocation alloc] init];
    WKWebView *mockWebView = mock([WKWebView class]);
    [geolocation setValue:mockWebView forKey:@"webView"];

    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:1700000000];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(52.345678, -73.935242);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                           altitude:12.3
                                                 horizontalAccuracy:5.0
                                                   verticalAccuracy:3.0
                                                             course:90.0
                                                              speed:1.5
                                                          timestamp:timestamp];

    NSString *expectedExpression = [NSString stringWithFormat:
        @"navigator.geolocation.helper.success('%@', %f, %f, %f, %f, %f, %f, %f);",
        timestamp, 52.35, -73.94, 12.3, 5.0, 3.0, 90.0, 1.5];

    [geolocation locationManager:mock([CLLocationManager class]) didUpdateLocations:@[location]];

    [verify(mockWebView) evaluateJavaScript:expectedExpression completionHandler:anything()];
}

@end
