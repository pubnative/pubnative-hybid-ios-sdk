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
#import "HyBidSKAdNetworkViewController.h"
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

@interface HyBidMRAIDRewardedPresenter() <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, HyBidURLDrillerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, retain) HyBidMRAIDView *mraidView;
@property (nonatomic, strong) HyBidAd *adModel;

@end

@implementation HyBidMRAIDRewardedPresenter

- (void)dealloc {
    self.serviceProvider = nil;
    self.adModel = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad withSkipOffset:(NSInteger)skipOffset {
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.skipOffset = skipOffset;
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
                                                 isEndcard:NO];
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
    
    HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.adModel getOpenRTBSkAdNetworkModel] : [self.adModel getSkAdNetworkModel];
    
    NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:url];
    if (customUrl != nil) {
        [self openBrowser:customUrl navigationType:HyBidWebBrowserNavigationExternalValue];
    } else if (skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];

        [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            [[HyBidURLDriller alloc] startDrillWithURLString:url delegate:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters: [HyBidStoreKitUtils cleanUpProductParams:productParams] delegate: self];
                [skAdnetworkViewController presentSKStoreProductViewController:^(BOOL success) {
                    if (success) {
                        [self.delegate rewardedPresenterDidDisappear:self];
                    }
                }];
            });
        } else {
            [self openBrowser:url navigationType:self.ad.navigationMode];
        }
    } else {
        [self openBrowser:url navigationType:self.ad.navigationMode];
    }
}

- (void)openBrowser:(NSString*)url navigationType:(NSString *)navigationType {
    
    HyBidWebBrowserNavigation navigation = [HyBidInternalWebBrowserNavigationController.shared webBrowserNavigationBehaviourFromString: navigationType];
    
    if (navigation == HyBidWebBrowserNavigationInternal) {
        if (!self.mraidView) { return; }
        [HyBidInternalWebBrowserNavigationController.shared navigateToURL:url delegate:self.mraidView];
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

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.STOREKIT_PRODUCT_VIEW_DISMISS adFormat:HyBidReportingAdFormat.REWARDED properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    [HyBidNotificationCenter.shared post: HyBidNotificationTypeSKStoreProductViewIsDismissed object: nil userInfo: nil];
    [self.delegate rewardedPresenterDidAppear:self];
}

@end
