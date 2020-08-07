//
//  MPFullscreenAdViewController+Web.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdViewController+Private.h"
#import "MPFullscreenAdViewController+Web.h"
#import "UIView+MPAdditions.h"

@interface MPFullscreenAdViewController (MPAdContainerViewWebAdDelegate) <MPAdContainerViewWebAdDelegate>
@end

#pragma mark -

@interface MPFullscreenAdViewController (MPAdWebViewAgentDelegate) <MPAdWebViewAgentDelegate>
@end

#pragma mark -

@implementation MPFullscreenAdViewController (Web)

- (MPAdWebViewAgent *)webViewAgent {
    if (self._webViewAgent == nil) {
        self._webViewAgent = [[MPAdWebViewAgent alloc] initWithAdWebViewFrame:self.view.bounds delegate:self];
    }
    return self._webViewAgent;
}

- (void)loadConfigurationForWebAd:(MPAdConfiguration *)configuration {
    [self view]; // app crashes if `view` is not available when `webViewAgent` tries to load
    [self.webViewAgent loadConfiguration:configuration];
    self.webView = self.webViewAgent.view;
    self.webView.frame = self.view.bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    self.adContainerView = [[MPAdContainerView alloc] initWithFrame:self.view.bounds webContentView:self.webView];
    self.adContainerView.webAdDelegate = self;
    self.adContainerView.countdownTimerDelegate = self;
    [self.view addSubview:self.adContainerView];
    self.adContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:
    @[[self.adContainerView.mp_safeTopAnchor constraintEqualToAnchor:self.view.mp_safeTopAnchor],
      [self.adContainerView.mp_safeLeadingAnchor constraintEqualToAnchor:self.view.mp_safeLeadingAnchor],
      [self.adContainerView.mp_safeBottomAnchor constraintEqualToAnchor:self.view.mp_safeBottomAnchor],
      [self.adContainerView.mp_safeTrailingAnchor constraintEqualToAnchor:self.view.mp_safeTrailingAnchor]]];
    
    for (UIView *view in self.adContainerView.viewabilityFriendlyObstructionViews) {
        [self.webViewAgent.viewabilityTracker registerFriendlyObstructionView:view];
    }
}

#pragma mark - View Controller Life Cycle for Web Ads

- (void)willPresentFullscreenWebAd {
    self.webView.alpha = 0.0;
}

- (void)didPresentFullscreenWebAd {
    [UIView animateWithDuration:0.3 animations:^{
        self.webView.alpha = 1;
    }];
}

- (void)willDismissFullscreenWebAd {
    [self.webViewAgent disableRequestHandling];
}

- (void)didDismissFullscreenWebAd {
    // no op
}

#pragma mark - View Life Cycle for Web Ads

- (void)fullscreenWebAdWillAppear {
    [self.webViewAgent enableRequestHandling];
    [self.webViewAgent invokeJavaScriptForEvent:MPAdWebViewEventAdDidAppear];
}

- (void)fullscreenWebAdDidAppear {
    // no op
}

- (void)fullscreenWebAdWillDisappear {
    [self.webViewAgent disableRequestHandling];
}

- (void)fullscreenWebAdDidDisappear {
    [self.webViewAgent invokeJavaScriptForEvent:MPAdWebViewEventAdDidDisappear];
}

@end

#pragma mark -

@implementation MPFullscreenAdViewController (MPAdContainerViewWebAdDelegate)

- (void)adContainerViewDidHitCloseButton:(MPAdContainerView *)adContainerView {
    [self dismiss];
}

@end

#pragma mark -

@implementation MPFullscreenAdViewController (MPAdWebViewAgentDelegate)

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adActionDidFinish:(MPWebView *)ad {
    //NOOP: the landing page is going away, but not the interstitial.
}

- (void)adActionWillBegin:(MPWebView *)ad {
    // no op
}

- (void)adActionWillLeaveApplication:(MPWebView *)ad {
    [self.webAdDelegate fullscreenWebAdWillLeaveApplication:self];
    [self dismiss];
}

- (void)adDidClose:(MPWebView *)ad {
    //NOOP: the ad is going away, but not the interstitial.
}

- (void)adDidFailToLoadAd:(MPWebView *)ad {
    [self.webAdDelegate fullscreenWebAdDidFailToLoad:self];
}

- (void)adDidFinishLoadingAd:(MPWebView *)ad {
    [self.webAdDelegate fullscreenWebAdDidLoad:self];
}

- (void)adWebViewAgentDidReceiveTap:(MPAdWebViewAgent *)aAdWebViewAgent {
    [self.webAdDelegate fullscreenWebAdDidReceiveTap:self];
}

@end
