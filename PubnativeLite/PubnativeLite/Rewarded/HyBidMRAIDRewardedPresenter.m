// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidMRAIDRewardedPresenter.h"
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "HyBidMRAIDServiceProvider.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidURLDriller.h"
#import "HyBidError.h"
#import "HyBid.h"
#import "StoreKit/StoreKit.h"
#import "HyBidSKAdNetworkParameter.h"
#import "HyBidCustomClickUtil.h"
#import "HyBidStoreKitUtils.h"
#import "HyBidDeeplinkHandler.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidMRAIDRewardedPresenter() <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, HyBidURLDrillerDelegate, HyBidInterruptionDelegate>

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, retain) HyBidMRAIDView *mraidView;
@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) HyBidSkAdNetworkModel *skAdModel;
@property (nonatomic, strong) HyBidAdAttributionCustomClickAdsWrapper* aakCustomClickAd;

@end

@implementation HyBidMRAIDRewardedPresenter

- (void)dealloc {
    self.serviceProvider = nil;
    self.adModel = nil;
    self.skAdModel = nil;
    self.aakCustomClickAd = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad withSkipOffset:(NSInteger)skipOffset {
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.skipOffset = skipOffset;
        self.skAdModel = ad.isUsingOpenRTB ? [self.adModel getOpenRTBSkAdNetworkModel] : [self.adModel getSkAdNetworkModel];
        self.aakCustomClickAd = [[HyBidAdAttributionCustomClickAdsWrapper alloc] initWithAd:self.ad
                                                                                   adFormat:HyBidReportingAdFormat.REWARDED];
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    self.mraidView = [[HyBidMRAIDView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
                                              withHtmlData:self.adModel.htmlData
                                               withBaseURL:[NSURL URLWithString:self.adModel.htmlUrl]
                                                    withAd:self.ad
                                         supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo, PNLiteMRAIDSupportsLocation]
                                             isInterstital:YES
                                              isScrollable:NO
                                                  delegate:self
                                           serviceDelegate:self
                                        rootViewController:[UIApplication sharedApplication].topViewController
                                               contentInfo:self.adModel.contentInfo
                                                skipOffset:_skipOffset
                                                 isEndcard:NO
                                 shouldHandleInterruptions:YES];
}

- (void)show {
    [self.mraidView showAsInterstitial];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [self.mraidView showAsInterstitialFromViewController:viewController];
}

- (void)hide {
    [self.mraidView hide];
}

- (void)handleClick:(NSString*) url {
    [self.delegate rewardedPresenterDidClick:self];
    
    if(![self.aakCustomClickAd adHasCustomMarketPlace]){
        [self triggerClickFlowWithUrl:url];
    } else {
        [self.aakCustomClickAd handlingCustomMarketPlaceWithCompletion:^(BOOL successful) {
            if (!successful) { [self triggerClickFlowWithUrl:url]; }
        }];
    }
}

- (void)triggerClickFlowWithUrl:(NSString *)url {
    HyBidDeeplinkHandler *deeplinkHandler = [[HyBidDeeplinkHandler alloc] initWithLink:self.ad.link];
    HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.adModel getOpenRTBSkAdNetworkModel] : [self.adModel getSkAdNetworkModel];
    
    NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:url];
    if (customUrl != nil) {
        [self openBrowser:customUrl navigationType:HyBidWebBrowserNavigationExternalValue];
    } else if (skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];

        [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            [[HyBidURLDriller alloc] startDrillWithURLString:url delegate:self];
            if (deeplinkHandler.isCapable && deeplinkHandler.fallbackURL) {
                [[HyBidURLDriller alloc] startDrillWithURLString:deeplinkHandler.fallbackURL.absoluteString delegate:self];
            }
            
            NSDictionary *cleanedParams = [HyBidStoreKitUtils cleanUpProductParams:productParams];
            NSLog(@"HyBid SKAN params dictionary: %@", cleanedParams);
            [HyBidSKAdNetworkViewController.shared presentStoreKitViewWithProductParameters:cleanedParams adFormat:HyBidReportingAdFormat.REWARDED isAutoStoreKitView:NO ad:self.ad];
        } else if (deeplinkHandler.isCapable) {
            [deeplinkHandler openWithNavigationType:self.ad.navigationMode];
        } else {
            [self openBrowser:url navigationType:self.ad.navigationMode];
        }
    } else {
        [self openBrowser:url navigationType:self.ad.navigationMode];
    }
}

