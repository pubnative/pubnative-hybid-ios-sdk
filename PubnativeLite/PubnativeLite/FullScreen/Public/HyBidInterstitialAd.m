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

#import "HyBidInterstitialAd.h"
#import "HyBidInterstitialAdRequest.h"
#import "HyBidInterstitialPresenter.h"
#import "HyBidInterstitialPresenterFactory.h"
#import "HyBidLogger.h"
#import "HyBidIntegrationType.h"
#import "HyBidSettings.h"
#import "HyBidAdImpression.h"
#import "HyBidSignalDataProcessor.h"
#import "HyBid.h"
#import "HyBidError.h"
#import "PNLiteAssetGroupType.h"
#import "HyBidRemoteConfigFeature.h"
#import "HyBidRemoteConfigManager.h"

#define TIME_TO_EXPIRE 1800 //30 Minutes as in seconds

@interface HyBidInterstitialAd() <HyBidInterstitialPresenterDelegate, HyBidAdRequestDelegate, HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, weak) NSObject<HyBidInterstitialAdDelegate> *delegate;
@property (nonatomic, strong) HyBidInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;
@property (nonatomic) NSInteger videoSkipOffset;
@property (nonatomic) NSInteger htmlSkipOffset;
@property (nonatomic, assign) NSTimeInterval initialLoadTimestamp;
@property (nonatomic, assign) NSTimeInterval initialRenderTimestamp;
@property (nonatomic, strong) NSMutableDictionary *loadReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *renderReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *renderErrorReportingProperties;
@property (nonatomic) BOOL closeOnFinish;
@property (nonatomic) BOOL isCloseOnFinishSet;

@end

@implementation HyBidInterstitialAd

- (void)dealloc {
    self.ad = nil;
    self.zoneID = nil;
    self.appToken = nil;
    self.delegate = nil;
    self.interstitialPresenter = nil;
    self.interstitialAdRequest = nil;
    self.loadReportingProperties = nil;
    self.renderReportingProperties = nil;
    self.renderErrorReportingProperties = nil;
    [self cleanUp];
}

- (void)cleanUp {
    self.ad = nil;
    self.initialLoadTimestamp = -1;
    self.initialRenderTimestamp = -1;
}

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate {
    return [self initWithZoneID:zoneID withAppToken:nil andWithDelegate:delegate];
}

