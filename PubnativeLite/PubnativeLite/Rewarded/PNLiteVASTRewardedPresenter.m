//
//  PNLiteVASTRewardedPresenter.m
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "PNLiteVASTRewardedPresenter.h"
#import "PNLiteVASTPlayerRewardedViewController.h"
#import "UIApplication+PNLiteTopViewController.h"

@interface PNLiteVASTRewardedPresenter()

@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerRewardedViewController *vastViewController;

@end

@implementation PNLiteVASTRewardedPresenter

- (void)dealloc {
    self.adModel = nil;
    self.vastViewController = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        self.adModel = ad;
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.vastViewController = [PNLiteVASTPlayerRewardedViewController new];
    [self.vastViewController setModalPresentationStyle: UIModalPresentationFullScreen];
    [self.vastViewController loadFullScreenPlayerWithPresenter:self withAd:self.adModel];
}

- (void)show {
    [[UIApplication sharedApplication].topViewController presentViewController:self.vastViewController animated:NO completion:nil];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [viewController presentViewController:self.vastViewController animated:NO completion:nil];
}

- (void)hide {
    [[UIApplication sharedApplication].topViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
