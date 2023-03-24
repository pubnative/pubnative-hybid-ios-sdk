//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNLiteMRAIDBannerPresenter.h"
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "HyBidMRAIDServiceProvider.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidSKAdNetworkViewController.h"
#import "HyBidURLDriller.h"
#import "HyBidError.h"
#import "HyBid.h"
#import "StoreKit/StoreKit.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteMRAIDBannerPresenter () <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, HyBidURLDrillerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, retain) HyBidMRAIDView *mraidView;
@property (nonatomic, strong) HyBidAd *adModel;

@end

@implementation PNLiteMRAIDBannerPresenter

- (void)dealloc {
    self.serviceProvider = nil;
    self.adModel = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        self.adModel = ad;
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
                                           needCloseButton:NO];
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
                                           needCloseButton:NO];
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

#pragma mark HyBidMRAIDViewDelegate

- (void)mraidViewAdReady:(HyBidMRAIDView *)mraidView {
    [self.delegate adPresenter:self didLoadWithAd:mraidView];
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
    
    [self.delegate adPresenterDidClick:self];
    
    HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.adModel getOpenRTBSkAdNetworkModel] : [self.adModel getSkAdNetworkModel];
    
    if (skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
        
        [self insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            [[HyBidURLDriller alloc] startDrillWithURLString:url.absoluteString delegate:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [productParams removeObjectForKey:@"fidelity-type"];
                HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters:productParams];
                skAdnetworkViewController.delegate = self;
                [[UIApplication sharedApplication].topViewController presentViewController:skAdnetworkViewController animated:true completion:nil];
                [self.delegate adPresenterDidDisappear:self];
            });
        } else {
            [self.serviceProvider openBrowser:url.absoluteString];
        }
    } else {
        [self.serviceProvider openBrowser:url.absoluteString];
    }
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
    [self.delegate adPresenterDidClick:self];
    
    HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.adModel getOpenRTBSkAdNetworkModel] : [self.adModel getSkAdNetworkModel];
    
    if (skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
        
        [self insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            [[HyBidURLDriller alloc] startDrillWithURLString:urlString delegate:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [productParams removeObjectForKey:@"fidelity-type"];
                HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters:productParams];
                skAdnetworkViewController.delegate = self;
                [[UIApplication sharedApplication].topViewController presentViewController:skAdnetworkViewController animated:true completion:nil];
                [self.delegate adPresenterDidDisappear:self];
            });
        } else {
            [self.serviceProvider openBrowser:urlString];
        }
    } else {
        [self.serviceProvider openBrowser:urlString];
    }
}

- (NSMutableDictionary *)insertFidelitiesIntoDictionaryIfNeeded:(NSMutableDictionary *)dictionary
{
    double skanVersion = [dictionary[@"adNetworkPayloadVersion"] doubleValue];
    if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [dictionary[@"fidelities"] count] > 0) {
        NSArray<NSData *> *fidelitiesDataArray = dictionary[@"fidelities"];
        
        if ([fidelitiesDataArray count] > 0) {
            for (NSData *fidelity in fidelitiesDataArray) {
                SKANObject skanObject;
                [fidelity getBytes:&skanObject length:sizeof(skanObject)];
                
                if (skanObject.fidelity == 1) {
                    if (@available(iOS 11.3, *)) {
                        [dictionary setObject:[NSString stringWithUTF8String:skanObject.timestamp] forKey:SKStoreProductParameterAdNetworkTimestamp];
                        
                        NSString *nonce = [NSString stringWithUTF8String:skanObject.nonce];
                        [dictionary setObject:[[NSUUID alloc] initWithUUIDString:nonce] forKey:SKStoreProductParameterAdNetworkNonce];
                    }
                    
                    if (@available(iOS 13.0, *)) {
                        NSString *signature = [NSString stringWithUTF8String:skanObject.signature];
                        
                        [dictionary setObject:signature forKey:SKStoreProductParameterAdNetworkAttributionSignature];
                        
                        NSString *fidelity = [NSString stringWithFormat:@"%d", skanObject.fidelity];
                        [dictionary setObject:fidelity forKey:@"fidelity-type"];
                    }
                    
                    dictionary[@"fidelities"] = nil;
                    
                    break; // Currently we support only 1 fidelity for each kind
                }
            }
        }
    }
    
    return dictionary;
}

- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString {
    [self.serviceProvider playVideo:urlString];
}

- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString {
    [self.serviceProvider storePicture:urlString];
}

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self.delegate adPresenterDidAppear:self];
}

@end
