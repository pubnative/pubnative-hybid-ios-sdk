// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidBannerPresenterFactory.h"
#import "PNLiteMRAIDBannerPresenter.h"
#import "HyBidVASTAdPresenter.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidBannerPresenterFactory

- (HyBidAdPresenter *)adPresenterFromAd:(HyBidAd *)ad {
    switch (ad.adType) {
        case kHyBidAdTypeHTML: {
            NSNumber *assetGroupID;
            if (ad.isUsingOpenRTB) {
                assetGroupID = ad.openRTBAssetGroupID;
            } else {
                assetGroupID = ad.assetGroupID;
            }
            
            switch ([assetGroupID intValue]) {
                case MRAID_160x600:
                case MRAID_250x250:
                case MRAID_300x50:
                case MRAID_300x250:
                case MRAID_300x600:
                case MRAID_320x50:
                case MRAID_320x100:
                case MRAID_320x480:
                case MRAID_480x320:
                case MRAID_728x90:
                case MRAID_768x1024:
                case MRAID_1024x768: {
                    PNLiteMRAIDBannerPresenter *mraidBannerPresenter = [[PNLiteMRAIDBannerPresenter alloc] initWithAd:ad];
                    return mraidBannerPresenter;
                    break;
                }
                default:
                    [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:[NSString stringWithFormat:@"Asset Group %@ is an incompatible Asset Group ID for banner ad format.", ad.assetGroupID]];
                    return nil;
                    break;
            }
        }
        case kHyBidAdTypeVideo: {
            NSNumber *assetGroupID = ad.isUsingOpenRTB
            ? ad.openRTBAssetGroupID
            : ad.assetGroupID;

            switch (assetGroupID.integerValue) {
                case VAST_MRECT: {
                    HyBidVASTAdPresenter *vastAdPresenter = [[HyBidVASTAdPresenter alloc] initWithAd:ad];
                    return vastAdPresenter;
                    break;
                }
                default:
                    [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:[NSString stringWithFormat:@"Asset Group %@ is an incompatible Asset Group ID for banner ad format.", ad.assetGroupID]];
                    return nil;
                    break;
            }
        }
        default:
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:[NSString stringWithFormat:@"Ad Type is unsupported for banner ad format."]];
            return nil;
            break;
    }
}
@end
