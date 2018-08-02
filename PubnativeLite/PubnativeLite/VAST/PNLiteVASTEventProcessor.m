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

@interface PNLiteVASTEventProcessor()

@property(nonatomic, strong) NSDictionary *events;
@property(nonatomic, weak) NSObject<PNLiteVASTEventProcessorDelegate> *delegate;
@property (nonatomic, strong) NSString *userAgent;

@end

@implementation PNLiteVASTEventProcessor

// designated initializer
- (id)initWithEvents:(NSDictionary *)events delegate:(id<PNLiteVASTEventProcessorDelegate>)delegate;
{
    self = [super init];
    if (self) {
        self.events = events;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    self.events = nil;
    self.userAgent = nil;
}

- (void)trackEvent:(PNLiteVASTEvent)event
{
    NSString *eventString = nil;
    switch (event) {
        case PNLiteVASTEvent_Start:           eventString = @"start";           break;
        case PNLiteVASTEvent_FirstQuartile:   eventString = @"firstQuartile";   break;
        case PNLiteVASTEvent_Midpoint:        eventString = @"midpoint";        break;
        case PNLiteVASTEvent_ThirdQuartile:   eventString = @"thirdQuartile";   break;
        case PNLiteVASTEvent_Complete:        eventString = @"complete";        break;
        case PNLiteVASTEvent_Close:           eventString = @"close";           break;
        case PNLiteVASTEvent_Pause:           eventString = @"pause";           break;
        case PNLiteVASTEvent_Resume:          eventString = @"resume";          break;
        default: break;
    }
    [self invokeDidTrackEvent:event];
    if(eventString == nil) {
        [self invokeDidTrackEvent:PNLiteVASTEvent_Unknown];
    } else {
        for (NSURL *eventUrl in self.events[eventString]) {
            [self sendTrackingRequest:eventUrl];
            NSLog(@"VAST - Event Processor: Sent event '%@' to url: %@", eventString, [eventUrl absoluteString]);
        }
    }
}

- (void)invokeDidTrackEvent:(PNLiteVASTEvent)event
{
    if ([self.delegate respondsToSelector:@selector(eventProcessorDidTrackEvent:)]) {
        [self.delegate eventProcessorDidTrackEvent:event];
    }
}

- (void)sendVASTUrls:(NSArray *)urls
{
    for (NSURL *url in urls) {
        [self sendTrackingRequest:url];
        NSLog(@"VAST - Event Processor: Sent http request to url: %@", url);
    }
}

- (void)sendTrackingRequest:(NSURL *)url
{
    dispatch_queue_t sendTrackRequestQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(sendTrackRequestQueue, ^{
        
        NSLog(@"VAST - Event Processor: Event processor sending request to url: %@", [url absoluteString]);
        
        NSURLSession * session = [NSURLSession sharedSession];
        if(self.userAgent == nil){
            // Perform on main thread/queue
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
                session.configuration.HTTPAdditionalHeaders = @{@"User-Agent": self.userAgent};
                NSURLRequest* request = [NSURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:1.0];
                
                [[session dataTaskWithRequest:request
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                
                                // Send the request only, no response or errors
                                if(error == nil) {
                                    NSLog(@"VAST - tracking url %@ error: %@", response.URL, error);
                                } else {
                                    NSLog(@"VAST - tracking url %@ response: %@", response.URL, [NSString stringWithUTF8String:[data bytes]]);
                                }
                            }] resume];
            });
        }
    });
}

@end
