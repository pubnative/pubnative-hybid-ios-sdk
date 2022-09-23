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

#import "PNLiteInterstitialPresenterDecorator.h"
#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"
#import <StoreKit/SKOverlay.h>
#import <StoreKit/SKOverlayConfiguration.h>
#import "UIApplication+PNLiteTopViewController.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteInterstitialPresenterDecorator() <SKOverlayDelegate>

@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic) NSObject<HyBidInterstitialPresenterDelegate> *interstitialPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) SKOverlay *overlay API_AVAILABLE(ios(14.0));
@property (nonatomic, assign) BOOL isOverlayShown;

@end

@implementation PNLiteInterstitialPresenterDecorator

- (void)dealloc {
    self.interstitialPresenter = nil;
    self.adTracker = nil;
    self.interstitialPresenterDelegate = nil;
    self.errorReportingProperties = nil;
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            self.overlay = nil;
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }
}

- (void)load {
    [self.interstitialPresenter load];
}

- (void)show {
    [self.interstitialPresenter show];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [self.interstitialPresenter showFromViewController:viewController];
}

- (void)hide {
    [self.interstitialPresenter hide];
}

- (instancetype)initWithInterstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidInterstitialPresenterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.interstitialPresenter = interstitialPresenter;
        self.adTracker = adTracker;
        self.interstitialPresenterDelegate = delegate;
        self.errorReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary withInterstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter {
    if ([HyBidSettings sharedInstance].appToken != nil && [HyBidSettings sharedInstance].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSettings sharedInstance].appToken forKey:HyBidReportingCommon.APPTOKEN];
    }
    if (interstitialPresenter.ad.zoneID != nil && interstitialPresenter.ad.zoneID.length > 0) {
        [reportingDictionary setObject:interstitialPresenter.ad.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if (interstitialPresenter.ad.assetGroupID) {
        switch (interstitialPresenter.ad.assetGroupID.integerValue) {
            case VAST_INTERSTITIAL: {
                [reportingDictionary setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
                
                NSString *vast = interstitialPresenter.ad.isUsingOpenRTB
                ? interstitialPresenter.ad.openRtbVast
                : interstitialPresenter.ad.vast;
                if (vast) {
                    [reportingDictionary setObject:vast forKey:HyBidReportingCommon.CREATIVE];
                }
                break;
            }
            default:
                [reportingDictionary setObject:@"HTML" forKey:HyBidReportingCommon.AD_TYPE];
                if (interstitialPresenter.ad.htmlData) {
                    [reportingDictionary setObject:interstitialPresenter.ad.htmlData forKey:HyBidReportingCommon.CREATIVE];
                }
                break;
        }
    }
}

- (void)presentSKOverlay {
    if ([HyBidSettings sharedInstance].interstitialSKOverlay) {
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
    if ([HyBidSettings sharedInstance].interstitialSKOverlay) {
        if (@available(iOS 14.0, *)) {
            if (self.overlay) {
                [SKOverlay dismissOverlayInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
        }
    }
}

#pragma mark HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidLoad:)]) {
        [self.interstitialPresenterDelegate interstitialPresenterDidLoad:interstitialPresenter];
        if ([HyBidSettings sharedInstance].interstitialSKOverlay) {
            if (@available(iOS 14.0, *)) {
                HyBidSkAdNetworkModel* skAdNetworkModel = interstitialPresenter.ad.isUsingOpenRTB ? [interstitialPresenter.ad getOpenRTBSkAdNetworkModel] : [interstitialPresenter.ad getSkAdNetworkModel];
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

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidShow:)]) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
        [self.interstitialPresenterDelegate interstitialPresenterDidShow:interstitialPresenter];
        [self presentSKOverlay];
    }
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidClick:)]) {
        [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.FULLSCREEN];
        [self.interstitialPresenterDelegate interstitialPresenterDidClick:interstitialPresenter];
    }
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenterDidDismiss:)]) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.INTERSTITIAL_CLOSED adFormat:HyBidReportingAdFormat.FULLSCREEN properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.interstitialPresenterDelegate interstitialPresenterDidDismiss:interstitialPresenter];
        [self dismissSKOverlay];
    }
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    if (self.interstitialPresenterDelegate && [self.interstitialPresenterDelegate respondsToSelector:@selector(interstitialPresenter:didFailWithError:)]) {
        if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
            [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        }
        [self addCommonPropertiesToReportingDictionary:self.errorReportingProperties withInterstitialPresenter:interstitialPresenter];
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.FULLSCREEN properties:self.errorReportingProperties];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.interstitialPresenterDelegate interstitialPresenter:interstitialPresenter didFailWithError:error];
    }
}

- (void)interstitialPresenterDidAppear:(HyBidInterstitialPresenter *)interstitialPresenter {
    
}

- (void)interstitialPresenterDidDisappear:(HyBidInterstitialPresenter *)interstitialPresenter {
    
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

@end
