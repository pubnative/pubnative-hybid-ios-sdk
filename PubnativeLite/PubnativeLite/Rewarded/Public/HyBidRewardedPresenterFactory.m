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
#import "PNLiteRewardedPresenterDecorator.h"
#import "PNLiteVASTRewardedPresenter.h"
#import "HyBidMRAIDRewardedPresenter.h"
#import "HyBidAdTracker.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidRewardedPresenterFactory

- (HyBidRewardedPresenter *)createRewardedPresenterWithAd:(HyBidAd *)ad
                                       withHTMLSkipOffset:(NSUInteger)htmlSkipOffset
                                        withCloseOnFinish:(BOOL)closeOnFinish
                                             withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate {
    HyBidRewardedPresenter *rewardedPresenter = [self createRewardedPresenterFromAd:ad
                                                                 withHTMLSkipOffset:htmlSkipOffset
                                                                  withCloseOnFinish:closeOnFinish];
    if (!rewardedPresenter) {
        return nil;
    }
    
    NSArray *impressionBeacons = [ad beaconsDataWithType:PNLiteAdTrackerImpression];
    NSArray *customEndcardImpressionBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardImpression];
    NSArray *clickBeacons = [ad beaconsDataWithType:PNLiteAdTrackerClick];
    NSArray *customEndcardClickBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardClick];

    HyBidAdTracker *adTracker = [[HyBidAdTracker alloc] initWithImpressionURLs:impressionBeacons withCustomEndcardImpressionURLs:customEndcardImpressionBeacons withClickURLs:clickBeacons withCustomEndcardClickURLs:customEndcardClickBeacons forAd:ad];
    
    PNLiteRewardedPresenterDecorator *rewardedPresenterDecorator = [[PNLiteRewardedPresenterDecorator alloc] initWithRewardedPresenter:rewardedPresenter
                                                                                                                                         withAdTracker: adTracker
                                                                                                                                          withDelegate:delegate];
    rewardedPresenter.delegate = rewardedPresenterDecorator;
    return rewardedPresenterDecorator;
}

- (HyBidRewardedPresenter *)createRewardedPresenterFromAd:(HyBidAd *)ad
                                       withHTMLSkipOffset:(NSInteger)htmlSkipOffset
                                        withCloseOnFinish:(BOOL)closeOnFinish {
    NSNumber *adAssetGroupID = ad.isUsingOpenRTB ? ad.openRTBAssetGroupID : ad.assetGroupID;
    switch (adAssetGroupID.integerValue) {
        case MRAID_300x600:
        case MRAID_320x480:
        case MRAID_480x320:
        case MRAID_1024x768:
        case MRAID_768x1024:{
            HyBidMRAIDRewardedPresenter *mraidRewardedPresenter = [[HyBidMRAIDRewardedPresenter alloc] initWithAd:ad withSkipOffset:htmlSkipOffset];
            return mraidRewardedPresenter;
        }
        case VAST_REWARDED: {
            PNLiteVASTRewardedPresenter *vastRewardedPresenter = [[PNLiteVASTRewardedPresenter alloc] initWithAd:ad
                                                                                               withCloseOnFinish:closeOnFinish];
            return vastRewardedPresenter;
        }
        default:
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:[NSString stringWithFormat:@"Asset Group %@ is an incompatible Asset Group ID for Rewarded ad format.", ad.assetGroupID]];
            return nil;
            break;
    }
}

@end
