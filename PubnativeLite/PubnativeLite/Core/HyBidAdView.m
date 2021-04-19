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

#import "HyBidAdView.h"
#import "HyBidLogger.h"
#import "HyBidIntegrationType.h"
#import "HyBidBannerPresenterFactory.h"
#import "HyBidRemoteConfigManager.h"
#import "HyBidRemoteConfigModel.h"
#import "HyBidAuction.h"
#import "HyBidVastTagAdSource.h"

@interface HyBidAdView()

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSMutableArray<HyBidAd*>* auctionResponses;
@property (nonatomic, strong) UIView *container;

@end

@implementation HyBidAdView

- (void)dealloc {
    self.ad = nil;
    self.zoneID = nil;
    self.delegate = nil;
    self.adPresenter = nil;
    self.adRequest = nil;
    self.adSize = nil;

    [self cleanUp];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.adRequest = [[HyBidAdRequest alloc] init];
    self.autoShowOnLoad = true;
}

- (instancetype)initWithSize:(HyBidAdSize *)adSize {
    self = [super initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)];
    if (self) {
        self.adRequest = [[HyBidAdRequest alloc] init];
        self.adRequest.openRTBAdType = BANNER;
        self.auctionResponses = [[NSMutableArray alloc]init];
        self.adSize = adSize;
        self.autoShowOnLoad = true;
    }
    return self;
}

- (void)cleanUp {
    [self removeAllSubViewsFrom:self];
    [self.container removeFromSuperview];
    self.container = nil;
    self.ad = nil;
}

- (void)removeAllSubViewsFrom:(UIView *)view {
    NSArray *viewsToRemove = [view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)loadWithZoneID:(NSString *)zoneID withPosition:(BannerPosition)bannerPosition andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate
{
    self.bannerPosition = bannerPosition;
    [self loadWithZoneID:zoneID andWithDelegate:delegate];
}

- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.delegate = delegate;
    self.zoneID = zoneID;
    if (!self.zoneID || self.zoneID.length == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"Invalid Zone ID provided." code:0 userInfo:nil]];
        }
    } else {
        HyBidRemoteConfigModel* configModel = HyBidRemoteConfigManager.sharedInstance.remoteConfigModel;
        
        if (configModel.placementInfo != nil &&
            configModel.placementInfo.placements != nil &&
            configModel.placementInfo.placements.count > 0) {
            
            NSPredicate *p = [NSPredicate predicateWithFormat:@"zoneId=%ld", [zoneID integerValue]];
            NSArray<HyBidRemoteConfigPlacement*>* filteredPlacements = [configModel.placementInfo.placements filteredArrayUsingPredicate:p];
            
            if (filteredPlacements.count > 0) {
                HyBidRemoteConfigPlacement *placement = filteredPlacements.firstObject;
                
                if (placement.type != nil &&
                    [placement.type isEqualToString:@"auction"] &&
                    placement.adSources.count > 0 ) {
                    
                    long timeout = 5000;
                    if (placement.timeout != 0) {
                        timeout = placement.timeout;
                    }
                    NSMutableArray<HyBidAdSourceAbstract*>* adSources = [[NSMutableArray alloc]init];
                    for (HyBidAdSourceConfig* config in placement.adSources) {
                        if (config.type != nil &&
                            [config.type isEqualToString:@"vast_tag"]) {
                            HyBidVastTagAdSource* vastAdSource = [[HyBidVastTagAdSource alloc]initWithConfig:config];
                            [adSources addObject:vastAdSource];
                        }
                    }
                    HyBidAuction* auction = [[HyBidAuction alloc]initWithAdSources:adSources mZoneId: zoneID timeout:timeout];
                    [auction runAction:^(NSArray<HyBidAd *> *mAdResponses, NSError *error) {
                        if (error == nil && [mAdResponses count] > 0) {
                            self.ad = mAdResponses.firstObject;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.autoShowOnLoad) {
                                    [self renderAd];
                                } else {
                                    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
                                        [self.delegate adViewDidLoad:self];
                                    }
                                }
                            });
                        } else {
                            if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
                                [self.delegate adView:self didFailWithError:error];
                            }
                        }
                        return;
                    }];
                    return;
                }
            }
        }
        [self requestAd];
        
    }
}

- (void)requestAd {
    self.adRequest.adSize = self.adSize;
    [self.adRequest setIntegrationType: self.isMediation ? MEDIATION : STANDALONE withZoneID:self.zoneID];
    [self.adRequest requestAdWithDelegate:self withZoneID:self.zoneID];
}

- (void) show {
    [self renderAd];
}

