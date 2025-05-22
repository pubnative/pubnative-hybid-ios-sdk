// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import "HyBidAdRequest.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidAdRequest ()

- (void)invokeDidStart;
- (void)invokeDidLoad:(HyBidAd *)ad;
- (void)invokeDidFail:(NSError *)error;
@end

@interface PNLiteAdRequestTest : XCTestCase

@end

@implementation PNLiteAdRequestTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_requestAdWithDelegate_withNilDelegateAndValidZoneID_shouldPass
{
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    [request requestAdWithDelegate:nil withZoneID:@"validZoneID"];
}

//This test is closed for IQV SDK
/*
- (void)test_requestAdWithDelegate_withValidDelegateAndNilZoneID_shouldPass
{
    NSObject <HyBidAdRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdRequestDelegate));
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    [request requestAdWithDelegate:delegate withZoneID:nil];
}
*/

//This test is closed for IQV SDK
/*
- (void)test_requestAdWithDelegate_withValidDelegateAndEmptyZoneID_shouldPass
{
    NSObject <HyBidAdRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdRequestDelegate));
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    [request requestAdWithDelegate:delegate withZoneID:@""];
}
*/
- (void)test_requestAdWithDelegate_withValidDelegateAndValidZoneID_shouldPass
{
    [HyBidSDKConfig sharedConfig].apiURL = @"validAPIURL";
    NSObject <HyBidAdRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdRequestDelegate));
    HyBidAdSize *adSize = HyBidAdSize.SIZE_300x250;
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    request.adSize = adSize;
    [request requestAdWithDelegate:delegate withZoneID:@"validZoneID"];
}

- (void)test_invokeDidStart_withNilListener_shouldPass
{
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    request.delegate = nil;
    [request invokeDidStart];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidStart_withValidListener_shouldCallback
{
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    NSObject <HyBidAdRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdRequestDelegate));
    request.delegate = delegate;
    [request invokeDidStart];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) requestDidStart:request];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidLoad_withNilListener_shouldPass
{
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    request.delegate = nil;
    [request invokeDidStart];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidLoad_withValidListener_shouldCallback
{
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    HyBidAd *ad = mock([HyBidAd class]);
    NSObject <HyBidAdRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdRequestDelegate));
    request.delegate = delegate;
    [request invokeDidLoad:ad];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) request:request didLoadWithAd:ad];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidFail_witNilListener_shouldPass
{
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    request.delegate = nil;
    NSError *error = mock([NSError class]);
    [request invokeDidFail:error];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidFail_withValidListener_shouldCallback
{
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    NSObject <HyBidAdRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdRequestDelegate));
    request.delegate = delegate;
    NSError *error = mock([NSError class]);
    [request invokeDidFail:error];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) request:request didFailWithError:error];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

@end
