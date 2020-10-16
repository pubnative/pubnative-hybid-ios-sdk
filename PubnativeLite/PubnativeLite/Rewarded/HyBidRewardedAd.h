//
//  HyBidRewardedAd.h
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"
#import "HyBidSignalDataProcessor.h"

@protocol HyBidRewardedAdDelegate<NSObject>

- (void)rewardedDidLoad;
- (void)rewardedDidFailWithError:(NSError *)error;
- (void)rewardedDidTrackImpression;
- (void)rewardedDidTrackClick;
- (void)rewardedDidDismiss;

@end

@interface HyBidRewardedAd: NSObject <HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isMediation;

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate;
- (instancetype)initWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate;
- (void)load;
- (void)prepareAdWithContent:(NSString *)adContent;

/**
 Presents the rewarded ad modally from the current view controller.
 This method will do nothing if the rewarded ad has not been loaded (i.e. the value of its `isReady` property is NO).
 */
- (void)show;

/**
* Presents the rewarded ad modally from the specified view controller.
*
* This method will do nothing if the rewarded ad has not been loaded (i.e. the value of its
* `isReady` property is NO).
*
* @param viewController The view controller that should be used to present the rewarded ad.
*/
- (void)showFromViewController:(UIViewController *)viewController;
- (void)hide;

@end
