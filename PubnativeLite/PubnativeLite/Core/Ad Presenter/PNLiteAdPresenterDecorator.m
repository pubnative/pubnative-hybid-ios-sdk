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
#import <StoreKit/SKOverlay.h>
#import <StoreKit/SKOverlayConfiguration.h>
#import "UIApplication+PNLiteTopViewController.h"
#import "PNLiteImpressionTracker.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteAdPresenterDecorator () <SKOverlayDelegate, PNLiteImpressionTrackerDelegate>

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, weak) NSObject<HyBidAdPresenterDelegate> *adPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) SKOverlay *overlay API_AVAILABLE(ios(14.0));
@property (nonatomic, assign) BOOL isOverlayShown;
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
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            self.overlay = nil;
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }}

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
    [self dismissSKOverlay];
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
    if ([HyBidSettings sharedInstance].appToken != nil && [HyBidSettings sharedInstance].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSettings sharedInstance].appToken forKey:HyBidReportingCommon.APPTOKEN];
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

- (void)presentSKOverlay {
    if ([HyBidSettings sharedInstance].bannerSKOverlay) {
        if (@available(iOS 14.0, *)) {
            if (self.overlay) {
                if (!self.isOverlayShown) {
                    [self.overlay presentInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
                }
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
        }
    }
}

- (void)dismissSKOverlay {
    NSString *previousBannerPresenterDecoratorDescription = [NSUserDefaults.standardUserDefaults stringForKey:kUserDefaultsHyBidPreviousBannerPresenterDecoratorKey];
    if ([HyBidSettings sharedInstance].bannerSKOverlay) {
        if (@available(iOS 14.0, *)) {
            if ([previousBannerPresenterDecoratorDescription isEqualToString:self.description]) {
                if (self.overlay) {
                    [SKOverlay dismissOverlayInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
                }
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
        }
    }
}

#pragma mark HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    self.trackedView = adView;
    if(!self.impressionTracker) {
        self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
        self.impressionTracker.delegate = self;
    }
    if (self.trackedView) {
        [self.impressionTracker addView:self.trackedView];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression could not be fired - Tracked view not available"];
    }
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenter:didLoadWithAd:)]) {
        [self.adPresenterDelegate adPresenter:adPresenter didLoadWithAd:adView];
        if ([HyBidSettings sharedInstance].bannerSKOverlay) {
            if (@available(iOS 14.0, *)) {
                HyBidSkAdNetworkModel* skAdNetworkModel = adPresenter.ad.isUsingOpenRTB ? [adPresenter.ad getOpenRTBSkAdNetworkModel] : [adPresenter.ad getSkAdNetworkModel];
                NSString *appIdentifier = [skAdNetworkModel.productParameters objectForKey:@"itunesitem"];
                if (appIdentifier && appIdentifier.length > 0) {
                    SKOverlayAppConfiguration *configuration = [[SKOverlayAppConfiguration alloc]
                                                                initWithAppIdentifier:appIdentifier
                                                                position:SKOverlayPositionBottom];
                    configuration.userDismissible = YES;
                    self.overlay = [[SKOverlay alloc] initWithConfiguration:configuration];
                    self.overlay.delegate = self;
                }
            } else {
                [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
            }
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
        [self addCommonPropertiesToReportingDictionary:self.errorReportingProperties withAdPresenter:adPresenter];
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.BANNER properties:self.errorReportingProperties];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.adPresenterDelegate adPresenter:adPresenter didFailWithError:error];
    }
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter {
    self.videoStarted = YES;
    if (!self.videoStarted || !self.impressionConfirmed) {return;}
    if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] && !self.adTracker.impressionTracked) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
    }
}

- (void)adPresenterDidAppear:(HyBidAdPresenter *)adPresenter {
    
}

- (void)adPresenterDidDisappear:(HyBidAdPresenter *)adPresenter {
    
}

#pragma mark SKOverlayDelegate

- (void)storeOverlay:(SKOverlay *)overlay willStartPresentation:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){}
- (void)storeOverlay:(SKOverlay *)overlay didFinishPresentation:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    if ([overlay isEqual:self.overlay]) {
        self.isOverlayShown = YES;
    }
}
- (void)storeOverlay:(SKOverlay *)overlay willStartDismissal:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){}
- (void)storeOverlay:(SKOverlay *)overlay didFinishDismissal:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    if ([overlay isEqual:self.overlay]) {
        self.isOverlayShown = NO;
    }
}
- (void)storeOverlay:(SKOverlay *)overlay didFailToLoadWithError:(NSError *)error  API_AVAILABLE(ios(14.0)){}

#pragma mark PNLiteImpressionTrackerDelegate

- (void)impressionDetectedWithView:(UIView *)view {
    if (self.adPresenter.ad.adType != kHyBidAdTypeVideo && !self.adTracker.impressionTracked) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentSKOverlay];
        });
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.BANNER];
        [self.adPresenterDelegate adPresenterDidStartPlaying:self.adPresenter];
    } else {
        self.impressionConfirmed = YES;
        if (self.adPresenterDelegate && [self.adPresenterDelegate respondsToSelector:@selector(adPresenterDidStartPlaying:)] && !self.adTracker.impressionTracked) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.adPresenter startTracking];
                [self presentSKOverlay];
            });
        }
    }
}

@end
