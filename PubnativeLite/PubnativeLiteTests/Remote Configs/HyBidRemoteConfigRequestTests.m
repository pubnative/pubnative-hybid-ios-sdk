//
//  Copyright © 2021 PubNative. All rights reserved.
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
#import <OCMockitoIOS/OCMockitoIOS.h>
#import "HyBidRemoteConfigRequest.h"
#import "HyBidEncryption.h"

@interface HyBidRemoteConfigRequest()

@property (nonatomic, weak) NSObject <HyBidRemoteConfigRequestDelegate> *delegate;

- (void)invokeDidLoad:(HyBidRemoteConfigModel *)model;

- (void)invokeDidFail:(NSError *)error;

@end

@interface HyBidRemoteConfigRequestTests : XCTestCase

@property (nonatomic) HyBidRemoteConfigRequest *request;

@end

@implementation HyBidRemoteConfigRequestTests

- (void)setUp {
    self.request = [[HyBidRemoteConfigRequest alloc] init];
}

- (void)test_invokeDidLoad_withNilListener_shouldPass
{
    self.request.delegate = nil;
    [self.request invokeDidLoad:mock([HyBidRemoteConfigModel class])];
    
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
    NSObject<HyBidRemoteConfigRequestDelegate> *delegate = mockProtocol(@protocol(HyBidRemoteConfigRequestDelegate));
    HyBidRemoteConfigModel *mockModel = mock([HyBidRemoteConfigModel class]);
    
    self.request.delegate = delegate;
    [self.request invokeDidLoad:mockModel];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) remoteConfigRequestSuccess:mockModel];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)test_invokeDidFail_witNilListener_shouldPass
{
    self.request.delegate = nil;
    NSError *error = mock([NSError class]);
    [self.request invokeDidFail:error];
    
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
    NSObject<HyBidRemoteConfigRequestDelegate> *delegate = mockProtocol(@protocol(HyBidRemoteConfigRequestDelegate));
    self.request.delegate = delegate;
    NSError *error = mock([NSError class]);
    [self.request invokeDidFail:error];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [verify(delegate) remoteConfigRequestFail:error];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)tearDown {
    self.request = nil;
}

@end
