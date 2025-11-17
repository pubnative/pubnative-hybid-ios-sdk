// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
@property (nonatomic, strong) HyBidAdSessionData *adSessionData;

@property (nonatomic, weak) NSTimer *autoRefreshTimer;
@property (nonatomic, strong) NSTimer *skanImpressionTimer;
@property (nonatomic, assign) BOOL shouldRunAutoRefresh;
@property (nonatomic, assign) BOOL markup;
@property (nonatomic, assign) BOOL isUsingOpenRTB;

@end

@implementation HyBidAdView

@synthesize autoRefreshTimeInSeconds = _autoRefreshTimeInSeconds;

- (void)dealloc {
    [self stopTracking];
    if (self.skanImpressionTimer) {
        [self stopSKANImpressionTracking];
    }
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
    self.isUsingOpenRTB = NO;
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
        self.adSessionData = [[HyBidAdSessionData alloc] init];
    }
    return self;
}

- (instancetype)initWithSize:(HyBidAdSize *)adSize {
    self = [self initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)];
    if (self) {
        self.adSize = adSize;
        if (self.adSessionData == nil) {
            self.adSessionData = [[HyBidAdSessionData alloc] init];
        }
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
    self.adRequest.isUsingOpenRTB = self.isUsingOpenRTB;
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

- (void)setOpenRTBAdTypeWithAdFormat:(HyBidOpenRTBAdType)adFormat {
    self.adRequest.openRTBAdType = adFormat;
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
    self.isUsingOpenRTB = true;
}

- (void)setOpenRTBToFalse {
    self.isUsingOpenRTB = false;
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
    [[adView.widthAnchor constraintEqualToConstant:self.adSize.width] setActive: YES];
    [[adView.heightAnchor constraintEqualToConstant:self.adSize.height] setActive: YES];
    [[adView.centerXAnchor constraintEqualToAnchor:[self containerViewController].view.centerXAnchor] setActive: YES];
    if (@available(iOS 11.0, *)) {
        [[position == BANNER_POSITION_TOP ? adView.topAnchor : adView.bottomAnchor
                                      constraintEqualToAnchor:
          position == BANNER_POSITION_TOP ? [self containerViewController].view.safeAreaLayoutGuide.topAnchor : [self containerViewController].view.safeAreaLayoutGuide.bottomAnchor constant:position == BANNER_POSITION_TOP ? 8.0 : -8.0] setActive: YES];
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
    
    if ([HyBidSDKConfig sharedConfig].reporting) {
        if (self.initialRenderTimestamp != -1) {
            [self.renderReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialRenderTimestamp]] forKey:HyBidReportingCommon.RENDER_TIME];
        }
        if (self.renderReportingProperties) {
            [self.renderReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:self.ad withRequest:self.adRequest]];
            [self addPositionPropertyToReportingDictionary:self.renderReportingProperties];
            [self reportEvent:HyBidReportingEventType.RENDER withProperties:self.renderReportingProperties];
        }
    }
}

- (void)renderAd {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    self.initialLoadTimestamp = currentTime;
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

- (void)renderAdWithAdResponseOpenRTB:(NSString *)adReponse withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    self.isUsingOpenRTB = true;
    [self renderAdWithAdResponse:adReponse withDelegate:delegate];
}

- (void)renderAdWithAdResponse:(NSString *)adReponse withDelegate:(NSObject<HyBidAdViewDelegate> *)delegate {
    [self cleanUp];
    self.delegate = delegate;
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if (adReponse && [adReponse length] != 0) {
        HyBidAdRequest* adRequest = [[HyBidAdRequest alloc]init];
        adRequest.isUsingOpenRTB = self.isUsingOpenRTB;
        adRequest.delegate = self;
        adRequest.adSize = self.adSize;
        if ([self.adSize isEqualTo:HyBidAdSize.SIZE_300x250]){
            adRequest.placement = HyBidDemoAppPlacementMRect;
            adRequest.openRTBAdType = HyBidOpenRTBAdVideo;
        }
        if ([self.adSize isEqualTo:HyBidAdSize.SIZE_300x50] || [self.adSize isEqualTo:HyBidAdSize.SIZE_320x50]){
            adRequest.placement = HyBidDemoAppPlacementBanner;
            adRequest.openRTBAdType = HyBidOpenRTBAdBanner;
        }
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
        [[HyBidAdImpression sharedInstance] startSKANImpressionForAd:self.ad];
#endif
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 170400
        [[HyBidAdImpression sharedInstance] startAAKImpressionForAd:self.ad adFormat:HyBidReportingAdFormat.BANNER];
#endif
        
    }
}

- (void)stopTracking {
    [self.adPresenter stopTracking];
}

