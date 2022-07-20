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

#import "HyBidReportingRequest.h"
#import "PNLiteHttpRequest.h"
#import "HyBidReportingEndpoints.h"
#import "HyBidLogger.h"

@interface HyBidReportingRequest() <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidReportingRequestDelegate> *delegate;
@property (nonatomic, strong) HyBidReportingEvent *event;
@end

@implementation HyBidReportingRequest

- (void)dealloc {
    self.delegate = nil;
    self.event = nil;
}

- (void)doReportingRequestWithDelegate:(NSObject<HyBidReportingRequestDelegate> *)delegate
                    withReportingEvent:(HyBidReportingEvent *)event {
    if (!delegate) {
        [self invokeDidFail:[NSError errorWithDomain:@"Given delegate is nil and required, droping this call." code:0 userInfo:nil]];
    } else if(!event) {
        [self invokeDidFail:[NSError errorWithDomain:@"Given event is nil and required, droping this call." code:0 userInfo:nil]];
    } else {
        self.delegate = delegate;
        self.event = event;
        NSString *url = [HyBidReportingEndpoints reportingURL];
        NSError *error = nil;
        NSData *eventJSONData = [NSJSONSerialization dataWithJSONObject:self.event.properties options:0 error:&error];
        if (error) {
            [self invokeDidFail:[NSError errorWithDomain:@"Error when processing the event data, droping this call." code:0 userInfo:nil]];
        }
        PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
        request.body = eventJSONData;
        [request startWithUrlString:url withMethod:@"POST" delegate:self];
    }
}
- (void)invokeDidSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(reportingRequestSuccessForEvent:)]) {
            [self.delegate reportingRequestSuccessForEvent:self.event];
        }
        self.delegate = nil;
    });
}

- (void)invokeDidFail:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
        if(self.delegate && [self.delegate respondsToSelector:@selector(reportingRequestFail:)]) {
            [self.delegate reportingRequestFail:error];
        }
        self.delegate = nil;
    });
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    [self invokeDidSuccess];
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFail:error];
}

@end
