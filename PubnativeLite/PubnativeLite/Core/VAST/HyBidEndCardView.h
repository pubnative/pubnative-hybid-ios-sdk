// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidMRAIDView.h"
#import "HyBidEndCard.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidVASTCTAButton.h"
#import "HyBidAd.h"
#import "HyBidVASTAd.h"
#import "HyBidEndCardManager.h"
#import "HyBidSKOverlayDelegate.h"
#import "HyBidCustomCTAViewDelegate.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@protocol HyBidEndCardViewDelegate<NSObject>
@optional
- (void)endCardViewDidDisplay;
- (void)endCardViewCloseButtonTapped;
- (void)endCardViewSkipButtonTapped;
- (void)endCardViewFailedToLoad;
- (void)endCardViewClicked:(BOOL)triggerAdClick aakCustomClickAd:(HyBidAdAttributionCustomClickAdsWrapper*)aakCustomClickAd;
- (void)endCardViewSKOverlayClicked:(BOOL)triggerAdClick
                          clickType:(HyBidSKOverlayAutomaticCLickType)clickType
                isFirstPresentation:(BOOL)isFirstPresentation;
- (void)endCardViewAutoStorekitClicked:(BOOL)triggerAdClick clickType:(HyBidStorekitAutomaticClickType)clickType;
- (void)endCardViewRedirectedWithSuccess:(BOOL)success;
- (void)endCardViewCustomCTAPresented;
- (void)endCardViewCustomCTAClicked;
- (void)endCardViewReplayButtonClicked;

@end

@interface HyBidEndCardView : UIView <HyBidSKOverlayDelegate, HyBidCustomCTAViewDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
              withViewController:(UIViewController*)viewController
                          withAd:(HyBidAd *)ad
                      withVASTAd:(HyBidVASTAd *)vastAd
                  isInterstitial:(BOOL)isInterstitial
                   iconXposition:(NSString *)iconXposition
                   iconYposition:(NSString *)iconYposition
                  withSkipButton:(BOOL)withSkipButton
          vastCompanionsClicksThrough:(NSArray<NSString *>*)vastCompanionsClicksThrough
    vastCompanionsClicksTracking:(NSArray<NSString *>*)vastCompanionsClicksTracking
         vastVideoClicksTracking:(NSArray<NSString *>*)vastVideoClicksTracking;
- (void)displayEndCard:(HyBidEndCard *)endCard withViewController:(UIViewController*) viewController;
- (void)displayEndCard:(HyBidEndCard *)endCard withCTAButton:(HyBidVASTCTAButton *)ctaButton withViewController:(UIViewController*) viewController;
- (void)setupUI;
- (void)setAutoStoreKitPresentationAllowed:(BOOL)autoStoreKitAllowed;

@end
