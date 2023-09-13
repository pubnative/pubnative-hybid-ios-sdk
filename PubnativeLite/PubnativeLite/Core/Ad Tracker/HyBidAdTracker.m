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
#import "HyBidURLDriller.h"
#import <WebKit/WebKit.h>
#import "HyBid.h"
#import "ATOMError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

NSString *const PNLiteAdTrackerClick = @"click";
NSString *const PNLiteAdTrackerImpression = @"impression";
NSString *const PNLiteAdCustomEndCardImpression = @"custom_endcard_impression";
NSString *const PNLiteAdCustomEndCardClick = @"custom_endcard_click";

@interface HyBidAdTracker() <HyBidAdTrackerRequestDelegate, HyBidURLDrillerDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) HyBidAdTrackerRequest *adTrackerRequest;
@property (nonatomic, strong) NSArray *impressionURLs;
@property (nonatomic, strong) NSArray *clickURLs;
@property (nonatomic, assign) BOOL clickTracked;
@property (nonatomic, assign) BOOL customEndCardClickTracked;
@property (nonatomic, assign) BOOL customEndCardImpressionTracked;
@property (nonatomic, strong) NSString *trackTypeForURL;
@property (nonatomic, assign) BOOL urlDrillerEnabled;

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSArray<NSString *>*> *trackedURLsDictionary;

@end

@implementation HyBidAdTracker

- (void)dealloc {
    self.adTrackerRequest = nil;
    self.impressionURLs = nil;
    self.clickURLs = nil;
    self.wkWebView = nil;
    self.trackTypeForURL = nil;
    self.ad = nil;
    self.trackedURLsDictionary = nil;
}

- (instancetype)initWithImpressionURLs:(NSArray *)impressionURLs
                         withClickURLs:(NSArray *)clickURLs
                                 forAd:(HyBidAd *)ad {
    self.trackedURLsDictionary = [NSMutableDictionary new];
    self.ad = ad;
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

- (void)trackCustomEndCardImpressionWithAdFormat:(NSString *)adFormat {
    if (self.customEndCardImpressionTracked) {
        return;
    }
    
    [self trackURLs:self.impressionURLs withTrackType:PNLiteAdCustomEndCardImpression];
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CUSTOM_ENDCARD_IMPRESSION adFormat:adFormat properties:nil];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
    self.customEndCardImpressionTracked = YES;
}

- (void)trackCustomEndCardClickWithAdFormat:(NSString *)adFormat {
    if (self.customEndCardClickTracked) {
        return;
    }
    
    [self trackURLs:self.clickURLs withTrackType:PNLiteAdCustomEndCardClick];
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CUSTOM_ENDCARD_CLICK adFormat:adFormat properties:nil];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
    self.customEndCardClickTracked = YES;
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
                [self collectTrackedURLs:dataModel.url withType:trackType];
            } else if (dataModel.js != nil) {
                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking %@ with JS Beacon: %@",trackType, dataModel.js]];
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.wkWebView evaluateJavaScript:dataModel.js completionHandler:^(id _Nullable success, NSError * _Nullable error) {}];
                });
            }
        }
        
        [self sendTrackedUrlsToAtomIfNeeded];
    }
}

- (void)collectTrackedURLs:(NSString *)url withType:(NSString *)type
{
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray:self.trackedURLsDictionary[type]];
    [array addObject:url];
    
    self.trackedURLsDictionary[type] = array;
}

- (void)sendTrackedUrlsToAtomIfNeeded
{
    #if __has_include(<ATOM/ATOM-Swift.h>)
    NSString *creativeID = [self.ad creativeID];
    NSMutableArray<NSString *> *impressionURLs = [NSMutableArray new];
    NSMutableArray<NSString *> *clickURLs = [NSMutableArray new];
    
    for (NSString *key in self.trackedURLsDictionary.allKeys) {
        if ([key isEqualToString:@"impression"]) {
            [impressionURLs addObjectsFromArray:self.trackedURLsDictionary[key]];
        } else if ([key isEqualToString:@"click"]) {
            [clickURLs addObjectsFromArray:self.trackedURLsDictionary[key]];
        }
    }
    
    @try {
        Class ATOMAdParametersClass = NSClassFromString(@"ATOM.ATOMAdParameters");
        Class ATOM = NSClassFromString(@"ATOM.Atom");
        
        if (ATOMAdParametersClass == nil && ATOM != nil) {
            NSString *reason = [[NSString alloc] initWithFormat:@"ATOM Error: %d. The version of ATOM is incompatible with this HyBid. The functionality is limited. Please update to the newer version.", ATOMCannotFireImpressions];
            NSException* incompatibleException = [NSException
                    exceptionWithName:@"IncompatibleATOMVersionException"
                    reason: reason
                    userInfo:nil];
            @throw incompatibleException;
        }
        
        ATOMAdParameters *atomAdParameters = [[ATOMAdParameters alloc] initWithCreativeID:creativeID cohorts: [self.ad cohorts] impressionURLs:impressionURLs clickURL:clickURLs];
        [Atom impressionFiredWithAdParameters:atomAdParameters];
    }
    @catch (NSException *exception) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: exception.reason, NSStringFromSelector(_cmd)]];
    }
    
    [self.trackedURLsDictionary removeAllObjects];
    #endif
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
