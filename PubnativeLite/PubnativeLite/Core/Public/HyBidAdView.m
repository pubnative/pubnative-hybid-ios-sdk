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
#import "HyBidIntegrationType.h"
#import "HyBidBannerPresenterFactory.h"
#import "HyBidAdImpression.h"
#import "HyBidVastTagAdSource.h"
#import "HyBidSignalDataProcessor.h"
#import "HyBid.h"
#import "HyBidError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

#define TIME_TO_EXPIRE 1800 //30 Minutes as in seconds

@interface HyBidAdView() <HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSMutableArray<HyBidAd*>* auctionResponses;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, assign) NSTimeInterval initialLoadTimestamp;
@property (nonatomic, assign) NSTimeInterval initialRenderTimestamp;
@property (nonatomic, strong) NSMutableDictionary *loadReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *renderReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *sessionReportingProperties;

@property (nonatomic, weak) NSTimer *autoRefreshTimer;
@property (nonatomic, assign) BOOL shouldRunAutoRefresh;
@property (nonatomic, assign) BOOL markup;

@end

@implementation HyBidAdView

@synthesize autoRefreshTimeInSeconds = _autoRefreshTimeInSeconds;

- (void)dealloc {
    self.ad = nil;
    self.zoneID = nil;
    self.appToken = nil;
    self.delegate = nil;
    self.adPresenter = nil;
    self.adRequest = nil;
    self.adSize = nil;
    self.loadReportingProperties = nil;
    self.renderReportingProperties = nil;
    self.sessionReportingProperties = nil;
    [self cleanUp];
    [self stopAutoRefresh];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.adRequest = [[HyBidAdRequest alloc] init];
    self.autoShowOnLoad = true;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (![HyBid isInitialized]) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid SDK was not initialized. Please initialize it before creating a HyBidAdView. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process."];
        }
        self.adRequest = [[HyBidAdRequest alloc] init];
        self.adRequest.openRTBAdType = HyBidOpenRTBAdBanner;
        self.auctionResponses = [[NSMutableArray alloc]init];
        self.adSize = HyBidAdSize.SIZE_320x50;
        self.autoShowOnLoad = true;
        self.loadReportingProperties = [NSMutableDictionary new];
        self.renderReportingProperties = [NSMutableDictionary new];
        self.sessionReportingProperties = [NSMutableDictionary new];
        self.markup = NO;
    }
    return self;
}

- (instancetype)initWithSize:(HyBidAdSize *)adSize {
    self = [self initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)];
    if (self) {
        self.adSize = adSize;
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
    [self setOpenRTBToFalse];
    self.bannerPosition = bannerPosition;
    [self loadWithZoneID:zoneID andWithDelegate:delegate];
}

- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self setOpenRTBToFalse];
    [self loadWithZoneID:zoneID withAppToken:nil andWithDelegate:delegate];
}

- (void)loadExchangeAdWithZoneID:(NSString *)zoneID withPosition:(HyBidBannerPosition)bannerPosition andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self setOpenRTBToTrue];
    self.bannerPosition = bannerPosition;
    [self loadExchangeAdWithZoneID:zoneID andWithDelegate:delegate];
}

- (void)loadExchangeAdWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self setOpenRTBToTrue];
    [self loadWithZoneID:zoneID withAppToken:nil andWithDelegate:delegate];
}

- (void)loadWithZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken andWithDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    
    self.delegate = delegate;
    self.zoneID = zoneID;
    self.appToken = appToken;
    if (!self.zoneID || self.zoneID.length == 0) {
        [self invokeDidFailWithError:[NSError hyBidInvalidZoneId]];
    } else {
        [self requestAd];
    }
}

- (void)requestAd {
    self.adRequest.adSize = self.adSize;
    [self.adRequest setIntegrationType:self.isMediation ? MEDIATION : STANDALONE withZoneID:self.zoneID withAppToken:self.appToken];
    [self.adRequest requestAdWithDelegate:self withZoneID:self.zoneID withAppToken:self.appToken];
    
    self.shouldRunAutoRefresh = YES;
    [self setupAutoRefreshTimerIfNeeded];
}

- (void)setupAutoRefreshTimerIfNeeded {
    if (self.autoRefreshTimer == nil && self.autoRefreshTimeInSeconds > 0) {
        self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshTimeInSeconds target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
}

- (void)prepare {
    if (self.adRequest != nil && self.ad != nil) {
        [self.adRequest cacheAd:self.ad];
    }
}

- (void)setOpenRTBToTrue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kIsUsingOpenRTB];
}

- (void)setOpenRTBToFalse {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kIsUsingOpenRTB];
}

