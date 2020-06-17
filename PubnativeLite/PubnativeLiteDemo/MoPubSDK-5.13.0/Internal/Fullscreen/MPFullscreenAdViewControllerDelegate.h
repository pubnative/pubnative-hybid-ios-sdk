//
//  MPFullscreenAdViewControllerDelegate.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPFullscreenAdViewController;

#pragma mark -

/**
 Note: Appear and Disappear events might happen multiple times if a view controller such as a web
 browser view controller is presented on top, and disappearing is not the same as dismissing.
 */
@protocol MPFullscreenAdViewControllerAppearanceDelegate <NSObject>
    
- (void)fullscreenAdWillAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdDidAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdWillDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdDidDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdWillDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdDidDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController;

@end

#pragma mark -

@protocol MPFullscreenAdViewControllerWebAdDelegate <NSObject>

- (void)fullscreenWebAdDidLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenWebAdDidFailToLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenWebAdDidReceiveTap:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenWebAdWillLeaveApplication:(id<MPFullscreenAdViewController>)fullscreenAdViewController;

@optional

- (void)fullscreenWebAdDidFulfillRewardRequirement:(id<MPFullscreenAdViewController>)fullscreenAdViewController;

@end

NS_ASSUME_NONNULL_END
