//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidRewardedAd.h"
#import "HyBidRewardedAdRequest.h"
#import "HyBidRewardedPresenter.h"
#import "HyBidRewardedPresenterFactory.h"
#import "HyBidLogger.h"
#import "HyBidAdImpression.h"
#import "HyBidIntegrationType.h"
#import "HyBidSignalDataProcessor.h"
#import "HyBid.h"
#import "HyBidError.h"
#import "PNLiteAssetGroupType.h"

@interface HyBidRewardedAd() <HyBidRewardedPresenterDelegate, HyBidAdRequestDelegate, HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, weak) NSObject<HyBidRewardedAdDelegate> *delegate;
@property (nonatomic, strong) HyBidRewardedPresenter *rewardedPresenter;
@property (nonatomic, strong) HyBidRewardedAdRequest *rewardedAdRequest;
@property (nonatomic, assign) NSTimeInterval initialLoadTimestamp;
@property (nonatomic, assign) NSTimeInterval initialRenderTimestamp;
@property (nonatomic, strong) NSMutableDictionary *loadReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *renderReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *renderErrorReportingProperties;

@end

@implementation HyBidRewardedAd

- (void)dealloc {
    self.ad = nil;
    self.zoneID = nil;
    self.delegate = nil;
    self.rewardedPresenter = nil;
    self.rewardedAdRequest = nil;
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

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate {
    self = [super init];
    if (self) {
        if (![HyBid isInitialized]) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid SDK was not initialized. Please initialize it before creating a HyBidRewardedAd. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process."];
        }
        self.rewardedAdRequest = [[HyBidRewardedAdRequest alloc] init];
        self.rewardedAdRequest.openRTBAdType = HyBidOpenRTBAdVideo;
        self.zoneID = zoneID;
        self.delegate = delegate;
        self.loadReportingProperties = [NSMutableDictionary new];
        self.renderReportingProperties = [NSMutableDictionary new];
        self.renderErrorReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate {
    return [self initWithZoneID:@"" andWithDelegate:delegate];
}

- (void)load {
    [self cleanUp];
    self.initialLoadTimestamp = [[NSDate date] timeIntervalSince1970];
    if (!self.zoneID || self.zoneID.length == 0) {
        [self invokeDidFailWithError:[NSError hyBidInvalidZoneId]];
    } else {
        self.isReady = NO;
        [self.rewardedAdRequest setIntegrationType: self.isMediation ? MEDIATION : STANDALONE withZoneID: self.zoneID];
        [self.rewardedAdRequest requestAdWithDelegate:self withZoneID:self.zoneID];
    }
}

- (void)prepare
{
    if (self.rewardedAdRequest != nil && self.ad != nil) {
        [self.rewardedAdRequest cacheAd:self.ad];
    }
}

- (BOOL)isAutoCacheOnLoad {
    if (self.rewardedAdRequest != nil) {
        return [self.rewardedAdRequest isAutoCacheOnLoad];
    } else {
        return YES;
    }
}

- (void)setIsAutoCacheOnLoad:(BOOL)isAutoCacheOnLoad
{
    if (self.rewardedAdRequest != nil) {
        [self.rewardedAdRequest setIsAutoCacheOnLoad:isAutoCacheOnLoad];
    }
}

- (void)prepareAdWithContent:(NSString *)adContent {
    if (adContent && [adContent length] != 0) {
        [self processAdContent:adContent];
    } else {
        [self invokeDidFailWithError:[NSError hyBidInvalidAsset]];
    }
}

- (void)processAdContent:(NSString *)adContent {
    HyBidSignalDataProcessor *signalDataProcessor = [[HyBidSignalDataProcessor alloc] init];
    signalDataProcessor.delegate = self;
    [signalDataProcessor processSignalData:adContent];
}

- (void)show {
    if (self.isReady) {
        self.initialRenderTimestamp = [[NSDate date] timeIntervalSince1970];
        [self.rewardedPresenter show];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Rewarded not ready."];
    }
}

- (void)showFromViewController:(UIViewController *)viewController {
    if (self.isReady) {
        self.initialRenderTimestamp = [[NSDate date] timeIntervalSince1970];
        [self.rewardedPresenter showFromViewController:viewController];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Rewarded not ready."];
    }
}

- (void)hide {
    [self.rewardedPresenter hide];
}

- (void)renderAd:(HyBidAd *)ad {
    HyBidRewardedPresenterFactory *rewardedPresenterFactory = [[HyBidRewardedPresenterFactory alloc] init];
    self.rewardedPresenter = [rewardedPresenterFactory createRewardedPresenterWithAd:ad withDelegate:self];
    if (!self.rewardedPresenter) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid rewarded presenter."];
        [self invokeDidFailWithError:[NSError hyBidUnsupportedAsset]];
        [self.renderErrorReportingProperties setObject:[NSError hyBidUnsupportedAsset].localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        [self.renderErrorReportingProperties setObject:[NSString stringWithFormat:@"%ld",[NSError hyBidUnsupportedAsset].code] forKey:HyBidReportingCommon.ERROR_CODE];
        [self addCommonPropertiesToReportingDictionary:self.renderErrorReportingProperties];
        [self reportEvent:HyBidReportingEventType.RENDER_ERROR withProperties:self.renderErrorReportingProperties];
        return;
    } else {
        [self.rewardedPresenter load];
    }
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary {
    [reportingDictionary setObject:[HyBidSettings sharedInstance].appToken forKey:HyBidReportingCommon.APPTOKEN];
    [reportingDictionary setObject:self.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    [reportingDictionary setObject:[HyBidIntegrationType integrationTypeToString:self.rewardedAdRequest.integrationType] forKey:HyBidReportingCommon.INTEGRATION_TYPE];
    switch (self.ad.assetGroupID.integerValue) {
        case VAST_REWARDED:
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
                                                                       adFormat:HyBidReportingAdFormat.REWARDED
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidLoad)]) {
        [self.delegate rewardedDidLoad];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    if (self.initialLoadTimestamp != -1) {
        [self.loadReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialLoadTimestamp]] forKey:HyBidReportingCommon.TIME_TO_LOAD];
    }
    [self addCommonPropertiesToReportingDictionary:self.loadReportingProperties];
    [self reportEvent:HyBidReportingEventType.LOAD_FAIL withProperties:self.loadReportingProperties];
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidFailWithError:)]) {
        [self.delegate rewardedDidFailWithError:error];
    }
}

