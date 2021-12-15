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
#import "HyBidAdImpression.h"
#import "HyBidVastTagAdSource.h"
#import "HyBidSignalDataProcessor.h"
#import "HyBid.h"
#import "HyBidError.h"
#import "PNLiteAssetGroupType.h"
#import "HyBidRemoteConfigFeature.h"

@interface HyBidAdView() <HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSMutableArray<HyBidAd*>* auctionResponses;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, assign) NSTimeInterval initialLoadTimestamp;
@property (nonatomic, assign) NSTimeInterval initialRenderTimestamp;
@property (nonatomic, strong) NSMutableDictionary *loadReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *renderReportingProperties;

@end

@implementation HyBidAdView

- (void)dealloc {
    self.ad = nil;
    self.zoneID = nil;
    self.delegate = nil;
    self.adPresenter = nil;
    self.adRequest = nil;
    self.adSize = nil;
    self.loadReportingProperties = nil;
    self.renderReportingProperties = nil;
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
        if (![HyBid isInitialized]) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid SDK was not initialized. Please initialize it before creating a HyBidAdView. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process."];
        }
        self.adRequest = [[HyBidAdRequest alloc] init];
        self.adRequest.openRTBAdType = HyBidOpenRTBAdBanner;
        self.auctionResponses = [[NSMutableArray alloc]init];
        self.adSize = adSize;
        self.autoShowOnLoad = true;
        self.loadReportingProperties = [NSMutableDictionary new];
        self.renderReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

- (void)cleanUp {
    [self removeAllSubViewsFrom:self];
    [self.container removeFromSuperview];
    self.container = nil;
    self.ad = nil;
    self.initialLoadTimestamp = -1;
    self.initialRenderTimestamp = -1;
}

- (void)removeAllSubViewsFrom:(UIView *)view {
    NSArray *viewsToRemove = [view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)loadWithZoneID:(NSString *)zoneID withPosition:(HyBidBannerPosition)bannerPosition andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    self.bannerPosition = bannerPosition;
    [self loadWithZoneID:zoneID andWithDelegate:delegate];
}

- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *bannerString = [HyBidRemoteConfigFeature hyBidRemoteAdFormatToString:HyBidRemoteAdFormat_BANNER];
    if (![[[HyBidRemoteConfigManager sharedInstance] featureResolver] isAdFormatEnabled:bannerString]) {
        [self invokeDidFailWithError:[NSError hyBidDisabledFormatError]];
    } else {
        self.delegate = delegate;
        self.zoneID = zoneID;
        if (!self.zoneID || self.zoneID.length == 0) {
            [self invokeDidFailWithError:[NSError hyBidInvalidZoneId]];
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
                                        [self invokeDidLoad];
                                    }
                                });
                            } else {
                                [self invokeDidFailWithError:error];
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
}

- (void)requestAd {
    self.adRequest.adSize = self.adSize;
    [self.adRequest setIntegrationType: self.isMediation ? MEDIATION : STANDALONE withZoneID:self.zoneID];
    [self.adRequest requestAdWithDelegate:self withZoneID:self.zoneID];
}

- (void)prepare {
    if (self.adRequest != nil && self.ad != nil) {
        [self.adRequest cacheAd:self.ad];
    }
}

- (BOOL)isAutoCacheOnLoad {
    if (self.adRequest != nil) {
        return [self.adRequest isAutoCacheOnLoad];
    } else {
        return YES;
    }
}

- (void)setIsAutoCacheOnLoad:(BOOL)isAutoCacheOnLoad {
    if (self.adRequest != nil) {
        [self.adRequest setIsAutoCacheOnLoad:isAutoCacheOnLoad];
    }
}

- (void)show {
    [self renderAd];
}

- (void)show:(UIView *)adView withPosition:(HyBidBannerPosition)position {
    if (self.container == nil) {
        self.container = [[UIView alloc] init];
    }
    [self.container addSubview:adView];
    [[self containerViewController].view addSubview:self.container];
    
    switch (position) {
        case BANNER_POSITION_UNKNOWN:
            break;
        case BANNER_POSITION_TOP:
            [self setStickyBannerConstraintsAtPosition:BANNER_POSITION_TOP forView:self.container];
            break;
        case BANNER_POSITION_BOTTOM:
            [self setStickyBannerConstraintsAtPosition:BANNER_POSITION_BOTTOM forView:self.container];
            break;
    }
}

- (UIViewController *)containerViewController {
    return [[[UIApplication sharedApplication].delegate.window.rootViewController childViewControllers] lastObject];
}

- (void)setStickyBannerConstraintsAtPosition:(HyBidBannerPosition)position forView:(UIView *)adView {
    adView.translatesAutoresizingMaskIntoConstraints = NO;
    [adView.widthAnchor constraintEqualToConstant:self.adSize.width].active = YES;
    [adView.heightAnchor constraintEqualToConstant:self.adSize.height].active = YES;
    [adView.centerXAnchor constraintEqualToAnchor:[self containerViewController].view.centerXAnchor].active = YES;
    if (@available(iOS 11.0, *)) {
        [position == BANNER_POSITION_TOP ? adView.topAnchor : adView.bottomAnchor
                                     constraintEqualToAnchor:
         position == BANNER_POSITION_TOP ? [self containerViewController].view.safeAreaLayoutGuide.topAnchor : [self containerViewController].view.safeAreaLayoutGuide.bottomAnchor constant:position == BANNER_POSITION_TOP ? 8.0 : -8.0].active = YES;
    } else {
        // Fallback on earlier versions
    }
}

