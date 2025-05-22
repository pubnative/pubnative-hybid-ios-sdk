// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
    NSArray *clickBeacons = [ad beaconsDataWithType:PNLiteAdTrackerClick];
    
    NSArray *customEndcardImpressionBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardImpression];
    NSArray *customEndcardClickBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardClick];
    
    HyBidCustomCTATracking *customCTATracking = [[HyBidCustomCTATracking alloc] initWithAd:ad];
    
    HyBidAdTracker *adTracker = [[HyBidAdTracker alloc] initWithImpressionURLs:impressionBeacons
                                               withCustomEndcardImpressionURLs:customEndcardImpressionBeacons
                                                                 withClickURLs:clickBeacons
                                                    withCustomEndcardClickURLs:customEndcardClickBeacons
                                                         withCustomCTATracking:customCTATracking
                                                                         forAd:ad];
    
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
