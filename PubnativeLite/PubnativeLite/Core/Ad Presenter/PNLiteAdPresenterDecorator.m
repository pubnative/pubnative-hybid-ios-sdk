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

#import "PNLiteAdPresenterDecorator.h"
#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"
#import "PNLiteImpressionTracker.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteAdPresenterDecorator () <PNLiteImpressionTrackerDelegate>

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, weak) NSObject<HyBidAdPresenterDelegate> *adPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) PNLiteImpressionTracker *impressionTracker;
@property (nonatomic, strong) UIView *trackedView;
@property (nonatomic, assign) BOOL videoStarted;
@property (nonatomic, assign) BOOL impressionConfirmed;

@end

NSString * const kUserDefaultsHyBidPreviousBannerPresenterDecoratorKey = @"kUserDefaultsHyBidPreviousBannerPresenterDecorator";

@implementation PNLiteAdPresenterDecorator

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] setValue:self.description forKeyPath:kUserDefaultsHyBidPreviousBannerPresenterDecoratorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self stopTracking];
    self.adPresenter = nil;
    self.adTracker = nil;
    self.adPresenterDelegate = nil;
    self.errorReportingProperties = nil;
    if (self.impressionTracker) {
        [self.impressionTracker clear];
    }
    self.impressionTracker = nil;
    self.trackedView = nil;
    self.videoStarted = NO;
    self.impressionConfirmed = NO;
}

- (void)load {
    [self.adPresenter load];
}

- (void)loadMarkupWithSize:(HyBidAdSize *)adSize {
    [self.adPresenter loadMarkupWithSize:adSize];
}

- (void)startTracking {
    if(self.adPresenter.ad.adType != kHyBidAdTypeVideo) {
        [self.adPresenter startTracking];
    }
}

- (void)stopTracking {
    if (self.impressionTracker) {
        [self.impressionTracker clear];
    }
    self.impressionTracker = nil;
    
    [self.adPresenter stopTracking];
}

- (instancetype)initWithAdPresenter:(HyBidAdPresenter *)adPresenter
                      withAdTracker:(HyBidAdTracker *)adTracker
                       withDelegate:(NSObject<HyBidAdPresenterDelegate> *)delegate{
    self = [super init];
    if (self) {
        self.adPresenter = adPresenter;
        self.adTracker = adTracker;
        self.adPresenterDelegate = delegate;
        self.errorReportingProperties = [NSMutableDictionary new];
        self.videoStarted = NO;
        self.impressionConfirmed = NO;
    }
    return self;
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary withAdPresenter:(HyBidAdPresenter *)adPresenter {
    if ([HyBidSDKConfig sharedConfig].appToken != nil && [HyBidSDKConfig sharedConfig].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSDKConfig sharedConfig].appToken forKey:HyBidReportingCommon.APPTOKEN];
    }
    if (adPresenter.ad.zoneID != nil && adPresenter.ad.zoneID.length > 0) {
        [reportingDictionary setObject:adPresenter.ad.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if (adPresenter.ad.assetGroupID) {
        switch (adPresenter.ad.assetGroupID.integerValue) {
            case VAST_MRECT: {
                [reportingDictionary setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
                NSString *vast = adPresenter.ad.isUsingOpenRTB
                ? adPresenter.ad.openRtbVast
                : adPresenter.ad.vast;
                if (vast) {
                    [reportingDictionary setObject:vast forKey:HyBidReportingCommon.CREATIVE];
                }
                break;
            }
            default:
                [reportingDictionary setObject:@"HTML" forKey:HyBidReportingCommon.AD_TYPE];
                if (adPresenter.ad.htmlData) {
                    [reportingDictionary setObject:adPresenter.ad.htmlData forKey:HyBidReportingCommon.CREATIVE];
                }
                break;
        }
    }
}

#pragma mark HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    self.trackedView = adView;
    if(!self.impressionTracker) {
        self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
        [self.impressionTracker determineViewbilityRemoteConfig:self.adPresenter.ad];
        self.impressionTracker.delegate = self;
    }
    if (self.trackedView) {
        if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerViewable) {
            [self.impressionTracker addView:self.trackedView];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression could not be fired - Tracked view not available"];
    }
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenter:didLoadWithAd:)]) {
        [self.adPresenterDelegate adPresenter:adPresenter didLoadWithAd:adView];
        if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerRender) {
            [self impressionDetectedWithView:self.trackedView];
        }
    }
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidClick:)]) {
        [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.BANNER];
        [self.adPresenterDelegate adPresenterDidClick:adPresenter];
    }
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenter:didFailWithError:)]) {
        if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
            [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        }
        if(self.errorReportingProperties) {
            [self addCommonPropertiesToReportingDictionary:self.errorReportingProperties withAdPresenter:adPresenter];
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.BANNER properties:self.errorReportingProperties];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
        [self.adPresenterDelegate adPresenter:adPresenter didFailWithError:error];
    }
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter {
    self.videoStarted = YES;
    if (!self.videoStarted || !self.impressionConfirmed) {return;}
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] && !self.adTracker.impressionTracked && self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerViewable) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
    }
}

- (void)adPresenterDidAppear:(HyBidAdPresenter *)adPresenter {
    // in case impressionTrackingMethod is render, we trigger adPresenterDidStartPlaying which will fire impression.
    if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerRender && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] ) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
    }
}

- (void)adPresenterDidDisappear:(HyBidAdPresenter *)adPresenter {
    
}

#pragma mark PNLiteImpressionTrackerDelegate

- (void)impressionDetectedWithView:(UIView *)view {
    if (self.adPresenter.ad.adType != kHyBidAdTypeVideo && !self.adTracker.impressionTracked) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        if ([self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] ) {
            [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
        }
    } else {
        self.impressionConfirmed = YES;
        if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] && !self.adTracker.impressionTracked) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.adPresenter startTracking];
            });
        }
    }
}

@end
