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

#import "HyBidAdTracker.h"
#import "HyBidDataModel.h"
#import "HyBidLogger.h"
#import "HyBidURLDriller.h"
#import <WebKit/WebKit.h>
#import "HyBid.h"

NSString *const PNLiteAdTrackerClick = @"click";
NSString *const PNLiteAdTrackerImpression = @"impression";

@interface HyBidAdTracker() <HyBidAdTrackerRequestDelegate, HyBidURLDrillerDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) HyBidAdTrackerRequest *adTrackerRequest;
@property (nonatomic, strong) NSArray *impressionURLs;
@property (nonatomic, strong) NSArray *clickURLs;
@property (nonatomic, assign) BOOL impressionTracked;
@property (nonatomic, assign) BOOL clickTracked;
@property (nonatomic, strong) NSString *trackTypeForURL;
@property (nonatomic, assign) BOOL urlDrillerEnabled;

@end

@implementation HyBidAdTracker

- (void)dealloc {
    self.adTrackerRequest = nil;
    self.impressionURLs = nil;
    self.clickURLs = nil;
    self.wkWebView = nil;
    self.trackTypeForURL = nil;
}

- (instancetype)initWithImpressionURLs:(NSArray *)impressionURLs
                         withClickURLs:(NSArray *)clickURLs {
    HyBidAdTrackerRequest *adTrackerRequest = [[HyBidAdTrackerRequest alloc] init];
    return [self initWithAdTrackerRequest:adTrackerRequest withImpressionURLs:impressionURLs withClickURLs:clickURLs];
}

- (instancetype)initWithAdTrackerRequest:(HyBidAdTrackerRequest *)adTrackerRequest
                      withImpressionURLs:(NSArray *)impressionURLs
                           withClickURLs:(NSArray *)clickURLs {
    self = [super init];
    if (self) {
        self.adTrackerRequest = adTrackerRequest;
        self.impressionURLs = impressionURLs;
        self.clickURLs = clickURLs;
        self.wkWebView = [[WKWebView alloc]initWithFrame:CGRectZero];
    }
    return self;
}

- (void)trackClickWithAdFormat:(NSString *)adFormat {
    if (self.clickTracked) {
        return;
    }
    
    [self trackURLs:self.clickURLs withTrackType:PNLiteAdTrackerClick];
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CLICK adFormat:adFormat properties:nil];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
    self.clickTracked = YES;
}

- (void)trackImpressionWithAdFormat:(NSString *)adFormat {
    if (self.impressionTracked) {
        return;
    }
    
    [self trackURLs:self.impressionURLs withTrackType:PNLiteAdTrackerImpression];
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.IMPRESSION adFormat:adFormat properties:nil];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
    self.impressionTracked = YES;
}

- (void)trackURLs:(NSArray *)URLs withTrackType:(NSString *)trackType {
    if (URLs != nil) {
        for (HyBidDataModel *dataModel in URLs) {
            if (dataModel.url != nil) {
                if (self.urlDrillerEnabled) {
                    self.trackTypeForURL = trackType;
                    [[[HyBidURLDriller alloc] init] startDrillWithURLString:dataModel.url delegate:self];
                } else {
                    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking %@ with URL: %@",trackType, dataModel.url]];
                    [self.adTrackerRequest trackAdWithDelegate:self withURL:dataModel.url];
                }
            } else if (dataModel.js != nil) {
                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking %@ with JS Beacon: %@",trackType, dataModel.js]];
                [self.wkWebView evaluateJavaScript:dataModel.js completionHandler:^(id _Nullable success, NSError * _Nullable error) {}];
            }
        }
    }
}

#pragma mark HyBidAdTrackerRequestDelegate

- (void)requestDidStart:(HyBidAdTrackerRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Tracker Request %@ started:",request]];
}

- (void)requestDidFinish:(HyBidAdTrackerRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Tracker Request %@ finished:",request]];
}

- (void)request:(HyBidAdTrackerRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Tracker Request %@ failed with error: %@",request,error.localizedDescription]];
}

#pragma mark HyBidURLDrillerDelegate

- (void)didStartWithURL:(NSURL *)url {
    
}

- (void)didRedirectWithURL:(NSURL *)url {
    
}

- (void)didFinishWithURL:(NSURL *)url {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking %@ with URL: %@",self.trackTypeForURL, [url absoluteString]]];
    [self.adTrackerRequest trackAdWithDelegate:self withURL:[url absoluteString]];
}

- (void)didFailWithURL:(NSURL *)url andError:(NSError *)error {
    
}

@end