- (instancetype)initWithZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken andWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate {
    self = [super init];
    if (self) {
        if (![HyBid isInitialized]) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid SDK was not initialized. Please initialize it before creating a HyBidInterstitialAd. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process."];
        }
        self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
        self.interstitialAdRequest.openRTBAdType = HyBidOpenRTBAdVideo;
        self.zoneID = zoneID;
        self.appToken = appToken;
        self.delegate = delegate;
        if ([HyBidSettings sharedInstance].videoSkipOffset > 0) {
            [self setVideoSkipOffset:[HyBidSettings sharedInstance].videoSkipOffset];
        }
        if ([HyBidSettings sharedInstance].htmlSkipOffset > 0) {
            [self setHTMLSkipOffset:[HyBidSettings sharedInstance].htmlSkipOffset];
        }
        self.loadReportingProperties = [NSMutableDictionary new];
        self.renderReportingProperties = [NSMutableDictionary new];
        self.renderErrorReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate {
    return [self initWithZoneID:@"" andWithDelegate:delegate];
}

- (void)load {
    NSString *interstitialString = [HyBidRemoteConfigFeature hyBidRemoteAdFormatToString:HyBidRemoteAdFormat_INTERSTITIAL];
    if (![[[HyBidRemoteConfigManager sharedInstance] featureResolver] isAdFormatEnabled:interstitialString]) {
        [self invokeDidFailWithError:[NSError hyBidDisabledFormatError]];
    } else {
        [self cleanUp];
        self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
        if (!self.zoneID || self.zoneID.length == 0) {
            [self invokeDidFailWithError:[NSError hyBidInvalidZoneId]];
        } else {
            self.isReady = NO;
            [self.interstitialAdRequest setIntegrationType:self.isMediation ? MEDIATION : STANDALONE withZoneID:self.zoneID withAppToken:self.appToken];
            [self.interstitialAdRequest requestAdWithDelegate:self withZoneID:self.zoneID withAppToken:self.appToken];
        }
    }
}

- (void)setSkipOffset:(NSInteger)seconds {
    if(seconds > 0) {
        [self setVideoSkipOffset:seconds];
        [self setHTMLSkipOffset:seconds];
    }
}

- (void)setVideoSkipOffset:(NSInteger)seconds {
    if(seconds > 0) {
        self->_videoSkipOffset = seconds;
    }
}

- (void)setHTMLSkipOffset:(NSInteger)seconds {
    if(seconds > 0) {
        self->_htmlSkipOffset = seconds;
    }
}

- (void)setCloseOnFinish:(BOOL)closeOnFinish {
    self->_closeOnFinish = closeOnFinish;
    self.isCloseOnFinishSet = YES;
}

- (void)prepare {
    if (self.interstitialAdRequest != nil && self.ad != nil) {
        [self.interstitialAdRequest cacheAd:self.ad];
    }
}

- (BOOL)isAutoCacheOnLoad {
    if (self.interstitialAdRequest != nil) {
        return [self.interstitialAdRequest isAutoCacheOnLoad];
    } else {
        return YES;
    }
}

- (void)setIsAutoCacheOnLoad:(BOOL)isAutoCacheOnLoad {
    if (self.interstitialAdRequest != nil) {
        [self.interstitialAdRequest setIsAutoCacheOnLoad:isAutoCacheOnLoad];
    }
}

- (void)setMediationVendor:(NSString *)mediationVendor
{
    if (self.interstitialAdRequest != nil) {
        [self.interstitialAdRequest setMediationVendor:mediationVendor];
    }
}

- (void)prepareAdWithContent:(NSString *)adContent {
    if (adContent && [adContent length] != 0) {
        [self cleanUp];
        self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
        [self processAdContent:adContent];
    } else {
        [self invokeDidFailWithError:[NSError hyBidInvalidAsset]];
    }
}

- (void)prepareVideoTagFrom:(NSString *)url {
    [self cleanUp];
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    [self.interstitialAdRequest requestVideoTagFrom:url andWithDelegate:self];
}

- (void)prepareCustomMarkupFrom:(NSString *)markup {
    [self cleanUp];
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    [self.interstitialAdRequest processCustomMarkupFrom:markup andWithDelegate:self];
}

- (void)processAdContent:(NSString *)adContent {
    HyBidSignalDataProcessor *signalDataProcessor = [[HyBidSignalDataProcessor alloc] init];
    signalDataProcessor.delegate = self;
    [signalDataProcessor processSignalData:adContent];
}

- (void)show {
    if (self.isReady) {
        self.initialRenderTimestamp = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval adExpireTime = self.initialLoadTimestamp + TIME_TO_EXPIRE;
        if (self.initialRenderTimestamp < adExpireTime) {
            [self.interstitialPresenter show];
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad has expired"];
            [self cleanUp];
            [self invokeDidFailWithError:[NSError hyBidExpiredAd]];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Interstitial not ready."];
    }
}

- (void)showFromViewController:(UIViewController *)viewController {
    if (self.isReady) {
        self.initialRenderTimestamp = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval adExpireTime = self.initialLoadTimestamp + TIME_TO_EXPIRE;
        if (self.initialRenderTimestamp < adExpireTime) {
            [self.interstitialPresenter showFromViewController:viewController];
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad has expired"];
            [self cleanUp];
            [self invokeDidFailWithError:[NSError hyBidExpiredAd]];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Interstitial not ready."];
    }
}

- (void)hide {
    [self.interstitialPresenter hide];
}

- (void)renderAd:(HyBidAd *)ad {
    HyBidInterstitialPresenterFactory *interstitalPresenterFactory = [[HyBidInterstitialPresenterFactory alloc] init];
    if (!self.isCloseOnFinishSet && [HyBidSettings sharedInstance].isCloseOnFinishSet) {
        self.interstitialPresenter = [interstitalPresenterFactory createInterstitalPresenterWithAd:ad withVideoSkipOffset:self.videoSkipOffset withHTMLSkipOffset:self.htmlSkipOffset withCloseOnFinish:[HyBidSettings sharedInstance].closeOnFinish withDelegate:self];
    } else {
        self.interstitialPresenter = [interstitalPresenterFactory createInterstitalPresenterWithAd:ad withVideoSkipOffset:self.videoSkipOffset withHTMLSkipOffset:self.htmlSkipOffset withCloseOnFinish:self.closeOnFinish withDelegate:self];
    }
    if (!self.interstitialPresenter) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid interstitial presenter."];
        [self invokeDidFailWithError:[NSError hyBidUnsupportedAsset]];
        [self.renderErrorReportingProperties setObject:[NSError hyBidUnsupportedAsset].localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        [self.renderErrorReportingProperties setObject:[NSString stringWithFormat:@"%ld",[NSError hyBidUnsupportedAsset].code] forKey:HyBidReportingCommon.ERROR_CODE];
        [self addCommonPropertiesToReportingDictionary:self.renderErrorReportingProperties];
        [self reportEvent:HyBidReportingEventType.RENDER_ERROR withProperties:self.renderErrorReportingProperties];
        return;
    } else {
        [self.interstitialPresenter load];
    }
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary {
    if ([HyBidSettings sharedInstance].appToken != nil && [HyBidSettings sharedInstance].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSettings sharedInstance].appToken forKey:HyBidReportingCommon.APPTOKEN];
    }
    if (self.zoneID != nil && self.zoneID.length > 0) {
        [reportingDictionary setObject:self.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if ([HyBidIntegrationType integrationTypeToString:self.interstitialAdRequest.integrationType] != nil && [HyBidIntegrationType integrationTypeToString:self.interstitialAdRequest.integrationType].length > 0) {
        [reportingDictionary setObject:[HyBidIntegrationType integrationTypeToString:self.interstitialAdRequest.integrationType] forKey:HyBidReportingCommon.INTEGRATION_TYPE];
    }
    switch (self.ad.assetGroupID.integerValue) {
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
}

- (void)reportEvent:(NSString *)eventType withProperties:(NSMutableDictionary *)properties {
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc] initWith:eventType
                                                                       adFormat:HyBidReportingAdFormat.FULLSCREEN
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
    
    [self.loadReportingProperties setObject: @([self.ad hasEndCard]) forKey:HyBidReportingCommon.HAS_END_CARD];
    
    [self addCommonPropertiesToReportingDictionary:self.loadReportingProperties];
    [self reportEvent:HyBidReportingEventType.LOAD withProperties:self.loadReportingProperties];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidLoad)]) {
        [self.delegate interstitialDidLoad];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    if (self.initialLoadTimestamp != -1) {
        [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
    }
    [self addCommonPropertiesToReportingDictionary:self.loadReportingProperties];
    [self reportEvent:HyBidReportingEventType.LOAD_FAIL withProperties:self.loadReportingProperties];
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidFailWithError:)]) {
        [self.delegate interstitialDidFailWithError:error];
    }
}

