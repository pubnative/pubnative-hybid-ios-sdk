//
//  PNLiteVASTPlayerRewardedViewController.m
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "PNLiteVASTPlayerRewardedViewController.h"

@interface PNLiteVASTPlayerRewardedViewController ()

@end

@implementation PNLiteVASTPlayerRewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadFullScreenPlayerWithPresenter:(HyBidInterstitialPresenter *)interstitialPresenter withAd:(HyBidAd *)ad {
//    self.presenter = interstitialPresenter;
//    self.adModel = ad;
//    self.player = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:self.adModel isInterstital:YES];
//    self.player.delegate = self;
//    if (self.adModel.zoneID != nil && self.adModel.zoneID.length > 0) {
//        self.videoAdCacheItem = [[HyBidVideoAdCache sharedInstance] retrieveVideoAdCacheItemFromCacheWithZoneID:self.adModel.zoneID];
//        if (!self.videoAdCacheItem) {
//            [self.player loadWithVastString:self.adModel.vast];
//        } else {
//            [self.player loadWithVideoAdCacheItem:self.videoAdCacheItem];
//        }
//    } else {
//        [self.player loadWithVastString:self.adModel.vast];
//    }
}

@end
