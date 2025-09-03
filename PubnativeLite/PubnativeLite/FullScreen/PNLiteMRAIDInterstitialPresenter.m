// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteMRAIDInterstitialPresenter.h"
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

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteMRAIDInterstitialPresenter() <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, HyBidURLDrillerDelegate, HyBidInterruptionDelegate>

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, retain) HyBidMRAIDView *mraidView;
@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) HyBidAdAttributionCustomClickAdsWrapper* aakCustomClickAd;

@end

@implementation PNLiteMRAIDInterstitialPresenter

- (void)dealloc {
    self.serviceProvider = nil;
    self.adModel = nil;
    self.aakCustomClickAd = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad withSkipOffset:(NSInteger)skipOffset {
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.skipOffset = skipOffset;
        self.aakCustomClickAd = [[HyBidAdAttributionCustomClickAdsWrapper alloc] initWithAd:self.ad
                                                                                   adFormat:HyBidReportingAdFormat.FULLSCREEN];
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
    [self.delegate interstitialPresenterDidClick:self];
    
    if(![self.aakCustomClickAd adHasCustomMarketPlace]){
        [self triggerClickFlowWithUrl:url];
    } else {
        [self.aakCustomClickAd handlingCustomMarketPlaceWithCompletion:^(BOOL successful) {
            if (!successful) { [self triggerClickFlowWithUrl:url]; }
        }];
    }
}

- (void)triggerClickFlowWithUrl:(NSString *)url {
    HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.adModel getOpenRTBSkAdNetworkModel] : [self.adModel getSkAdNetworkModel];
    
    NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:url];
    if (customUrl != nil) {
        [self openBrowser:customUrl navigationType:HyBidWebBrowserNavigationExternalValue];
    } else if (skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];

        [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            [[HyBidURLDriller alloc] startDrillWithURLString:url delegate:self];
            
            [HyBidSKAdNetworkViewController.shared presentStoreKitViewWithProductParameters:[HyBidStoreKitUtils cleanUpProductParams:productParams] adFormat:HyBidReportingAdFormat.FULLSCREEN isAutoStoreKitView:NO ad:self.ad];
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
    [self.delegate interstitialPresenterDidLoad:self];
}

- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID View failed."];
    NSError *error = [NSError hyBidMraidPlayer];
    [self.delegate interstitialPresenter:self didFailWithError:error];
}

- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID will expand."];
    [self.delegate interstitialPresenterDidShow:self];
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
    [self.delegate interstitialPresenterDidDismiss:self];
    [self.delegate interstitialPresenterDidFinish:self];
}

- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"MRAID navigate with URL:%@",url]];
    
    [self handleClick:url.absoluteString];
}

- (BOOL)mraidViewShouldResize:(HyBidMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen {
    return allowOffscreen;
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
    [self.delegate interstitialPresenterDidAppear:self];
}

- (void)adHasNoFocus {
    [self.delegate interstitialPresenterDidDisappear:self];
}

@end
