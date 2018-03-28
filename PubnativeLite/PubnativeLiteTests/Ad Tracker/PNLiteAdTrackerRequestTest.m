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

#import <XCTest/XCTest.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "PNLiteAdTrackerRequest.h"

@interface PNLiteAdTrackerRequest()

@property (nonatomic, weak) NSObject <PNLiteAdTrackerRequestDelegate> *delegate;
- (void)invokeDidStart;
- (void)invokeDidLoad;
- (void)invokeDidFail:(NSError *)error;
@end

@interface PNLiteAdTrackerRequestTest : XCTestCase

@end

@implementation PNLiteAdTrackerRequestTest

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
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
    [request trackAdWithDelegate:nil withURL:@"validURL"];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithNilUrl_shouldPass
{
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
    NSObject <PNLiteAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:nil];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithEmptyUrl_shouldPass
{
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
    NSObject <PNLiteAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:@""];
}

- (void)test_trackAdWithDelegate_withValidDelegateAndWithValidUrl_shouldPass
{
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
    NSObject <PNLiteAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteAdTrackerRequestDelegate));
    [request trackAdWithDelegate:delegate withURL:@"validURL"];
}

- (void)test_invokeDidStart_withNilListener_shouldPass
{
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
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
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
    NSObject<PNLiteAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteAdTrackerRequestDelegate));
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
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
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
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
    NSObject<PNLiteAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteAdTrackerRequestDelegate));
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
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
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
    PNLiteAdTrackerRequest *request = [[PNLiteAdTrackerRequest alloc] init];
    NSObject<PNLiteAdTrackerRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteAdTrackerRequestDelegate));
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