- (void)show:(UIView *)adView withPosition:(BannerPosition)position
{
    if (self.container == nil) {
        self.container = [[UIView alloc] init];
    }
    
    [self.container addSubview:adView];
    [[self containerViewController].view addSubview:self.container];
    
    switch (position) {
        case UNKNOWN:
            break;
        case TOP:
            [self setStickyBannerConstraintsAtPosition:TOP forView:self.container];
            break;
        case BOTTOM:
            [self setStickyBannerConstraintsAtPosition:BOTTOM forView:self.container];
            break;
    }
}

- (UIViewController *)containerViewController
{
    return [[[UIApplication sharedApplication].delegate.window.rootViewController childViewControllers] lastObject];
}

- (void)setStickyBannerConstraintsAtPosition:(BannerPosition)position forView:(UIView *)adView
{
    adView.translatesAutoresizingMaskIntoConstraints = NO;
    [adView.widthAnchor constraintEqualToConstant:self.adSize.width].active = YES;
    [adView.heightAnchor constraintEqualToConstant:self.adSize.height].active = YES;
    [adView.centerXAnchor constraintEqualToAnchor:[self containerViewController].view.centerXAnchor].active = YES;
    if (@available(iOS 11.0, *)) {
        [position == TOP ? adView.topAnchor : adView.bottomAnchor
        constraintEqualToAnchor:
        position == TOP ? [self containerViewController].view.safeAreaLayoutGuide.topAnchor : [self containerViewController].view.safeAreaLayoutGuide.bottomAnchor
        constant:8.0].active = YES;
    } else {
        // Fallback on earlier versions
    }
}

- (void)setupAdView:(UIView *)adView {
    if (self.bannerPosition == UNKNOWN) {
        [self addSubview:adView];
    } else {
        [self show:adView withPosition:self.bannerPosition];
    }
    
    if (self.autoShowOnLoad) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
            [self.delegate adViewDidLoad:self];
        }
    }
    [self startTracking];
}

- (void)renderAd {
    self.adPresenter = [self createAdPresenter];
    if (!self.adPresenter) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid ad presenter."];
        [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"The server has returned an unsupported ad asset." code:0 userInfo:nil]];
        return;
    } else {
        [self.adPresenter load];
    }
}

- (void)renderAdWithContent:(NSString *)adContent withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.delegate = delegate;
    
    if (adContent && [adContent length] != 0) {
        [self processAdContent:adContent];
    } else {
        [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"The server has returned an invalid ad asset." code:0 userInfo:nil]];
    }
}

- (void)processAdContent:(NSString *)adContent {
    HyBidSignalDataProcessor *signalDataProcessor = [[HyBidSignalDataProcessor alloc] init];
    signalDataProcessor.delegate = self;
    [signalDataProcessor processSignalData:adContent withZoneID:self.zoneID];
}

- (void)startTracking {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        [self.adPresenter startTracking];
        
        if (self.ad.adType != kHyBidAdTypeVideo) {
            [self.delegate adViewDidTrackImpression:self];
        }
    }
}

- (void)stopTracking {
    [self.adPresenter stopTracking];
}

- (HyBidAdPresenter *)createAdPresenter {
    HyBidBannerPresenterFactory *bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
    return [bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    if (!ad) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"Server returned nil ad." code:0 userInfo:nil]];
        }
    } else {
        self.ad = ad;
        if (self.ad.vast != nil) {
            self.ad.adType = kHyBidAdTypeVideo;
        } else {
            self.ad.adType = kHyBidAdTypeHTML;
        }
        if (self.autoShowOnLoad) {
            [self renderAd];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
                [self.delegate adViewDidLoad:self];
            }
        }
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ failed with error: %@",request, error.localizedDescription]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    if (!adView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
            [self.delegate adView:self didFailWithError:[NSError errorWithDomain:@"An error has occurred while rendering the ad." code:0 userInfo:nil]];
        }
    } else {
        [self setupAdView:adView];
    }
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter
{
    [self.delegate adViewDidTrackImpression:self];
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

- (HyBidSkAdNetworkModel *)skAdNetworkModel {
    HyBidSkAdNetworkModel *result = nil;
    if (self.ad) {
        result = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
    }
    return result;
}

-  (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackClick:)]) {
        [self.delegate adViewDidTrackClick:self];
    }
}

#pragma mark - HyBidSignalDataProcessorDelegate

- (void)signalDataDidFinishWithAd:(HyBidAd *)ad {
    self.ad = ad;
    [self renderAd];
}

- (void)signalDataDidFailWithError:(NSError *)error {
    [self.delegate adView:self didFailWithError:error];
}

@end