- (void)prepareCustomMarkupFrom:(NSString *)markup withPlacement:(HyBidMarkupPlacement)placement {
    self.markup = YES;
    [self cleanUp];
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    [self.adRequest processCustomMarkupFrom:markup withPlacement: placement andWithDelegate:self];
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

- (void)refresh {
    [self invokeWillRefresh];
    [self cleanUp];
    [self loadWithZoneID:self.zoneID withAppToken:self.appToken andWithDelegate:self.delegate];
}

- (void)setAutoRefreshTimeInSeconds:(NSInteger)autoRefreshTimeInSeconds {
    _autoRefreshTimeInSeconds = autoRefreshTimeInSeconds;
    
    if (self.shouldRunAutoRefresh) {
        [self setupAutoRefreshTimerIfNeeded];
    }
}

- (void)stopAutoRefresh {
    self.autoRefreshTimeInSeconds = 0;
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
}

- (void)setMediationVendor:(NSString *)mediationVendor {
    if (self.adRequest != nil) {
        [self.adRequest setMediationVendor:mediationVendor];
    }
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
        adView.translatesAutoresizingMaskIntoConstraints = false;
        [self centerView:adView inContainerView:self withSuperView:self];
        [self sizeView:adView withSuperView:self withAdSize:self.adSize];
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
    if (self.renderReportingProperties) {
        [self addCommonPropertiesToReportingDictionary:self.renderReportingProperties];
        [self reportEvent:HyBidReportingEventType.RENDER withProperties:self.renderReportingProperties];
    }
}

- (void)renderAd {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval adExpireTime = self.initialLoadTimestamp + TIME_TO_EXPIRE;
    if (currentTime < adExpireTime) {
        self.adPresenter = [self createAdPresenter];
        if (!self.adPresenter) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid ad presenter."];
            [self.delegate adView:self didFailWithError:[NSError hyBidUnsupportedAsset]];
            [self createRenderErrorEventWithError:[NSError hyBidUnsupportedAsset]];
            return;
        } else {
            [self.adPresenter load];
        }
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad has expired"];
        [self cleanUp];
        [self invokeDidFailWithError:[NSError hyBidExpiredAd]];
    }
}

- (void)renderAdForSignalData {
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
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if (adContent && [adContent length] != 0) {
        [self processAdContent:adContent];
    } else {
        [self.delegate adView:self didFailWithError:[NSError hyBidInvalidAsset]];
        [self createRenderErrorEventWithError:[NSError hyBidInvalidAsset]];
    }
}

- (void)renderAdWithAdResponse:(NSString *)adReponse withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.delegate = delegate;
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if (adReponse && [adReponse length] != 0) {
        HyBidAdRequest* adRequest = [[HyBidAdRequest alloc]init];
        adRequest.delegate = self;
        adRequest.openRTBAdType = HyBidOpenRTBAdBanner;
        [adRequest processResponseWithJSON:adReponse];
    } else {
        [self.delegate adView:self didFailWithError:[NSError hyBidInvalidAsset]];
        [self createRenderErrorEventWithError:[NSError hyBidInvalidAsset]];
    }
}

- (void)processAdContent:(NSString *)adContent {
    [self cleanUp];
    HyBidSignalDataProcessor *signalDataProcessor = [[HyBidSignalDataProcessor alloc] init];
    signalDataProcessor.delegate = self;
    [signalDataProcessor processSignalData:adContent];
}

- (void)startTracking {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        HyBidImpressionTrackerMethod impressionTrackingMethod;
        if (self.ad.impressionTrackingMethod != nil) {
            if ([self.ad.impressionTrackingMethod  isEqual: @"render"]) {
                impressionTrackingMethod = HyBidAdImpressionTrackerRender;
            } else {
                impressionTrackingMethod = HyBidAdImpressionTrackerViewable;
            }
        } else {
            impressionTrackingMethod = [HyBidViewbilityConfig sharedConfig].impressionTrackerMethod;
        }
        
        if (impressionTrackingMethod == HyBidAdImpressionTrackerViewable) {
            [self.adPresenter startTracking];
        } 

        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
        [[HyBidAdImpression sharedInstance] startImpressionForAd:self.ad];
        #endif
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
    if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
        [renderErrorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        [renderErrorReportingProperties setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:HyBidReportingCommon.ERROR_CODE];
    }
    
    if(renderErrorReportingProperties) {
        [self addCommonPropertiesToReportingDictionary:renderErrorReportingProperties];
        [self reportEvent:HyBidReportingEventType.RENDER_ERROR withProperties:renderErrorReportingProperties];
    }
}

