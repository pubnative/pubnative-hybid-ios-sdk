// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"
#import "HyBidCustomCTAViewDelegate.h"
#import "HyBidSKOverlayDelegate.h"

@class HyBidInterstitialPresenter;
@class HyBidAdSessionData;

@protocol HyBidInterstitialPresenterDelegate<NSObject>

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter
             didFailWithError:(NSError *)error;

@optional
- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter viewController:(UIViewController *)viewController;
- (void)interstitialPresenterDidFinish:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidAppear:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidDisappear:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDismissesSKOverlay:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDismissesCustomCTA:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterWillPresentEndCard:(HyBidInterstitialPresenter *)interstitialPresenter
                              skoverlayDelegate:(id<HyBidSKOverlayDelegate>)skoverlayDelegate
                              customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate;
- (void)interstitialPresenterDidPresentCustomEndCard:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidPresentCustomCTA;
- (void)interstitialPresenterDidClickCustomCTAOnEndCard:(BOOL)onEndCard;
- (void)interstitialPresenterDidSKOverlayAutomaticClick:(HyBidInterstitialPresenter *)interstitialPresenter
                                              clickType:(HyBidSKOverlayAutomaticCLickType)clickType;
- (void)interstitialPresenterDidStorekitAutomaticClick:(HyBidInterstitialPresenter *)interstitialPresenter           clickType:(HyBidStorekitAutomaticClickType)clickType;
- (void)interstitialPresenterDidReplay:(HyBidInterstitialPresenter *)interstitialPresenter viewController:(UIViewController *)viewController;

@end

@interface HyBidInterstitialPresenter : NSObject

@property (nonatomic, readonly) HyBidAd *ad;
@property (nonatomic) NSObject <HyBidInterstitialPresenterDelegate> *delegate;
@property (nonatomic, weak) NSObject <HyBidCustomCTAViewDelegate> *customCTADelegate;
@property (nonatomic, weak) NSObject <HyBidSKOverlayDelegate> *skoverlayDelegate;
@property (nonatomic, strong) HyBidAdSessionData *adSessionData;

- (void)load;

/// Presents the interstitial ad modally from the current view controller.
- (void)show;

/**
 * Presents the interstitial ad modally from the specified view controller.
 *
 * @param viewController The view controller that should be used to present the interstitial ad.
 */
- (void)showFromViewController:(UIViewController *)viewController;

- (void)hideFromViewController:(UIViewController *)viewController;

@end
