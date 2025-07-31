// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidMRAIDView.h"
#import "HyBidVASTEndCard.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidVASTCTAButton.h"
#import "HyBidAd.h"
#import "HyBidVASTAd.h"
#import "HyBidVASTEndCardManager.h"
#import "HyBidSKOverlayDelegate.h"
#import "HyBidCustomCTAViewDelegate.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@protocol HyBidVASTEndCardViewDelegate<NSObject>

- (void)vastEndCardViewDidDisplay;
- (void)vastEndCardViewCloseButtonTapped;
- (void)vastEndCardViewSkipButtonTapped;
- (void)vastEndCardViewFailedToLoad;
- (void)vastEndCardViewClicked:(BOOL)triggerAdClick aakCustomClickAd:(HyBidAdAttributionCustomClickAdsWrapper*)aakCustomClickAd;
- (void)vastEndCardViewSKOverlayClicked:(BOOL)triggerAdClick
                              clickType:(HyBidSKOverlayAutomaticCLickType)clickType
                    isFirstPresentation:(BOOL)isFirstPresentation;
- (void)vastEndCardViewAutoStorekitClicked:(BOOL)triggerAdClick clickType:(HyBidStorekitAutomaticClickType)clickType;
- (void)vastEndCardViewRedirectedWithSuccess:(BOOL)success;
- (void)vastEndCardViewCustomCTAPresented;
- (void)vastEndCardViewCustomCTAClicked;
- (void)vastEndCardViewReplayButtonClicked;

@end

@interface HyBidVASTEndCardView : UIView <HyBidSKOverlayDelegate, HyBidCustomCTAViewDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(NSObject<HyBidVASTEndCardViewDelegate> *)delegate
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
- (void)displayEndCard:(HyBidVASTEndCard *)endCard withViewController:(UIViewController*) viewController;
- (void)displayEndCard:(HyBidVASTEndCard *)endCard withCTAButton:(HyBidVASTCTAButton *)ctaButton withViewController:(UIViewController*) viewController;
- (void)setupUI;

@end