- (void)invokeDidTrackImpression {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidTrackImpression)]) {
        [self.delegate rewardedDidTrackImpression];
        
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidTrackClick)]) {
        [self.delegate rewardedDidTrackClick];
    }
}

- (void)invokeOnReward {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReward)]) {
        [self.delegate onReward];
    }
}

- (void)invokeDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidDismiss)]) {
        [self.delegate rewardedDidDismiss];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500
        [[HyBidAdImpression sharedInstance] endImpressionForAd:self.ad];
#endif
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
        self.ad.adType = kHyBidAdTypeVideo;
        [self renderAd:ad];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

#pragma mark HyBidRewardedPresenterDelegate

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter {
    self.isReady = YES;
    [self invokeDidLoad];
}

- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.initialRenderTimestamp != -1) {
        [self.renderReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialRenderTimestamp]] forKey:HyBidReportingCommon.RENDER_TIME];
    }
    [self addCommonPropertiesToReportingDictionary:self.renderReportingProperties];
    [self reportEvent:HyBidReportingEventType.RENDER withProperties:self.renderReportingProperties];
    [self invokeDidTrackImpression];
}

- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter {
    [self invokeDidTrackClick];
}

- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter {
    [self invokeDidDismiss];
}

- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter {
    [self invokeOnReward];
}

#pragma mark - HyBidSignalDataProcessorDelegate

- (void)signalDataDidFinishWithAd:(HyBidAd *)ad {
    self.ad = ad;
    self.ad.adType = kHyBidAdTypeVideo;
    [self renderAd:self.ad];
}

- (void)signalDataDidFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

@end
