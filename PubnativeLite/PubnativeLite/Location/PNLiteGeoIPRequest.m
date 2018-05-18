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

#import "PNLiteGeoIPRequest.h"
#import "PNLiteHttpRequest.h"

NSString *const kPNLiteGeoIPRequestBaseUrl = @"http://ip-api.com/json";
NSString *const kPNLiteGeoIPResponseSuccess = @"success";
NSString *const kPNLiteGeoIPResponseFail = @"fail";

@interface PNLiteGeoIPRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <PNLiteGeoIPRequestDelegate> *delegate;

@end

@implementation PNLiteGeoIPRequest

- (void)requestGeoIPWithDelegate:(NSObject<PNLiteGeoIPRequestDelegate> *)delegate
{
    if(delegate == nil){
        NSLog(@"PNLiteGeoIPRequest - Given delegate is nil and required, droping this call");
    } else {
        self.delegate = delegate;
        [self invokeDidStart];
        [[PNLiteHttpRequest alloc] startWithUrlString:kPNLiteGeoIPRequestBaseUrl delegate:self];
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

- (void)invokeDidLoad:(PNLiteGeoIPModel *)geoIP
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:didLoadWithGeoIP:)]) {
            [self.delegate request:self didLoadWithGeoIP:geoIP];
        }
        self.delegate = nil;
    });
}

- (void)invokeDidFail:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]){
            [self.delegate request:self didFailWithError:error];
        }
        self.delegate = nil;
    });
}

- (void)processResponseWithData:(NSData *)data
{
    NSError *parseError;
    NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&parseError];
    if (parseError) {
        [self invokeDidFail:parseError];
    } else {
        PNLiteGeoIPModel *geoIP = [[PNLiteGeoIPModel alloc] initWithDictionary:jsonDictonary];
        if(geoIP == nil) {
            NSError *error = [NSError errorWithDomain:@"Error: Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        } else if ([kPNLiteGeoIPResponseSuccess isEqualToString:geoIP.status]) {
            [self invokeDidLoad:geoIP];
            
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"PNLiteGeoIPRequest - %@", geoIP.message];
            NSError *responseError = [NSError errorWithDomain:errorMessage
                                                         code:0
                                                     userInfo:nil];
            [self invokeDidFail:responseError];
        }
    }
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode
{
    [self processResponseWithData:data];
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error
{
    [self invokeDidFail:error];
}
@end
