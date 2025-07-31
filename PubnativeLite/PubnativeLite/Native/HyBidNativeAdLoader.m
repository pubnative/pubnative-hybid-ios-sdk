// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidNativeAdLoader.h"
#import "HyBidNativeAdRequest.h"
#import "HyBidIntegrationType.h"
#import "HyBidError.h"
#import "HyBidSignalDataProcessor.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidNativeAdLoader() <HyBidAdRequestDelegate, HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) HyBidNativeAdRequest *nativeAdRequest;
@property (nonatomic, weak) NSObject <HyBidNativeAdLoaderDelegate> *delegate;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSString *appToken;

@property (nonatomic, weak) NSTimer *autoRefreshTimer;
@property (nonatomic, assign) BOOL shouldRunAutoRefresh;
@property (nonatomic, strong) HyBidAdSessionData *adSessionData;

@end

@implementation HyBidNativeAdLoader

@synthesize autoRefreshTimeInSeconds = _autoRefreshTimeInSeconds;

- (void)dealloc {
    self.nativeAdRequest = nil;
    self.delegate = nil;
    self.zoneID = nil;
    self.appToken = nil;
    [self stopAutoRefresh];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nativeAdRequest = [[HyBidNativeAdRequest alloc] init];
    }
    return self;
}

- (void)loadNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID {
    [self loadNativeAdWithDelegate:delegate withZoneID:zoneID withAppToken:nil];
}

- (void)loadNativeExchangeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID {
    [self loadNativeAdWithDelegate:delegate withZoneID:zoneID withAppToken:nil];
}

- (void)loadNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken {
    self.delegate = delegate;
    self.zoneID = zoneID;
    self.appToken = appToken;
    if (self.adSessionData == nil) {
        self.adSessionData = [[HyBidAdSessionData alloc] init];
    }
    [self requestAd];
}

- (void)prepareNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withContent:(NSString *)adContent {
    self.delegate = delegate;
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

- (void)requestAd {
    if (self.zoneID && [self.zoneID length] > 0) {
        [self.nativeAdRequest setIntegrationType:self.isMediation ? MEDIATION : STANDALONE withZoneID:self.zoneID withAppToken:self.appToken];
        [self.nativeAdRequest requestAdWithDelegate:self withZoneID:self.zoneID withAppToken:self.appToken];
        self.shouldRunAutoRefresh = YES;
        [self setupAutoRefreshTimerIfNeeded];
    }
}

- (void)setupAutoRefreshTimerIfNeeded {
    if (self.autoRefreshTimer == nil && self.autoRefreshTimeInSeconds > 0) {
        self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshTimeInSeconds target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
}

- (void)refresh {
    [self invokeWillRefresh];
    [self requestAd];
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

- (void)invokeDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderDidLoadWithNativeAd:)]) {
        [self.delegate nativeLoaderDidLoadWithNativeAd:nativeAd];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];

    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderDidFailWithError:)]) {
        [self.delegate nativeLoaderDidFailWithError:error];
    }
}

- (void)invokeWillRefresh {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderWillRefresh)]) {
        [self.delegate nativeLoaderWillRefresh];
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
        [self loadNativeAdWithRequest:request ad:ad];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

#pragma mark - HyBidSignalDataProcessorDelegate

- (void)signalDataDidFinishWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Signal data loaded with ad: %@", ad]];
    if (!ad) {
        [self invokeDidFailWithError:[NSError hyBidNullAd]];
    } else {
        [self loadNativeAdWithRequest:nil ad:ad];
    }
}

- (void)signalDataDidFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

- (void)loadNativeAdWithRequest:(HyBidAdRequest *)request ad:(HyBidAd *)ad {
    self.adSessionData = [ATOMManager createAdSessionDataFrom:request ad:ad];
    HyBidNativeAd *nativeAd = [[HyBidNativeAd alloc] initWithAd:ad];
    nativeAd.adSessionData = self.adSessionData;
    [self invokeDidLoadWithNativeAd:nativeAd];
}

@end
