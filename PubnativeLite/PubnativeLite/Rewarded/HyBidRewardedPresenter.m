//
//  HyBidRewardedPresenter.m
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "HyBidRewardedPresenter.h"

@implementation HyBidRewardedPresenter

- (void)dealloc {
    self.delegate = nil;
}

- (void)load {
    // Do nothing, this method should be overriden
}

- (void)show {
    // Do nothing, this method should be overriden
}

- (void)showFromViewController:(UIViewController *)viewController {
    // Do nothing, this method should be overriden
}

- (void)hide {
    // Do nothing, this method should be overriden
}

- (HyBidAd *)ad {
    return nil;
}

@end
