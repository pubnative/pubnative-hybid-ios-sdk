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

#import "HyBidVASTEventProcessor.h"
#import "HyBidWebBrowserUserAgentInfo.h"
#import "HyBidViewabilityNativeVideoAdSession.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif


@interface HyBidVASTEventProcessor()

@property(nonatomic, strong) NSMutableArray<HyBidVASTTracking *> *events;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *eventsDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *progressEvents;
@property(nonatomic, weak) NSObject<HyBidVASTEventProcessorDelegate> *delegate;

@end

@implementation HyBidVASTEventProcessor
- (id)initWithEventsDictionary:(NSDictionary<NSString *, NSMutableArray<NSString *> *> *)eventDictionary progressEventsDictionary:(NSDictionary<NSString *, NSString *> *)progressEventDictionary delegate:(id<HyBidVASTEventProcessorDelegate>)delegate {
    self = [super init];
    if (self) {
        self.eventsDictionary = [eventDictionary mutableCopy];
        self.progressEvents = [progressEventDictionary mutableCopy];
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithEvents:(NSArray<HyBidVASTTracking *> *)events delegate:(id<HyBidVASTEventProcessorDelegate>)delegate {
    self = [super init];
    if (self) {
        self.events = [events mutableCopy];
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    self.events = nil;
    self.eventsDictionary = nil;
    self.progressEvents = nil;
}

- (void)trackEventWithType:(HyBidVASTAdTrackingEventType)type
{
    NSString *eventString = nil;
    
    if (type == HyBidVASTAdTrackingEventType_start) {
        eventString = HyBidVASTAdTrackingEventType_start;
    } else if (type == HyBidVASTAdTrackingEventType_firstQuartile) {
        eventString = HyBidVASTAdTrackingEventType_firstQuartile;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDFirstQuartileEvent];
    } else if (type == HyBidVASTAdTrackingEventType_midpoint) {
        eventString = HyBidVASTAdTrackingEventType_midpoint;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDMidpointEvent];
    } else if (type == HyBidVASTAdTrackingEventType_thirdQuartile) {
        eventString = HyBidVASTAdTrackingEventType_thirdQuartile;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDThirdQuartileEvent];
    } else if (type == HyBidVASTAdTrackingEventType_complete) {
        eventString = HyBidVASTAdTrackingEventType_complete;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDCompleteEvent];
    } else if (type == HyBidVASTAdTrackingEventType_skip) {
        eventString = HyBidVASTAdTrackingEventType_skip;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDSkippedEvent];
    } else if (type == HyBidVASTAdTrackingEventType_creativeView) {
        eventString = HyBidVASTAdTrackingEventType_creativeView;
    } else if (type == HyBidVASTAdTrackingEventType_close) {
        eventString = HyBidVASTAdTrackingEventType_close;
    } else if (type == HyBidVASTAdTrackingEventType_closeLinear) {
        eventString = HyBidVASTAdTrackingEventType_closeLinear;
    } else if (type == HyBidVASTAdTrackingEventType_pause) {
        eventString = HyBidVASTAdTrackingEventType_pause;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDPauseEvent];
    } else if (type == HyBidVASTAdTrackingEventType_resume) {
        eventString = HyBidVASTAdTrackingEventType_resume;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDResumeEvent];
    } else if (type == HyBidVASTAdTrackingEventType_ctaClick) {
        eventString = HyBidVASTAdTrackingEventType_ctaClick;
    } else if (type == HyBidVASTAdTrackingEventType_mute) {
        eventString = HyBidVASTAdTrackingEventType_mute;
    } else if (type == HyBidVASTAdTrackingEventType_unmute) {
        eventString = HyBidVASTAdTrackingEventType_unmute;
    } else if ([type isEqualToString:@"click"]) {
        eventString = @"click";
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDClikedEvent];
    }
    
    [self invokeDidTrackEvent:type];
    if(!eventString) {
        [self invokeDidTrackEvent:@"unknown"];
    } else {
        if (self.eventsDictionary != nil && self.eventsDictionary.count != 0) {
            NSArray<NSString *> *urlStrings = self.eventsDictionary[eventString];
            if (urlStrings && urlStrings.count > 0) {
                for (NSString *urlString in urlStrings) {
                    [self sendTrackingRequest:urlString];
                    [HyBidLogger debugLogFromClass:NSStringFromClass([self class])
                                        fromMethod:NSStringFromSelector(_cmd)
                                       withMessage:[NSString stringWithFormat:@"Sent event '%@' to url: %@", eventString, urlString]];
                }
            }
        }else if (self.events.count != 0) {
            for (HyBidVASTTracking *event in self.events) {
                if ([[event event] isEqualToString:eventString]) {
                    [self sendTrackingRequest:[event url]];
                    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Sent event '%@' to url: %@", eventString, [event url]]];
                }
            }
        }
    }
}
- (void)trackProgressEvent:(NSString*)offset {
    if (self.progressEvents != nil && self.progressEvents.count != 0) {
        NSString* urlString = self.progressEvents[offset];
        [self sendTrackingRequest:urlString];
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class])
                            fromMethod:NSStringFromSelector(_cmd)
                           withMessage:[NSString stringWithFormat:@"Sent event '%@' to url: %@", HyBidVASTAdTrackingEventType_progress, urlString]];
    }
}


- (void)trackImpression:(HyBidVASTImpression *)impression {
    if (impression != NULL) {
        [self sendTrackingRequest:impression.url];
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Sent event impression to url: %@", impression.url]];
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error while sending event impression"]];
    }

}

- (void)trackImpressionWith:(NSString *)impressionURL {
    if (impressionURL && impressionURL.length != 0) {
        [self sendTrackingRequest:impressionURL];
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Sent event impression to url: %@", impressionURL]];
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error while sending event impression"]];
    }
}

- (void)invokeDidTrackEvent:(HyBidVASTAdTrackingEventType)event {
    if ([self.delegate respondsToSelector:@selector(eventProcessorDidTrackEventType:)]) {
        [self.delegate eventProcessorDidTrackEventType:event];
    }
}

- (void)sendVASTUrls:(NSArray *)urls {
    for (NSString *stringURL in urls) {
        [self sendTrackingRequest:stringURL];
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Sent http request to url: %@", stringURL]];
    }
}

- (void)setCustomEvents:(NSArray<HyBidVASTTracking *> *)events
{
    self.events = [events mutableCopy];
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
                    if ([data length] > 0 && [data length] < 100) { // Ignore debugging long responses
                        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking url %@ response: %@", response.URL, [NSString stringWithUTF8String:[data bytes]]]];
                    } else {
                        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking url: %@", response.URL]];
                    }
                } else {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking url %@ error: %@", response.URL, error]];
                    if ([HyBidSDKConfig sharedConfig].reporting) {
                        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                        [[HyBid reportingManager] reportEventFor:reportingEvent];
                    }
                }
            }] resume];
        });
        
    });
}

@end
