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

#import "PNLiteVASTEventProcessor.h"
#import "HyBidLogger.h"
#import "HyBidWebBrowserUserAgentInfo.h"
#import "HyBidViewabilityNativeVideoAdSession.h"

@interface PNLiteVASTEventProcessor()

@property(nonatomic, strong) NSDictionary *events;
@property(nonatomic, weak) NSObject<PNLiteVASTEventProcessorDelegate> *delegate;

@end

@implementation PNLiteVASTEventProcessor

// designated initializer
- (id)initWithEvents:(NSDictionary *)events delegate:(id<PNLiteVASTEventProcessorDelegate>)delegate; {
    self = [super init];
    if (self) {
        self.events = events;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    self.events = nil;
}

- (void)trackEvent:(PNLiteVASTEvent)event {
    NSString *eventString = nil;
    switch (event) {
        case PNLiteVASTEvent_Start:
            eventString = @"start";
            break;
        case PNLiteVASTEvent_FirstQuartile:
            eventString = @"firstQuartile";
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDFirstQuartileEvent];
            break;
        case PNLiteVASTEvent_Midpoint:
            eventString = @"midpoint";
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDMidpointEvent];
            break;
        case PNLiteVASTEvent_ThirdQuartile:
            eventString = @"thirdQuartile";
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDThirdQuartileEvent];
            break;
        case PNLiteVASTEvent_Complete:
            eventString = @"complete";
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDCompleteEvent];
            break;
        case PNLiteVASTEvent_Close:
            eventString = @"close";
            break;
        case PNLiteVASTEvent_Pause:
            eventString = @"pause";
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDPauseEvent];
            break;
        case PNLiteVASTEvent_Resume:
            eventString = @"resume";
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDResumeEvent];
            break;
        case PNLiteVASTEvent_Click:
            eventString = @"click";
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDClikedEvent];
            break;
        default: break;
    }
    [self invokeDidTrackEvent:event];
    if(!eventString) {
        [self invokeDidTrackEvent:PNLiteVASTEvent_Unknown];
    } else {
        for (NSURL *eventUrl in self.events[eventString]) {
            [self sendTrackingRequest:[eventUrl absoluteString]];
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Sent event '%@' to url: %@", eventString, [eventUrl absoluteString]]];
        }
    }
}

- (void)invokeDidTrackEvent:(PNLiteVASTEvent)event {
    if ([self.delegate respondsToSelector:@selector(eventProcessorDidTrackEvent:)]) {
        [self.delegate eventProcessorDidTrackEvent:event];
    }
}

- (void)sendVASTUrls:(NSArray *)urls {
    for (NSString *stringURL in urls) {
        [self sendTrackingRequest:stringURL];
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Sent http request to url: %@", stringURL]];
    }
}

- (void)sendTrackingRequest:(NSString *)url {
    dispatch_queue_t sendTrackRequestQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(sendTrackRequestQueue, ^{
        
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Event processor sending request to url: %@", url]];
        
        NSURLSession * session = [NSURLSession sharedSession];
            dispatch_async(dispatch_get_main_queue(), ^{
                session.configuration.HTTPAdditionalHeaders = @{@"User-Agent": HyBidWebBrowserUserAgentInfo.hyBidUserAgent};
                NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:1.0];
                
                [[session dataTaskWithRequest:request
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                
                                // Send the request only, no response or errors
                                if(!error) {
                                    if ([data length] > 0) {
                                        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking url %@ response: %@", response.URL, [NSString stringWithUTF8String:[data bytes]]]];
                                    } else {
                                        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking url: %@", response.URL]];
                                    }
                                } else {
                                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking url %@ error: %@", response.URL, error]];
                                }
                            }] resume];
            });
        
    });
}

@end