- (HyBidAdPresenter *)createAdPresenter {
    self.initialRenderTimestamp = [[NSDate date] timeIntervalSince1970];
    HyBidBannerPresenterFactory *bannerPresenterFactory = [[HyBidBannerPresenterFactory alloc] init];
    return [bannerPresenterFactory createAdPresenterWithAd:self.ad withDelegate:self];
}

- (void)createRenderErrorEventWithError:(NSError *)error {
    if ([HyBidSDKConfig sharedConfig].reporting) {
        NSMutableDictionary *renderErrorReportingProperties = [NSMutableDictionary new];
        if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
            [renderErrorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
            [renderErrorReportingProperties setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:HyBidReportingCommon.ERROR_CODE];
        }
        
        if(renderErrorReportingProperties) {
            [renderErrorReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:self.ad withRequest:self.adRequest]];
            [self addPositionPropertyToReportingDictionary:renderErrorReportingProperties];
            [self reportEvent:HyBidReportingEventType.RENDER_ERROR withProperties:renderErrorReportingProperties];
        }
    }
}

- (void)addSessionReportingProperties:(NSMutableDictionary *)reportingDictionary {
    if (self.zoneID != nil && self.zoneID.length > 0){
        [reportingDictionary setObject:self.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if ([HyBidSessionManager sharedInstance].safeImpressionCounter != nil) {
        [reportingDictionary setObject:[HyBidSessionManager sharedInstance].safeImpressionCounter forKey:HyBidReportingCommon.IMPRESSION_SESSION_COUNT];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey: HyBidReportingCommon.SESSION_DURATION] != nil){
        [reportingDictionary setObject: [[NSUserDefaults standardUserDefaults] stringForKey: HyBidReportingCommon.SESSION_DURATION] forKey: HyBidReportingCommon.SESSION_DURATION];
    }
    if ([[HyBidSessionManager sharedInstance] getAgeOfApp] != nil){
        [reportingDictionary setObject:[[HyBidSessionManager sharedInstance] getAgeOfApp] forKey: HyBidReportingCommon.AGE_OF_APP];
    }
}

- (void)addPositionPropertyToReportingDictionary:(NSMutableDictionary *)reportingDictionary {
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
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc] initWith:eventType
                                                                           adFormat:HyBidReportingAdFormat.BANNER
                                                                         properties:[NSDictionary dictionaryWithDictionary:properties]];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

- (NSTimeInterval)elapsedTimeSince:(NSTimeInterval)timestamp {
    return [[NSDate date] timeIntervalSince1970] - timestamp;
}

- (void)invokeDidLoad {
    if ([HyBidSDKConfig sharedConfig].reporting) {
        if (self.initialLoadTimestamp != -1) {
            [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
        }
        
        [self.loadReportingProperties setObject: @([self.ad hasEndCard]) forKey:HyBidReportingCommon.HAS_END_CARD];
        
        if(self.loadReportingProperties) {
            [self.loadReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:self.ad withRequest:self.adRequest]];
            [self addPositionPropertyToReportingDictionary:self.loadReportingProperties];
            [self reportEvent:HyBidReportingEventType.LOAD withProperties:self.loadReportingProperties];
        }
    }
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.LOAD ad:self.ad];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
        [self.delegate adViewDidLoad:self];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    if ([HyBidSDKConfig sharedConfig].reporting) {
        if (self.initialLoadTimestamp != -1) {
            [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
        }
        if(self.loadReportingProperties) {
            [self.loadReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:self.ad withRequest:self.adRequest]];
            [self addPositionPropertyToReportingDictionary:self.loadReportingProperties];
            [self reportEvent:HyBidReportingEventType.LOAD_FAIL withProperties:self.loadReportingProperties];
        }
    }
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.LOAD_FAIL ad:self.ad errorCode:error.code];
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
        self.adSessionData = [ATOMManager createAdSessionDataFromRequest:request ad:ad];
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
    adPresenter.adSessionData = self.adSessionData;
}

- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter {
    [self.delegate adViewDidTrackImpression:self];
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.SHOW ad:self.ad];
    if ([self.delegate respondsToSelector:@selector(adViewDidTrackImpression:)]) {
        [[HyBidSessionManager sharedInstance] sessionDurationWithZoneID:self.zoneID];
        if ([HyBidSDKConfig sharedConfig].reporting) {
            if (self.sessionReportingProperties) {
                [self addSessionReportingProperties:self.sessionReportingProperties];
                [self reportEvent:HyBidReportingEventType.SESSION_REPORT_INFO withProperties:self.sessionReportingProperties];
            }
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopSKANImpressionTracking];
    });
}

- (void) stopSKANImpressionTracking {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
    [[HyBidAdImpression sharedInstance] endSKANImpressionForAd:self.ad];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 170400
    [[HyBidAdImpression sharedInstance] endAAKImpressionForAd:self.ad adFormat:HyBidReportingAdFormat.BANNER];
#endif
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
    self.adSessionData = [ATOMManager createAdSessionDataFromRequest:nil ad:ad];
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

