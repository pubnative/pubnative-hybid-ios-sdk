// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>
#import "PNLiteHttpRequest.h"
#import "HyBidError.h"

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
    NSError* error = [NSError hyBidServerErrorWithMessage:@"URL is nil or empty."];
    [verify(delegate)request:request didFailWithError:error];
}

- (void)test_startWithUrlString_withValidDelegateAndWithValidMethodAndWithEmptyUrl_shouldCallbackFail
{
    NSObject<PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    [request startWithUrlString:@"" withMethod:@"GET" delegate:delegate];
    NSError* error = [NSError hyBidServerErrorWithMessage:@"URL is nil or empty."];
    [verify(delegate)request:request didFailWithError:error];
}

- (void)test_startWithUrlString_withValidDelegateAndWithValidUrlAndWithNotValidMethod_shouldCallbackFail
{
    NSObject<PNLiteHttpRequestDelegate> *delegate = mockProtocol(@protocol(PNLiteHttpRequestDelegate));
    PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
    [request startWithUrlString:@"validURL" withMethod:@"notValidMethod" delegate:delegate];
    NSError* error = [NSError hyBidServerErrorWithMessage:@"Unsupported HTTP method, dropping the call."];
    [verify(delegate)request:request didFailWithError:error];
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
