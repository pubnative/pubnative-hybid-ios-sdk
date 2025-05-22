// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import "HyBidAdTrackerRequest.h"

@interface HyBidAdTrackerRequest()

@property (nonatomic, weak) NSObject <HyBidAdTrackerRequestDelegate> *delegate;
- (void)invokeDidStart;
- (void)invokeDidLoad;
- (void)invokeDidFail:(NSError *)error;
@end

@interface HyBidAdTrackerRequestTest : XCTestCase

@end

@implementation HyBidAdTrackerRequestTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_trackAdWithDelegate_withNilDelegateAndWithValidUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    [request trackAdWithDelegate:nil withURL:@"validURL"];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithNilUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject <HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:nil];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithEmptyUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject <HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:@""];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithValidUrl_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject <HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:@"validURL"];
}

- (void)test_invokeDidStart_withNilListener_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
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
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
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
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
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
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
    request.delegate = delegate;
    [request invokeDidLoad];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) requestDidFinish:request];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidFail_witNilListener_shouldPass
{
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
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
    HyBidAdTrackerRequest *request = [[HyBidAdTrackerRequest alloc] init];
    NSObject<HyBidAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(HyBidAdTrackerRequestDelegate));
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
