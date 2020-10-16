//
//  HyBidRewardedPresenterFactory.h
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HyBidRewardedPresenter.h"
#import "HyBidAd.h"

@interface HyBidRewardedPresenterFactory : NSObject

- (HyBidRewardedPresenter *)createRewardedPresenterWithAd:(HyBidAd *)ad
                                                    withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate;

@end