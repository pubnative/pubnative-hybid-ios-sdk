//
//  HyBidRewardedPresenterDecorator.m
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "PNLiteRewardedPresenterDecorator.h"

@interface PNLiteRewardedPresenterDecorator()

@property (nonatomic, strong) HyBidRewardedPresenter *rewardedPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, weak) NSObject<HyBidRewardedPresenterDelegate> *rewardedPresenterDelegate;

@end

@implementation PNLiteRewardedPresenterDecorator

- (void)dealloc {
    self.rewardedPresenter = nil;
    self.adTracker = nil;
    self.rewardedPresenterDelegate = nil;
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
    }
    return self;
}

#pragma mark HyBidRewardedPresenterDelegate

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidLoad:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidLoad:rewardedPresenter];
    }
}

- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidShow:)]) {
        [self.adTracker trackImpression];
        [self.rewardedPresenterDelegate rewardedPresenterDidShow:rewardedPresenter];
    }
}

- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidClick:)]) {
        [self.adTracker trackClick];
        [self.rewardedPresenterDelegate rewardedPresenterDidClick:rewardedPresenter];
    }
}

- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidDismiss:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidDismiss:rewardedPresenter];
    }
}

- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter
{
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidFinish:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidFinish:rewardedPresenter];
    }
}

- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter didFailWithError:(NSError *)error {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenter:didFailWithError:)]) {
        [self.rewardedPresenterDelegate rewardedPresenter:rewardedPresenter didFailWithError:error];
    }
}

@end