- (void)invokeDidTrackImpression {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidTrackImpression)]) {
        [self.delegate interstitialDidTrackImpression];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
        [[HyBidAdImpression sharedInstance] startImpressionForAd:self.ad];
#endif
    }
}

- (HyBidSkAdNetworkModel *)skAdNetworkModel {
    HyBidSkAdNetworkModel *result = nil;
    if (self.ad) {
        result = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
    }
    return result;
}

- (void)invokeDidTrackClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidTrackClick)]) {
        [self.delegate interstitialDidTrackClick];
    }
}

- (void)invokeDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidDismiss)]) {
        [self.delegate interstitialDidDismiss];
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
        [self renderAd:ad];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

#pragma mark HyBidInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter {
    self.isReady = YES;
    [self invokeDidLoad];
}

- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter {
    if (self.initialRenderTimestamp != -1) {
        [self.renderReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialRenderTimestamp]] forKey:HyBidReportingCommon.RENDER_TIME];
    }
    [self addCommonPropertiesToReportingDictionary:self.renderReportingProperties];
    [self reportEvent:HyBidReportingEventType.RENDER withProperties:self.renderReportingProperties];
    [self invokeDidTrackImpression];
}

- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self invokeDidTrackClick];
}

- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter {
    [self invokeDidDismiss];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
    [[HyBidAdImpression sharedInstance] endImpressionForAd:self.ad];
#endif
}

#pragma mark - HyBidSignalDataProcessorDelegate

- (void)signalDataDidFinishWithAd:(HyBidAd *)ad {
    self.ad = ad;
    [self renderAd:self.ad];
}

- (void)signalDataDidFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

@end
