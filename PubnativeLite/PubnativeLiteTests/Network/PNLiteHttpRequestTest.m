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
#import "PNLiteHttpRequest.h"

NSInteger const kStatusCode = 200;

@interface PNLiteHttpRequest ()

@property (nonatomic, strong) NSObject<PNLiteHttpRequestDelegate> *delegate;
- (void)invokeFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode;
- (void)invokeFailWithError:(NSError *)error andAttemptRetry:(BOOL)retry;

@end

@interface PNLiteHttpRequestTest : XCTestCase

@end

@implementation PNLiteHttpRequestTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_startWithUrlString_withNilDelegateAndWithValidUrlAndWithValidMethod_shouldPass
{
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    [request startWithUrlString:@"validURL" withMethod:@"GET" delegate:nil];
}

- (void)test_startWithUrlString_withValidDelegateAndWithValidMethodAndWithNilUrl_shouldCallbackFail
{
    NSObject<PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    [request startWithUrlString:nil withMethod:@"GET" delegate:delegate];
    [verify(delegate)request:request didFailWithError:instanceOf([NSError class])];
}

- (void)test_startWithUrlString_withValidDelegateAndWithValidMethodAndWithEmptyUrl_shouldCallbackFail
{
    NSObject<PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    [request startWithUrlString:@"" withMethod:@"GET" delegate:delegate];
    [verify(delegate)request:request didFailWithError:instanceOf([NSError class])];
}

- (void)test_startWithUrlString_withValidDelegateAndWithValidUrlAndWithNotValidMethod_shouldCallbackFail
{
    NSObject<PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    [request startWithUrlString:@"validURL" withMethod:@"notValidMethod" delegate:delegate];
    [verify(delegate)request:request didFailWithError:instanceOf([NSError class])];
}

- (void)test_startWithUrlString_withValidDelegateAndWithValidMethodAndValidUrl_shouldPass
{
    NSObject<PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    [request startWithUrlString:@"validURL" withMethod:@"GET" delegate:delegate];
}

- (void)test_invokeFinishWithData_withValidListener_shouldCallback
{
    NSObject<PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    request.delegate = delegate;
    NSData *data = mock([NSData class]);
    [request invokeFinishWithData:data statusCode:kStatusCode];
    [verify(delegate) request:request didFinishWithData:data statusCode:kStatusCode];
}

- (void)test_invokeFinishWithData_withNilListener_shouldPass
{
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    NSData *data = mock([NSData class]);
    [request invokeFinishWithData:data statusCode:kStatusCode];
}

- (void)test_invokeFailWithError_withValidListener_andNoRetryAttempt_shouldCallbackFail
{
    NSObject <PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    request.delegate = delegate;
    NSError *error = mock([NSError class]);
    [request invokeFailWithError:error andAttemptRetry:NO];
    [verify(delegate)request:request didFailWithError:error];
}

- (void)test_invokeFailWithError_witNilListener_andNoRetryAttempt_shouldPass
{
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    NSError *error = mock([NSError class]);
    [request invokeFailWithError:error andAttemptRetry:NO];
}

@end
