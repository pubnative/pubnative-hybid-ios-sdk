//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidSKOverlay.h"
#import "HyBidSKAdNetworkParameter.h"
#import "UIApplication+PNLiteTopViewController.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidSKOverlay() <SKOverlayDelegate>

@property (nonatomic, strong) SKOverlay *overlay API_AVAILABLE(ios(14.0));
@property (nonatomic, assign) BOOL isOverlayShown;

@end

@implementation HyBidSKOverlay

- (void)dealloc {
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            self.overlay = nil;
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }
}

- (instancetype)initWithAd:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        if (@available(iOS 14.0, *)) {
            HyBidSkAdNetworkModel* skAdNetworkModel = ad.isUsingOpenRTB ? [ad getOpenRTBSkAdNetworkModel] : [ad getSkAdNetworkModel];
            NSString *appIdentifier = [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.itunesitem];
            SKOverlayPosition position = SKOverlayPositionBottom;
            BOOL userDismissible = YES;
            if ([appIdentifier isKindOfClass:[NSString class]]) {
                if (appIdentifier && appIdentifier.length > 0) {
                    if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.present] && ![[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.present] boolValue]) {
                        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Parameter \"present\" is specifically set to NO, will not create SKOverlay."];
                    } else {
                        if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.dismissible]) {
                            userDismissible = [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.dismissible] boolValue];
                        }
                        if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.position]) {
                            position = [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.position] boolValue] ? SKOverlayPositionBottom : SKOverlayPositionBottomRaised;
                        }
                        SKOverlayAppConfiguration *configuration = [[SKOverlayAppConfiguration alloc]
                                                                    initWithAppIdentifier:appIdentifier
                                                                    position:position];
                        configuration.userDismissible = userDismissible;
                        self.overlay = [[SKOverlay alloc] initWithConfiguration:configuration];
                        self.overlay.delegate = self;
                    }
                } else {
                    [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Parameter \"itunesitem\" is not valid, can not create SKOverlay."];
                }
            } else {
                [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Parameter \"itunesitem\" is not valid, can not create SKOverlay."];
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
        }
    }
    return self;
}

- (void)presentWithAd:(HyBidAd *)ad {
    if (ad.skoverlayEnabled) {
        if ([ad.skoverlayEnabled boolValue]) {
            [self checkSKOverlayAvailabilityAndPresent];
        }
    } else if ([HyBidRenderingConfig sharedConfig].interstitialSKOverlay) {
        [self checkSKOverlayAvailabilityAndPresent];
    }
}

- (void)checkSKOverlayAvailabilityAndPresent {
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

- (void)dismissWithAd:(HyBidAd *)ad {
    if (ad.skoverlayEnabled) {
        if ([ad.skoverlayEnabled boolValue]) {
            [self checkSKOverlayAvailabilityAndDismiss];
        }
    } else if ([HyBidRenderingConfig sharedConfig].interstitialSKOverlay) {
        [self checkSKOverlayAvailabilityAndDismiss];
    }
}

- (void)checkSKOverlayAvailabilityAndDismiss {
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            [SKOverlay dismissOverlayInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }
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
