// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"
#import "HyBidCustomCTAViewDelegate.h"
#import "HyBidSKOverlay.h"
#import "HyBidSKOverlayDelegate.h"

@class HyBidRewardedPresenter;
@class HyBidAdSessionData;

@protocol HyBidRewardedPresenterDelegate<NSObject>

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
             didFailWithError:(NSError *)error;

@optional
- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter viewController:(UIViewController *)viewController;
- (void)rewardedPresenterDidAppear:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidDisappear:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDismissesSKOverlay:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDismissesCustomCTA:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenteWillPresentEndCard:(HyBidRewardedPresenter *)rewardedPresenter
                         skoverlayDelegate:(id<HyBidSKOverlayDelegate>)skoverlayDelegate
                         customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate;
- (void)rewardedPresenteDidPresentCustomEndCard:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidPresentsCustomCTA;
- (void)rewardedPresenterDidClickCustomCTAOnEndCard:(BOOL)OnEndCard;
- (void)rewardedPresenterDidPresentCustomEndCard:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidSKOverlayAutomaticClick:(HyBidRewardedPresenter *)rewardedPresenter
                                              clickType:(HyBidSKOverlayAutomaticCLickType)clickType;
- (void)rewardedPresenterDidStorekitAutomaticClick:(HyBidRewardedPresenter *)rewardedPresenter
                                              clickType:(HyBidStorekitAutomaticClickType)clickType;
- (void)rewardedPresenterDidReplay:(HyBidRewardedPresenter *)rewardedPresenter viewController:(UIViewController *)viewController;

@end

@interface HyBidRewardedPresenter : NSObject

@property (nonatomic, readonly) HyBidAd *ad;
@property (nonatomic) NSObject <HyBidRewardedPresenterDelegate> *delegate;
@property (nonatomic) NSObject <HyBidCustomCTAViewDelegate> *customCTADelegate;
@property (nonatomic) NSObject <HyBidSKOverlayDelegate> *skoverlayDelegate;
@property (nonatomic, strong) HyBidAdSessionData *adSessionData;

- (void)load;

/// Presents the rewarded ad modally from the current view controller.
- (void)show;

/**
 * Presents the rewarded ad modally from the specified view controller.
 *
 * @param viewController The view controller that should be used to present the rewarded ad.
 */
- (void)showFromViewController:(UIViewController *)viewController;
- (void)hideFromViewController:(UIViewController *)viewController;

@end
