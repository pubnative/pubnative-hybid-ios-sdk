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

#import "PNLiteRewardedPresenterDecorator.h"
#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"
#import "PNLiteAssetGroupType.h"
#import <StoreKit/SKOverlay.h>
#import <StoreKit/SKOverlayConfiguration.h>
#import "UIApplication+PNLiteTopViewController.h"

@interface PNLiteRewardedPresenterDecorator() <SKOverlayDelegate>

@property (nonatomic, strong) HyBidRewardedPresenter *rewardedPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, weak) NSObject<HyBidRewardedPresenterDelegate> *rewardedPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) SKOverlay *overlay API_AVAILABLE(ios(14.0));
@property (nonatomic, assign) BOOL isOverlayShown;

@end

@implementation PNLiteRewardedPresenterDecorator

- (void)dealloc {
    self.rewardedPresenter = nil;
    self.adTracker = nil;
    self.rewardedPresenterDelegate = nil;
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
    [self.rewardedPresenter load];
}

- (void)show {
    [self.rewardedPresenter show];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [self.rewardedPresenter showFromViewController:viewController];
}

- (void)hide {
    [self.rewardedPresenter hide];
}

- (instancetype)initWithRewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.rewardedPresenter = rewardedPresenter;
        self.adTracker = adTracker;
        self.rewardedPresenterDelegate = delegate;
        self.errorReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary withRewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter {
    if ([HyBidSettings sharedInstance].appToken != nil && [HyBidSettings sharedInstance].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSettings sharedInstance].appToken forKey:HyBidReportingCommon.APPTOKEN];
    }
    if (rewardedPresenter.ad.zoneID != nil && rewardedPresenter.ad.zoneID.length > 0) {
        [reportingDictionary setObject:rewardedPresenter.ad.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    switch (rewardedPresenter.ad.assetGroupID.integerValue) {
        case VAST_INTERSTITIAL:
            [reportingDictionary setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
            if (rewardedPresenter.ad.vast) {
                [reportingDictionary setObject:rewardedPresenter.ad.vast forKey:HyBidReportingCommon.CREATIVE];
            }
            break;
        default:
            [reportingDictionary setObject:@"HTML" forKey:HyBidReportingCommon.AD_TYPE];
            if (rewardedPresenter.ad.htmlData) {
                [reportingDictionary setObject:rewardedPresenter.ad.htmlData forKey:HyBidReportingCommon.CREATIVE];
            }
            break;
    }
}

- (void)presentSKOverlay {
    if ([HyBidSettings sharedInstance].rewardedSKOverlay) {
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
    if ([HyBidSettings sharedInstance].rewardedSKOverlay) {
        if (@available(iOS 14.0, *)) {
            if (self.overlay) {
                [SKOverlay dismissOverlayInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
        }
    }
}

#pragma mark HyBidRewardedPresenterDelegate

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidLoad:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidLoad:rewardedPresenter];
        if ([HyBidSettings sharedInstance].rewardedSKOverlay) {
            if (@available(iOS 14.0, *)) {
                HyBidSkAdNetworkModel* skAdNetworkModel = rewardedPresenter.ad.isUsingOpenRTB ? [rewardedPresenter.ad getOpenRTBSkAdNetworkModel] : [rewardedPresenter.ad getSkAdNetworkModel];
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

- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidShow:)]) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.REWARDED];
        [self.rewardedPresenterDelegate rewardedPresenterDidShow:rewardedPresenter];
        [self presentSKOverlay];
    }
}

- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidClick:)]) {
        [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
        [self.rewardedPresenterDelegate rewardedPresenterDidClick:rewardedPresenter];
    }
}

- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidDismiss:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidDismiss:rewardedPresenter];
        [self dismissSKOverlay];
    }
}

- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter
{
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidFinish:)]) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.VIDEO_FINISHED adFormat:HyBidReportingAdFormat.REWARDED properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.rewardedPresenterDelegate rewardedPresenterDidFinish:rewardedPresenter];
    }
}

- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter didFailWithError:(NSError *)error {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenter:didFailWithError:)]) {
        if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
            [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        }
        [self addCommonPropertiesToReportingDictionary:self.errorReportingProperties withRewardedPresenter:rewardedPresenter];
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.REWARDED properties:self.errorReportingProperties];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.rewardedPresenterDelegate rewardedPresenter:rewardedPresenter didFailWithError:error];
    }
}

- (void)rewardedPresenterDidAppear:(HyBidRewardedPresenter *)rewardedPresenter {
    [self presentSKOverlay];
}

- (void)rewardedPresenterDidDisappear:(HyBidRewardedPresenter *)rewardedPresenter {
    [self dismissSKOverlay];
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
