//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidReportingManager.h"
#import "HyBidSettings.h"
#import "HyBidReportingRequest.h"
#import "HyBidReportingEvent.h"
#import "HyBidRemoteConfigManager.h"
#import "HyBidRemoteConfigFeature.h"
#import "HyBidLogger.h"

@interface HyBidReportingManager() <HyBidReportingRequestDelegate>

@end

@implementation HyBidReportingManager

+ (HyBidReportingManager *)sharedInstance {
    static HyBidReportingManager *_reportingManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reportingManager = [[HyBidReportingManager alloc] init];
        _reportingManager.events = [[NSMutableArray alloc]init];
    });
    return _reportingManager;
}

- (void)reportEventFor:(HyBidReportingEvent *)event {
    [self.events addObject:event];
    [self performReportingRequestWithEvent:event];
}

- (void)reportEventsFor:(NSArray<HyBidReportingEvent *> *)events {
    [self.events addObjectsFromArray:events];
    for (HyBidReportingEvent *event in events) {
        [self performReportingRequestWithEvent:event];
    }
}

- (void)performReportingRequestWithEvent:(HyBidReportingEvent *)event {
    if (event) {
        HyBidReportingRequest *request = [[HyBidReportingRequest alloc] init];
        if (([event.eventType isEqualToString:HyBidReportingEventType.ERROR] || [event.eventType isEqualToString:HyBidReportingEventType.RENDER_ERROR]) &&
            [HyBidRemoteConfigManager.sharedInstance.featureResolver isReportingModeEnabled:[HyBidRemoteConfigFeature hyBidRemoteReportingToString:HyBidRemoteReporting_AD_ERRORS]]) {
            [request doReportingRequestWithDelegate:self withReportingEvent:event];
        } else {
            if ([HyBidRemoteConfigManager.sharedInstance.featureResolver isReportingModeEnabled:[HyBidRemoteConfigFeature hyBidRemoteReportingToString:HyBidRemoteReporting_AD_EVENTS]]) {
                [request doReportingRequestWithDelegate:self withReportingEvent:event];
            }
        }
    }
}

- (void)clearEvents {
    [self.events removeAllObjects];
}

#pragma mark HyBidReportingRequestDelegate

- (void)reportingRequestSuccessForEvent:(HyBidReportingEvent *)event {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@ event is successfully reported", event.eventType]];
}

- (void)reportingRequestFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
}
@end