- (void)setupAdView:(UIView *)adView {
    if (self.bannerPosition == BANNER_POSITION_UNKNOWN) {
        [self addSubview:adView];
    } else {
        [self show:adView withPosition:self.bannerPosition];
    }
    
    if (self.autoShowOnLoad) {
        [self invokeDidLoad];
    }
    [self startTracking];
    if (self.initialRenderTimestamp != -1) {
        [self.renderReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialRenderTimestamp]] forKey:HyBidReportingCommon.RENDER_TIME];
    }
    [self addCommonPropertiesToReportingDictionary:self.renderReportingProperties];
    [self reportEvent:HyBidReportingEventType.RENDER withProperties:self.renderReportingProperties];
}

- (void)renderAd {
    self.adPresenter = [self createAdPresenter];
    if (!self.adPresenter) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid ad presenter."];
        [self.delegate adView:self didFailWithError:[NSError hyBidUnsupportedAsset]];
        [self createRenderErrorEventWithError:[NSError hyBidUnsupportedAsset]];
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
        [self.delegate adView:self didFailWithError:[NSError hyBidInvalidAsset]];
        [self createRenderErrorEventWithError:[NSError hyBidInvalidAsset]];
    }
}

- (void)processAdContent:(NSString *)adContent {
    HyBidSignalDataProcessor *signalDataProcessor = [[HyBidSignalDataProcessor alloc] init];
    signalDataProcessor.delegate = self;
    [signalDataProcessor processSignalData:adContent];
}

- (void)startTracking {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        [self.adPresenter startTracking];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
        [[HyBidAdImpression sharedInstance] startImpressionForAd:self.ad];
#endif
        
        if (self.ad.adType != kHyBidAdTypeVideo) {
            [self.delegate adViewDidTrackImpression:self];
        }
    }
}

- (void)stopTracking {
    [self.adPresenter stopTracking];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
    [[HyBidAdImpression sharedInstance] endImpressionForAd:self.ad];
#endif
}

- (HyBidAdPresenter *)createAdPresenter {
    self.initialRenderTimestamp = [[NSDate date] timeIntervalSince1970];
    HyBidBannerPresenterFactory *bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
    return [bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
}

- (void)createRenderErrorEventWithError:(NSError *)error {
    NSMutableDictionary *renderErrorReportingProperties = [NSMutableDictionary new];
    [renderErrorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
    [renderErrorReportingProperties setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:HyBidReportingCommon.ERROR_CODE];
    [self addCommonPropertiesToReportingDictionary:renderErrorReportingProperties];
    [self reportEvent:HyBidReportingEventType.RENDER_ERROR withProperties:renderErrorReportingProperties];
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary {
    [reportingDictionary setObject:[HyBidSettings sharedInstance].appToken forKey:HyBidReportingCommon.APPTOKEN];
    if (self.zoneID) {
        [reportingDictionary setObject:self.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    [reportingDictionary setObject:[HyBidIntegrationType integrationTypeToString:self.adRequest.integrationType] forKey:HyBidReportingCommon.INTEGRATION_TYPE];
    [reportingDictionary setObject:self.adSize.description forKey:HyBidReportingCommon.AD_SIZE];
    switch (self.ad.assetGroupID.integerValue) {
        case VAST_MRECT:
        case VAST_INTERSTITIAL:
            [reportingDictionary setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
            if (self.ad.vast) {
                [reportingDictionary setObject:self.ad.vast forKey:HyBidReportingCommon.CREATIVE];
            }
            break;
        default:
            [reportingDictionary setObject:@"HTML" forKey:HyBidReportingCommon.AD_TYPE];
            if (self.ad.htmlData) {
                [reportingDictionary setObject:self.ad.htmlData forKey:HyBidReportingCommon.CREATIVE];
            }
            break;
    }
    switch (self.bannerPosition) {
        case BANNER_POSITION_UNKNOWN:
            break;
        case BANNER_POSITION_TOP:
            [reportingDictionary setObject:@"TOP" forKey:HyBidReportingCommon.AD_POSITION];
            break;
        case BANNER_POSITION_BOTTOM:
            [reportingDictionary setObject:@"BOTTOM" forKey:HyBidReportingCommon.AD_POSITION];
            break;
    }
}

- (void)reportEvent:(NSString *)eventType withProperties:(NSMutableDictionary *)properties {
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc] initWith:eventType
                                                                       adFormat:HyBidReportingAdFormat.BANNER
                                                                     properties:properties];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
}

- (NSTimeInterval)elapsedTimeSince:(NSTimeInterval)timestamp {
    return [[NSDate date] timeIntervalSince1970] - timestamp;
}

- (void)invokeDidLoad {
    if (self.initialLoadTimestamp != -1) {
        [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
    }
    [self addCommonPropertiesToReportingDictionary:self.loadReportingProperties];
    [self reportEvent:HyBidReportingEventType.LOAD withProperties:self.loadReportingProperties];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
        [self.delegate adViewDidLoad:self];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    if (self.initialLoadTimestamp != -1) {
        [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
    }
    [self addCommonPropertiesToReportingDictionary:self.loadReportingProperties];
    [self reportEvent:HyBidReportingEventType.LOAD_FAIL withProperties:self.loadReportingProperties];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    if (!ad) {
        [self invokeDidFailWithError:[NSError hyBidNullAd]];
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
            [self invokeDidLoad];
        }
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ failed with error: %@",request, error.localizedDescription]];
    [self invokeDidFailWithError:error];
}

#pragma mark - HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView {
    if (!adView) {
        [self invokeDidFailWithError:[NSError hyBidRenderingBanner]];
    } else {
        [self setupAdView:adView];
    }
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter {
    [self.delegate adViewDidTrackImpression:self];
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

- (HyBidSkAdNetworkModel *)skAdNetworkModel {
    HyBidSkAdNetworkModel *result = nil;
    if (self.ad) {
        result = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
    }
    return result;
}

-  (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter {
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
