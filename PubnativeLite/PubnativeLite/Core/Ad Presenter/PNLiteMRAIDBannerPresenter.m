// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteMRAIDBannerPresenter.h"
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
#import "HyBidDeeplinkHandler.h"
#import "HyBidStoreKitUtils.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteMRAIDBannerPresenter () <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, HyBidURLDrillerDelegate, HyBidInterruptionDelegate>

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, retain) HyBidMRAIDView *mraidView;
@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) HyBidAdAttributionCustomClickAdsWrapper* aakCustomClickAd;

@end

@implementation PNLiteMRAIDBannerPresenter

- (void)dealloc {
    self.serviceProvider = nil;
    self.adModel = nil;
    self.aakCustomClickAd = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.aakCustomClickAd = [[HyBidAdAttributionCustomClickAdsWrapper alloc] initWithAd:self.ad adFormat:HyBidReportingAdFormat.BANNER];
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    self.mraidView = [[HyBidMRAIDView alloc] initWithFrame:CGRectMake(0, 0, [self.adModel.width floatValue], [self.adModel.height floatValue])
                                               withHtmlData:self.adModel.htmlData
                                                withBaseURL:[NSURL URLWithString:self.adModel.htmlUrl]
                                                    withAd:self.ad
                                          supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo, PNLiteMRAIDSupportsLocation]
                                              isInterstital:NO
                                              isScrollable:NO
                                                   delegate:self
                                            serviceDelegate:self
                                         rootViewController:[UIApplication sharedApplication].topViewController
                                                contentInfo:self.adModel.contentInfo
                                                 skipOffset:0
                                                 isEndcard:NO
                                 shouldHandleInterruptions:YES];
}

- (void)loadMarkupWithSize:(HyBidAdSize *)adSize {
    self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    self.mraidView = [[HyBidMRAIDView alloc] initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)
                                               withHtmlData:self.adModel.htmlData
                                                withBaseURL:[NSURL URLWithString:self.adModel.htmlUrl]
                                                    withAd:self.ad
                                          supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo, PNLiteMRAIDSupportsLocation]
                                              isInterstital:NO
                                              isScrollable:NO
                                                   delegate:self
                                            serviceDelegate:self
                                         rootViewController:[UIApplication sharedApplication].topViewController
                                                contentInfo:self.adModel.contentInfo
                                                 skipOffset:0
                                                 isEndcard:NO
                                 shouldHandleInterruptions:YES];
}

- (void)startTracking {
    if (self.mraidView) {
        [self.mraidView startAdSession];
    }
}

- (void)stopTracking {
    if (self.mraidView) {
        [self.mraidView stopAdSession];
    }
}

- (void)handleClick:(NSString*) url {
    [self.delegate adPresenterDidClick:self];
    
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
    HyBidDeeplinkHandler *deeplinkHandler = [[HyBidDeeplinkHandler alloc] initWithLink:self.ad.link];
    
    NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:url];
    if (customUrl != nil) {
        [self openBrowser:customUrl navigationType: HyBidWebBrowserNavigationExternalValue];
    } else if (skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
        
        [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            if (deeplinkHandler.isCapable && deeplinkHandler.fallbackURL) {
                [[HyBidURLDriller alloc] startDrillWithURLString:deeplinkHandler.fallbackURL.absoluteString delegate:self];
            }
            [[HyBidURLDriller alloc] startDrillWithURLString:url delegate:self];
            
            NSDictionary *cleanedParams = [HyBidStoreKitUtils cleanUpProductParams:productParams];
            NSLog(@"HyBid SKAN params dictionary: %@", cleanedParams);
            [HyBidSKAdNetworkViewController.shared presentStoreKitViewWithProductParameters:cleanedParams adFormat:HyBidReportingAdFormat.BANNER isAutoStoreKitView:NO ad:self.ad];
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
    [self.delegate adPresenter:self didLoadWithAd:mraidView];
    [self.aakCustomClickAd startImpressionWithAdView: mraidView];
}

- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID View failed."];
    NSError *error = [NSError hyBidMraidPlayer];
    [self.delegate adPresenter:self didFailWithError:error];
}

- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID will expand."];
}

- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID did close."];
}

- (HyBidSkAdNetworkModel *)skAdNetworkModel {
    HyBidSkAdNetworkModel *result = nil;
    if (self.adModel) {
        result = self.ad.isUsingOpenRTB ? [self.adModel getOpenRTBSkAdNetworkModel] : [self.adModel getSkAdNetworkModel];
    }
    return result;
}

- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"MRAID navigate with URL:%@",url]];
    
    [self handleClick: url.absoluteString];
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
    [self handleClick: urlString];
}

- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString {
    [self.serviceProvider playVideo:urlString];
}

- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString {
    [self.serviceProvider storePicture:urlString];
}

#pragma mark HyBidInterruptionDelegate

- (void)adHasNoFocus {
    if ([self.delegate respondsToSelector:@selector(adPresenterDidDisappear:)]) {
        [self.delegate adPresenterDidDisappear:self];
    }
}

- (void)adHasFocus {
    if ([self.delegate respondsToSelector:@selector(adPresenterDidAppear:)]) {
        [self.delegate adPresenterDidAppear:self];
    }
}

@end
