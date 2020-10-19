//
//  HyBidRewardedPresenter.h
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

@class HyBidRewardedPresenter;

@protocol HyBidRewardedPresenterDelegate<NSObject>

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
             didFailWithError:(NSError *)error;

@end

@interface HyBidRewardedPresenter : NSObject

@property (nonatomic, readonly) HyBidAd *ad;
@property (nonatomic, weak) NSObject <HyBidRewardedPresenterDelegate> *delegate;

- (void)load;

/// Presents the rewarded ad modally from the current view controller.
- (void)show;

/**
 * Presents the rewarded ad modally from the specified view controller.
 *
 * @param viewController The view controller that should be used to present the rewarded ad.
 */
- (void)showFromViewController:(UIViewController *)viewController;
- (void)hide;

@end