- (void)openBrowser:(NSString*)url navigationType:(NSString *)navigationType {
    
    HyBidWebBrowserNavigation navigation = [HyBidInternalWebBrowser.shared webBrowserNavigationBehaviourFromString: navigationType];
    
    if (navigation == HyBidWebBrowserNavigationInternal) {
        if (!self.mraidView) { return; }
        [HyBidInternalWebBrowser.shared navigateToURL:url];
    } else {
        [self.serviceProvider openBrowser:url];
    }
}

#pragma mark HyBidMRAIDViewDelegate

- (void)mraidViewAdReady:(HyBidMRAIDView *)mraidView {
    [self.delegate rewardedPresenterDidLoad:self];
}

- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID View failed."];
    NSError *error = [NSError hyBidMraidPlayer];
    [self.delegate rewardedPresenter:self didFailWithError:error];
}

- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID will expand."];
    [self.delegate rewardedPresenterDidShow:self];
    if (self.mraidView) {
        [self.mraidView startAdSession];
    }
    [self.aakCustomClickAd startImpressionWithAdView: [mraidView modalView]];
}

- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID did close."];
    if (self.mraidView) {
        [self.mraidView stopAdSession];
    }
    [self.delegate rewardedPresenterDidDismiss:self];
    [self.delegate rewardedPresenterDidFinish:self];
}

- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"MRAID navigate with URL:%@",url]];
    
    [self handleClick:url.absoluteString];
}

- (BOOL)mraidViewShouldResize:(HyBidMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen {
    return allowOffscreen;
}

- (void)mraidViewWillShowEndCard:(HyBidMRAIDView *)mraidView
                 isCustomEndCard:(BOOL)isCustomEndCard
               skOverlayDelegate:(id<HyBidSKOverlayDelegate>)skOverlayDelegate {
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(rewardedPresenteWillPresentEndCard:skOverlayDelegate:customCTADelegate:)]){
        [self.delegate rewardedPresenteWillPresentEndCard:self skOverlayDelegate:skOverlayDelegate customCTADelegate:nil];
    }

    if ([self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] != [NSNull null] && [self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] &&
        [[self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] intValue] == -1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedPresenterDismissesSKOverlay:)]) {
            [self.delegate rewardedPresenterDismissesSKOverlay:self];
        }
    } else {
        if (isCustomEndCard) {
            [HyBidInterruptionHandler.shared customEndCardWillShow];
        } else {
            [HyBidInterruptionHandler.shared endCardWillShow];
        }
    }
}

- (void)mraidViewDidPresentCustomEndCard:(HyBidMRAIDView *)mraidView {
    [self.delegate rewardedPresenterDidPresentCustomEndCard:self];
}


- (void)mraidViewAutoStoreKitDidShowWithClickType:(HyBidStorekitAutomaticClickType)clickType {
    [self.delegate rewardedPresenterDidStorekitAutomaticClick:self clickType:clickType];
}


- (void)mraidViewDidShowSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType {
    [self.delegate rewardedPresenterDidSKOverlayAutomaticClick:self clickType:clickType];
}

#pragma mark HyBidMRAIDServiceDelegate

- (void)mraidServiceCallNumberWithUrlString:(NSString *)urlString {
    [self.serviceProvider callNumber:urlString];
}

- (void)mraidServiceSendSMSWithUrlString:(NSString *)urlString {
    [self.serviceProvider sendSMS:urlString];
}

- (void)mraidServiceOpenBrowserWithUrlString:(NSString *)urlString {
    [self handleClick:urlString];
}

- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString {
    [self.serviceProvider playVideo:urlString];
}

- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString {
    [self.serviceProvider storePicture:urlString];
}

#pragma mark HyBidInterruptionDelegate

- (void)adHasFocus {
    [self.delegate rewardedPresenterDidAppear:self];
}

- (void)adHasNoFocus {
    [self.delegate rewardedPresenterDidDisappear:self];
}

@end
