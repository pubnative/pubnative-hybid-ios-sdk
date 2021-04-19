//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
        case VAST_INTERSTITIAL: {
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
