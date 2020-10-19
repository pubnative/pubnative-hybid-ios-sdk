//
//  HyBidRewardedPresenterFactory.m
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "HyBidRewardedPresenterFactory.h"
#import "PNLiteAssetGroupType.h"
#import "PNLiteRewardedPresenterDecorator.h"
#import "PNLiteVASTRewardedPresenter.h"
#import "HyBidAdTracker.h"
#import "HyBidLogger.h"

@implementation HyBidRewardedPresenterFactory

- (HyBidRewardedPresenter *)createRewardedPresenterWithAd:(HyBidAd *)ad
                                                    withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate {
    HyBidRewardedPresenter *rewardedPresenter = [self createRewardedPresenterFromAd:ad];
    if (!rewardedPresenter) {
        return nil;
    }
    PNLiteRewardedPresenterDecorator *rewardedPresenterDecorator = [[PNLiteRewardedPresenterDecorator alloc] initWithRewardedPresenter:rewardedPresenter
                                                                                                                                         withAdTracker:[[HyBidAdTracker alloc] initWithImpressionURLs:[ad beaconsDataWithType:PNLiteAdTrackerImpression] withClickURLs:[ad beaconsDataWithType:PNLiteAdTrackerClick]]
                                                                                                                                          withDelegate:delegate];
    rewardedPresenter.delegate = rewardedPresenterDecorator;
    return rewardedPresenterDecorator;
}

- (HyBidRewardedPresenter *)createRewardedPresenterFromAd:(HyBidAd *)ad {
    switch (ad.assetGroupID.integerValue) {
        case VAST_REWARDED: {
            PNLiteVASTRewardedPresenter *vastRewardedPresenter = [[PNLiteVASTRewardedPresenter alloc] initWithAd:ad];
            return vastRewardedPresenter;
        }
        default:
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Asset Group %@ is an incompatible Asset Group ID for Rewarded ad format.", ad.assetGroupID]];
            return nil;
            break;
    }
}

@end
