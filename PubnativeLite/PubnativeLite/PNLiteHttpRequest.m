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

#import "PNLiteHttpRequest.h"
#import "PNLiteReachability.h"

NSTimeInterval const kPNLiteHttpRequestDefaultTimeout = 60;
NSURLRequestCachePolicy const kPNLiteHttpRequestDefaultCachePolicy = NSURLRequestUseProtocolCachePolicy;

@interface PNLiteHttpRequest ()

@property (nonatomic, strong) NSObject<PNLiteHttpRequestDelegate> *delegate;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *userAgent;

@end

@implementation PNLiteHttpRequest

- (void)dealloc
{
    self.delegate = nil;
    self.urlString = nil;
    self.userAgent = nil;
}

- (void)startWithUrlString:(NSString *)urlString delegate:(NSObject<PNLiteHttpRequestDelegate> *)delegate
{
    self.delegate = delegate;
    self.urlString = urlString;
    
    if (self.delegate == nil) {
        NSLog(@"PNLiteHttpRequest - Delegate is nil, dropping the call.");
    } else if(self.urlString == nil || self.urlString.length <= 0) {
        [self invokeFailWithMessage:@"URL is nil or empty"];
    } else {
        PNLiteReachability *reachability = [PNLiteReachability reachabilityForInternetConnection];
        [reachability startNotifier];
        if([reachability currentReachabilityStatus] == PNLiteNetworkStatus_NotReachable){
            [reachability stopNotifier];
            [self invokeFailWithMessage:@"Internet is not available."];
        } else {
            [reachability stopNotifier];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.userAgent == nil){
                    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                    self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self makeRequest];
                });
            });
        }
    }
}

- (void)makeRequest
{
    NSURL *url = [NSURL URLWithString:self.urlString];
    if (url == nil) {
        NSString *message = [NSString stringWithFormat:@"URL cannot be parsed: %@", self.urlString];
        [self invokeFailWithMessage:message];
    } else {
        NSURLSession * session = [NSURLSession sharedSession];
        session.configuration.HTTPAdditionalHeaders = @{@"User-Agent": self.userAgent};
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:kPNLiteHttpRequestDefaultCachePolicy
                                                           timeoutInterval:kPNLiteHttpRequestDefaultTimeout];
        
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        if (error) {
                            [self invokeFailWithError:error];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self invokeFinishWithData:data statusCode:httpResponse.statusCode];
                            });
                        }
                    }] resume];
    }
}

- (void)invokeFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFinishWithData:statusCode:)]) {
        [self.delegate request:self didFinishWithData:data statusCode:statusCode];
    }
    self.delegate = nil;
}

- (void)invokeFailWithMessage:(NSString *)message
{
    NSError *error = [NSError errorWithDomain:message code:0 userInfo:nil];
    [self invokeFailWithError:error];
}

- (void)invokeFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.delegate request:self didFailWithError:error];
    }
    self.delegate = nil;
}

@end