- (void)addSessionReportingProperties:(NSMutableDictionary *)reportingDictionary {
    if (self.zoneID != nil && self.zoneID.length > 0){
        [reportingDictionary setObject:self.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if ([HyBidSessionManager sharedInstance].impressionCounter != nil) {
        [reportingDictionary setObject:[HyBidSessionManager sharedInstance].impressionCounter forKey:HyBidReportingCommon.IMPRESSION_SESSION_COUNT];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey: HyBidReportingCommon.SESSION_DURATION] != nil){
        [reportingDictionary setObject: [[NSUserDefaults standardUserDefaults] stringForKey: HyBidReportingCommon.SESSION_DURATION] forKey: HyBidReportingCommon.SESSION_DURATION];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey: HyBidReportingCommon.AGE_OF_APP] != nil){
        [reportingDictionary setObject:[[NSUserDefaults standardUserDefaults] stringForKey: HyBidReportingCommon.AGE_OF_APP] forKey: HyBidReportingCommon.AGE_OF_APP];
    }
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary {
    if ([HyBidSDKConfig sharedConfig].appToken != nil && [HyBidSDKConfig sharedConfig].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSDKConfig sharedConfig].appToken forKey:HyBidReportingCommon.APPTOKEN];
    }
    if (self.zoneID != nil && self.zoneID.length > 0) {
        [reportingDictionary setObject:self.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if ([HyBidIntegrationType integrationTypeToString:self.adRequest.integrationType] != nil && [HyBidIntegrationType integrationTypeToString:self.adRequest.integrationType].length > 0) {
        [reportingDictionary setObject:[HyBidIntegrationType integrationTypeToString:self.adRequest.integrationType] forKey:HyBidReportingCommon.INTEGRATION_TYPE];
    }
    if (self.adSize != nil && self.adSize.description.length > 0) {
        [reportingDictionary setObject:self.adSize.description forKey:HyBidReportingCommon.AD_SIZE];
    }
    
    NSNumber *assetGroupID = self.ad.isUsingOpenRTB
    ? self.ad.openRTBAssetGroupID
    : self.ad.assetGroupID;

    if(assetGroupID){
        switch (assetGroupID.integerValue) {
            case VAST_MRECT:
            case VAST_INTERSTITIAL: {
                [reportingDictionary setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
                
                NSString *vast = self.ad.isUsingOpenRTB
                ? self.ad.openRtbVast
                : self.ad.vast;
                
                if (vast) {
                    [reportingDictionary setObject:vast forKey:HyBidReportingCommon.CREATIVE];
                }
                break;
            }
            default:
                [reportingDictionary setObject:@"HTML" forKey:HyBidReportingCommon.AD_TYPE];
                if (self.ad.htmlData) {
                    [reportingDictionary setObject:self.ad.htmlData forKey:HyBidReportingCommon.CREATIVE];
                }
                break;
        }
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
                                                                     properties:[NSDictionary dictionaryWithDictionary:properties]];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
}

- (NSTimeInterval)elapsedTimeSince:(NSTimeInterval)timestamp {
    return [[NSDate date] timeIntervalSince1970] - timestamp;
}

- (void)invokeDidLoad {
    if (self.initialLoadTimestamp != -1) {
        [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
    }
    
    [self.loadReportingProperties setObject: @([self.ad hasEndCard]) forKey:HyBidReportingCommon.HAS_END_CARD];
    
    if(self.loadReportingProperties) {
        [self addCommonPropertiesToReportingDictionary:self.loadReportingProperties];
        [self reportEvent:HyBidReportingEventType.LOAD withProperties:self.loadReportingProperties];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
        [self.delegate adViewDidLoad:self];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    if (self.initialLoadTimestamp != -1) {
        [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
    }
    if(self.loadReportingProperties) {
        [self addCommonPropertiesToReportingDictionary:self.loadReportingProperties];
        [self reportEvent:HyBidReportingEventType.LOAD_FAIL withProperties:self.loadReportingProperties];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didFailWithError:)]) {
        [self.delegate adView:self didFailWithError:error];
    }
}

- (void)invokeWillRefresh {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewWillRefresh:)]) {
        [self.delegate adViewWillRefresh:self];
    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
    
    if ([HyBidSDKConfig sharedConfig].test == TRUE) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"You are using Verve HyBid SDK on test mode. Please disabled test mode before submitting your application for production."];
    }
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    if (!ad) {
        [self invokeDidFailWithError:[NSError hyBidNullAd]];
    } else {
        self.ad = ad;
        NSString *vast = self.ad.isUsingOpenRTB ? self.ad.openRtbVast : self.ad.vast;
        if (vast != nil) {
            self.ad.adType = kHyBidAdTypeVideo;
        } else if (self.ad.htmlData != nil) {
            self.ad.adType = kHyBidAdTypeHTML;
        } else {
            self.ad.adType = kHyBidAdTypeUnsupported;
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
    if ([self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        [[HyBidSessionManager sharedInstance] sessionDurationWithZoneID:self.zoneID];
        if(self.sessionReportingProperties) {
            [self addSessionReportingProperties:self.sessionReportingProperties];
            [self reportEvent:HyBidReportingEventType.SESSION_REPORT_INFO withProperties:self.sessionReportingProperties];
        }
    }
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
    [self renderAdForSignalData];
}

- (void)signalDataDidFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

#pragma mark - Utils

- (void)centerView:(UIView *)view inContainerView:(UIView *)containerView withSuperView:(UIView *)superView
{
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:containerView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:containerView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)sizeView:(UIView *)view withSuperView:(UIView *)superView withAdSize:(HyBidAdSize *)adSize
{
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:adSize.height]];
    [superView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:adSize.width]];
}

@end

