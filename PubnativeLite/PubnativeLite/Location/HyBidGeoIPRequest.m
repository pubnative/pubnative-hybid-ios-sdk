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

#import "HyBidGeoIPRequest.h"
#import "PNLiteHttpRequest.h"
#import "PNLiteConsentEndpoints.h"
#import "HyBidLogger.h"

NSString *const PNLiteGeoIPResponseSuccess = @"success";
NSString *const PNLiteGeoIPResponseFail = @"fail";

@interface HyBidGeoIPRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidGeoIPRequestDelegate> *delegate;

@end

@implementation HyBidGeoIPRequest

- (void)dealloc {
    self.delegate = nil;
}

- (void)requestGeoIPWithDelegate:(NSObject<HyBidGeoIPRequestDelegate> *)delegate {
    if(!delegate) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Given delegate is nil and required, droping this call."];
    } else {
        self.delegate = delegate;
        [self invokeDidStart];
        [[PNLiteHttpRequest alloc] startWithUrlString:[PNLiteConsentEndpoints geoIPURL] withMethod:@"GET" delegate:self];
    }
}

- (void)invokeDidStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
            [self.delegate requestDidStart:self];
        }
    });
}

- (void)invokeDidLoad:(NSString *)countryCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:didLoadWithCountryCode:)]) {
            [self.delegate request:self didLoadWithCountryCode:countryCode];
        }
        self.delegate = nil;
    });
}

- (void)invokeDidFail:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
        if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [self.delegate request:self didFailWithError:error];
        }
        self.delegate = nil;
    });
}

- (void)processResponseWithData:(NSData *)data {
    NSString *countryCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!countryCode) {
        NSError *error = [NSError errorWithDomain:@"Can't parse country code from server."
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    } else {
        [self invokeDidLoad:countryCode];
    }
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    [self processResponseWithData:data];
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFail:error];
}
@end
