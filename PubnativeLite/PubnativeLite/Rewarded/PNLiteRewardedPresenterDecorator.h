//
//  HyBidRewardedPresenterDecorator.h
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "HyBidRewardedPresenter.h"
#import "HyBidAdTracker.h"

@interface PNLiteRewardedPresenterDecorator : HyBidRewardedPresenter <HyBidRewardedPresenterDelegate>

- (instancetype)initWithRewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate;

@end
