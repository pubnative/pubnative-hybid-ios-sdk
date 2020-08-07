//
//  MPFullscreenAdViewController+MRAIDWeb.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdViewController+MRAIDWeb.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPLogging.h"
#import "UIView+MPAdditions.h"

@interface MPFullscreenAdViewController (MRControllerDelegate) <MRControllerDelegate>
@end

#pragma mark -

@implementation MPFullscreenAdViewController (MRAIDWeb)

- (void)loadConfigurationForMRAIDAd:(MPAdConfiguration *)configuration {
    CGFloat width = MAX(configuration.preferredSize.width, 1);
    CGFloat height = MAX(configuration.preferredSize.height, 1);
    CGRect frame = CGRectMake(0, 0, width, height);
    
    self.mraidController = [[MRController alloc] initWithAdViewFrame:frame
                                               supportedOrientations:configuration.orientationType
                                                     adPlacementType:MRAdViewPlacementTypeInterstitial
                                                            delegate:self];
    self.mraidController.countdownTimerDelegate = self;

    self.orientationType = [configuration orientationType];
    [self.mraidController loadAdWithConfiguration:configuration];
}

- (void)willPresentFullscreenMRAIDWebAd {
    [self.mraidController handleMRAIDInterstitialWillPresentWithViewController:self];
}

- (void)didPresentFullscreenMRAIDWebAd {
    // This ensures that we handle didPresentInterstitial at the end of the run loop, and prevents a bug
    // where code is run before UIKit thinks the presentViewController animation is complete, even though
    // this is is called from the completion block for said animation.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
        [self.mraidController handleMRAIDInterstitialDidPresentWithViewController:self];
    });
}

- (void)willDismissFullscreenMRAIDWebAd {
    [self.mraidController disableRequestHandling];
}

- (void)didDismissFullscreenMRAIDWebAd {
    // no op
}

#pragma mark - View Life Cycle for MRAID Web Ads

- (void)fullscreenMRAIDWebAdWillAppear {
    [self.mraidController enableRequestHandling];
}

- (void)fullscreenMRAIDWebAdDidAppear {
    // no op
}

- (void)fullscreenMRAIDWebAdWillDisappear {
    [self.mraidController disableRequestHandling];
}

- (void)fullscreenMRAIDWebAdDidDisappear {
    // no op
}

@end

#pragma mark -

@implementation MPFullscreenAdViewController (MRControllerDelegate)

#pragma mark - Required

- (UIViewController *)viewControllerForPresentingMRAIDModalView {
    return self;
}

- (void)appShouldSuspendForMRAIDAd:(MPAdContainerView *)adView {
    // no op
}

- (void)appShouldResumeFromMRAIDAd:(MPAdContainerView *)adView {
    // no op
}

#pragma mark - Optional

- (void)mraidAdDidLoad:(MPAdContainerView *)adView {
    [self.adContainerView removeFromSuperview];
    
    [self.view addSubview:adView];
    self.adContainerView = adView;
    self.adContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:
     @[[self.adContainerView.mp_safeTopAnchor constraintEqualToAnchor:self.view.mp_safeTopAnchor],
       [self.adContainerView.mp_safeLeadingAnchor constraintEqualToAnchor:self.view.mp_safeLeadingAnchor],
       [self.adContainerView.mp_safeBottomAnchor constraintEqualToAnchor:self.view.mp_safeBottomAnchor],
       [self.adContainerView.mp_safeTrailingAnchor constraintEqualToAnchor:self.view.mp_safeTrailingAnchor]]];

    [self.webAdDelegate fullscreenWebAdDidLoad:self];
}

- (void)mraidAdDidFailToLoad:(MPAdContainerView *)adView {
    [self.webAdDelegate fullscreenWebAdDidFailToLoad:self];
}

- (void)mraidAdWillClose:(MPAdContainerView *)adView {
    [self dismiss];
}

- (void)mraidAdDidClose:(MPAdContainerView *)adView {
    // no op
}

- (void)mraidAdDidReceiveClickthrough:(NSURL *)url {
    [self.webAdDelegate fullscreenWebAdDidReceiveTap:self];
}

- (void)mraidAdWillLeaveApplication {
    [self.webAdDelegate fullscreenWebAdWillLeaveApplication:self];
}

- (void)mraidAdDidFulflilRewardRequirement {
    if ([self.webAdDelegate respondsToSelector:@selector(fullscreenWebAdDidFulfillRewardRequirement:)]) {
        [self.webAdDelegate fullscreenWebAdDidFulfillRewardRequirement:self];
    }
    else {
        MPLogInfo(@"`webAdDelegate` does not response to `fullscreenWebAdDidFulfillRewardRequirement:`");
    }
}

@end
