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

#import "PNLiteAdTrackerRequest.h"
#import "PNLiteHttpRequest.h"

NSString *const kPNLiteAdTrackerRequestResponseOK = @"ok";
NSString *const kPNLiteAdTrackerRequestResponseError = @"error";
NSInteger const kPNLiteAdTrackerRequestResponseStatusOK = 200;
NSInteger const kPNLiteAdTrackerRequestResponseStatusRequestMalformed = 422;

@interface PNLiteAdTrackerRequest() <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <PNLiteAdTrackerRequestDelegate> *delegate;

@end

@implementation PNLiteAdTrackerRequest

- (void)trackAdWithDelegate:(NSObject<PNLiteAdTrackerRequestDelegate> *)delegate withURL:(NSString *)url
{
    if(delegate == nil){
        NSLog(@"PNLiteAdTrackerRequest - Given delegate is nil and required, droping this call");
    } else if(url == nil || url.length == 0){
        NSLog(@"PNLiteAdTrackerRequest - URL nil or empty, droping this call");
    } else {
        self.delegate = delegate;
        [self invokeDidStart];
        [[PNLiteHttpRequest alloc] startWithUrlString:url delegate:self];
    }
}

- (void)invokeDidStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
            [self.delegate requestDidStart:self];
        }
    });
}

- (void)invokeDidLoad
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinish:)]) {
            [self.delegate requestDidFinish:self];
        }
    });
}

- (void)invokeDidFail:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]){
            [self.delegate request:self didFailWithError:error];
        }
    });
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode
{
    if(kPNLiteAdTrackerRequestResponseStatusOK == statusCode ||
       kPNLiteAdTrackerRequestResponseStatusRequestMalformed == statusCode) {
        [self invokeDidLoad];
    } else {
        NSError *statusError = [NSError errorWithDomain:@"PNLiteHttpRequestDelegate - Server error: status code" code:statusCode userInfo:nil];
        [self invokeDidFail:statusError];
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error
{
    [self invokeDidFail:error];
}

@end
