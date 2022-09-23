//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "AppLovinMediationVerveCustomNetworkAdapter.h"

#define VERVE_ADAPTER_VERSION @"2.16.0.0"
#define MAX_MEDIATION_VENDOR @"m"
#define PARAM_APP_TOKEN @"pn_app_token"
#define PARAM_TEST_MODE @"pn_test"
#define DUMMY_TOKEN @"dummytoken"

@interface AppLovinMediationVerveBannerDelegate : NSObject<HyBidAdViewDelegate>
@property (nonatomic, weak) AppLovinMediationVerveCustomNetworkAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface AppLovinMediationVerveInterstitialAdDelegate : NSObject<HyBidInterstitialAdDelegate>
@property (nonatomic, weak) AppLovinMediationVerveCustomNetworkAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface AppLovinMediationVerveRewardedAdsDelegate : NSObject<HyBidRewardedAdDelegate>
@property (nonatomic, weak) AppLovinMediationVerveCustomNetworkAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface AppLovinMediationVerveNativeAdDelegate : NSObject<HyBidNativeAdLoaderDelegate, HyBidNativeAdFetchDelegate, HyBidNativeAdDelegate>
@property (nonatomic, weak) AppLovinMediationVerveCustomNetworkAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAVerveMediationNativeAd : MANativeAd
@property (nonatomic, weak) AppLovinMediationVerveCustomNetworkAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

@interface AppLovinMediationVerveCustomNetworkAdapter()

// Banner
@property (nonatomic, strong) HyBidAdView *adViewAd;
@property (nonatomic, strong) AppLovinMediationVerveBannerDelegate *adViewAdapterDelegate;

// Interstitial
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) AppLovinMediationVerveInterstitialAdDelegate *interstitialAdapterDelegate;

// Rewarded
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (nonatomic, strong) AppLovinMediationVerveRewardedAdsDelegate *rewardedAdapterDelegate;

// Native
@property (nonatomic, strong) HyBidNativeAd *nativeAd;
@property (nonatomic, strong) AppLovinMediationVerveNativeAdDelegate *nativeAdAdapterDelegate;

@end

@implementation AppLovinMediationVerveCustomNetworkAdapter

static ALAtomicBoolean *ALVerveInitialized;
static MAAdapterInitializationStatus ALVerveInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALVerveInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - ALMediationAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALVerveInitialized compareAndSet: NO update: YES] )
    {
        ALVerveInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *appToken = [parameters.customParameters al_stringForKey: PARAM_APP_TOKEN defaultValue: DUMMY_TOKEN];
        [self log: @"Initializing Verve SDK with app token: %@...", appToken];
        
        if ( [parameters isTesting] )
        {
            [HyBid setTestMode: YES];
            [HyBidLogger setLogLevel: HyBidLogLevelDebug];
        }
        
        [HyBid setLocationUpdates: NO];
        [HyBid initWithAppToken: appToken completion:^(BOOL success) {
            [self log: @"Verve SDK initialized"];
            ALVerveInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            
            completionHandler(ALVerveInitializationStatus, nil);
        }];
    }
    else
    {
        [self log: @"Verve attempted to intialize already - marking initialization as %ld", ALVerveInitializationStatus];
        completionHandler(ALVerveInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [HyBid getSDKVersionInfo];
}

- (NSString *)adapterVersion
{
    return VERVE_ADAPTER_VERSION;
}

- (void)destroy
{
    [super destroy];
}

#pragma mark - Shared Methods

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = parameters.hasUserConsent;
        if ( hasUserConsent )
        {
            NSString* verveGDPRConsentString = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
            if ( !verveGDPRConsentString || [verveGDPRConsentString isEqualToString:@""] )
            {
                [[HyBidUserDataManager sharedInstance] setIABGDPRConsentString: hasUserConsent.boolValue ? @"1" : @"0"];
            }
        }
        else { /* Don't do anything if huc value not set */ }
    }
        
    NSNumber *isAgeRestrictedUser = parameters.ageRestrictedUser;
    if ( isAgeRestrictedUser )
    {
        [HyBid setCoppa: isAgeRestrictedUser.boolValue];
    }
        
    if ( ALSdk.versionCode >= 61100 )
    {
        NSString* verveUSPrivacyString = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
            
        if ( !verveUSPrivacyString || [verveUSPrivacyString isEqualToString:@""] )
        {
            NSNumber *isDoNotSell = parameters.doNotSell;
            if ( isDoNotSell && isDoNotSell.boolValue )
            {
                [[HyBidUserDataManager sharedInstance] setIABUSPrivacyString: @"1NYN"];
            }
            else
            {
                [[HyBidUserDataManager sharedInstance] removeIABUSPrivacyString];
            }
        }
    }
}

- (void)updateMuteStateForParameters:(id<MAAdapterResponseParameters>)parameters
{
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    if ( [serverParameters al_containsValueForKey: @"is_muted"] )
    {
        BOOL muted = [serverParameters al_numberForKey: @"is_muted"].boolValue;
        if ( muted )
        {
            [HyBid setVideoAudioStatus: HyBidAudioStatusMuted];
        }
        else
        {
            [HyBid setVideoAudioStatus: HyBidAudioStatusDefault];
        }
    }
}

- (HyBidAdSize *)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return HyBidAdSize.SIZE_320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return HyBidAdSize.SIZE_728x90;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return HyBidAdSize.SIZE_300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return HyBidAdSize.SIZE_320x50;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)verveError
{
    NSInteger verveErrorCode = verveError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( verveErrorCode )
    {
        case 1: // No Fill
        case 6: // Null Ad
            adapterError = MAAdapterError.noFill;
            break;
        case 2: // Parse Error
        case 3: // Server Error
            adapterError = MAAdapterError.serverError;
            break;
        case 4: // Invalid Asset
        case 5: // Unsupported Asset
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 7: // Invalid Ad
        case 8: // Invalid Zone ID
        case 9: // Invalid Signal Data
            adapterError = MAAdapterError.badRequest;
            break;
        case 10: // Not Initialized
            adapterError = MAAdapterError.notInitialized;
            break;
        case 11: // Auction No Ad
        case 12: // Rendering Banner
        case 13: // Rendering Interstitial
        case 14: // Rendering Rewarded
            adapterError = MAAdapterError.adNotReady;
            break;
        case 15: // Mraid Player
        case 16: // Vast Player
        case 17: // Tracking URL
        case 18: // Tracking JS
        case 19: // Invalid URL
        case 20: // Internal
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: verveErrorCode
               thirdPartySdkErrorMessage: verveError.localizedDescription];
#pragma clang diagnostic pop
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad view ad...", adFormat.label];
    
    NSString* zoneId = [parameters thirdPartyAdPlacementIdentifier];
    NSString *appToken = [parameters.customParameters al_stringForKey: PARAM_APP_TOKEN];
    NSString *testMode = [parameters.customParameters al_stringForKey: PARAM_TEST_MODE defaultValue:@"0"];

    if (!zoneId || ![zoneId al_isValidString] || !appToken || ![appToken al_isValidString]) {
        [delegate didFailToLoadAdViewAdWithError:[MAAdapterError internalError]];
    } else {
        if ( [testMode isEqualToString:@"1"]) {
            // Test mode will remain active throughout this app session.
            [HyBid setTestMode: YES];
            [HyBidLogger setLogLevel: HyBidLogLevelDebug];
        }
        if ([[[HyBidSettings sharedInstance] appToken] isEqualToString:appToken] && [HyBid isInitialized]) {
            [self requestBanner:parameters adFormat:adFormat appToken:appToken zoneId:zoneId andNotify:delegate];
        } else {
            [HyBid initWithAppToken: appToken completion:^(BOOL success) {
                [self requestBanner:parameters adFormat:adFormat appToken:appToken zoneId:zoneId andNotify:delegate];
            }];
        }
    }
}

- (void)requestBanner:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat appToken:(NSString *)appToken zoneId:(NSString*) zoneId andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self updateConsentWithParameters: parameters];
    [self updateMuteStateForParameters: parameters];
    
    self.adViewAd = [[HyBidAdView alloc] initWithSize: [self sizeFromAdFormat: adFormat]];
    self.adViewAd.isMediation = YES;
    [self.adViewAd setMediationVendor: MAX_MEDIATION_VENDOR];
    self.adViewAdapterDelegate = [[AppLovinMediationVerveBannerDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adViewAd.delegate = self.adViewAdapterDelegate;
    
    [self.adViewAd loadWithZoneID:zoneId withAppToken:appToken andWithDelegate:self.adViewAdapterDelegate];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad"];
    
    NSString* zoneId = [parameters thirdPartyAdPlacementIdentifier];
    NSString *appToken = [parameters.customParameters al_stringForKey: PARAM_APP_TOKEN];
    
    if (!zoneId || ![zoneId al_isValidString] || !appToken || ![appToken al_isValidString]) {
        [delegate didFailToLoadInterstitialAdWithError:[MAAdapterError internalError]];
    } else {
        if ([[[HyBidSettings sharedInstance] appToken] isEqualToString:appToken] && [HyBid isInitialized]) {
            [self requestInterstitial:parameters appToken:appToken zoneId:zoneId andNotify:delegate];
        } else {
            [HyBid initWithAppToken: appToken completion:^(BOOL success) {
                [self requestInterstitial:parameters appToken:appToken zoneId:zoneId andNotify:delegate];
            }];
        }
    }
}

- (void)requestInterstitial:(id<MAAdapterResponseParameters>)parameters appToken:(NSString *)appToken zoneId:(NSString*) zoneId andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self updateConsentWithParameters: parameters];
    [self updateMuteStateForParameters: parameters];
    
    self.interstitialAdapterDelegate = [[AppLovinMediationVerveInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:zoneId withAppToken:appToken andWithDelegate:self.interstitialAdapterDelegate];
    self.interstitialAd.isMediation = YES;
    [self.interstitialAd setMediationVendor: MAX_MEDIATION_VENDOR];

    [self.interstitialAd load];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( [self.interstitialAd isReady] )
    {
        [self.interstitialAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad"];
    
    NSString* zoneId = [parameters thirdPartyAdPlacementIdentifier];
    NSString *appToken = [parameters.customParameters al_stringForKey: PARAM_APP_TOKEN];
    
    if (!zoneId || ![zoneId al_isValidString] || !appToken || ![appToken al_isValidString]) {
        [delegate didFailToLoadRewardedAdWithError:[MAAdapterError internalError]];
    } else {
        if ([[[HyBidSettings sharedInstance] appToken] isEqualToString:appToken] && [HyBid isInitialized]) {
            [self requestRewarded:parameters appToken:appToken zoneId:zoneId andNotify:delegate];
        } else {
            [HyBid initWithAppToken: appToken completion:^(BOOL success) {
                [self requestRewarded:parameters appToken:appToken zoneId:zoneId andNotify:delegate];
            }];
        }
    }
}

- (void)requestRewarded:(id<MAAdapterResponseParameters>)parameters appToken:(NSString *)appToken zoneId:(NSString*) zoneId andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self updateConsentWithParameters: parameters];
    [self updateMuteStateForParameters: parameters];
    
    self.rewardedAdapterDelegate = [[AppLovinMediationVerveRewardedAdsDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:zoneId withAppToken:appToken andWithDelegate:self.rewardedAdapterDelegate];
    self.rewardedAd.isMediation = YES;
    [self.rewardedAd setMediationVendor: MAX_MEDIATION_VENDOR];
    
    [self.rewardedAd load];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( [self.rewardedAd isReady] )
    {
        [self configureRewardForParameters: parameters];
        [self.rewardedAd showFromViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MANativeAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad"];
    
    NSString* zoneId = [parameters thirdPartyAdPlacementIdentifier];
    NSString *appToken = [parameters.customParameters al_stringForKey: PARAM_APP_TOKEN];
    
    if (!zoneId || ![zoneId al_isValidString] || !appToken || ![appToken al_isValidString]) {
        [delegate didFailToLoadNativeAdWithError:[MAAdapterError internalError]];
    } else {
        if ([[[HyBidSettings sharedInstance] appToken] isEqualToString:appToken] && [HyBid isInitialized]) {
            [self requestNative:parameters appToken:appToken zoneId:zoneId andNotify:delegate];
        } else {
            [HyBid initWithAppToken: appToken completion:^(BOOL success) {
                [self requestNative:parameters appToken:appToken zoneId:zoneId andNotify:delegate];
            }];
        }
    }
}

- (void)requestNative:(id<MAAdapterResponseParameters>)parameters appToken:(NSString *)appToken zoneId:(NSString*) zoneId andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self updateConsentWithParameters: parameters];
    [self updateMuteStateForParameters: parameters];
    
    HyBidNativeAdLoader *nativeAdLoader = [[HyBidNativeAdLoader alloc] init];
    nativeAdLoader.isMediation = YES;
    self.nativeAdAdapterDelegate = [[AppLovinMediationVerveNativeAdDelegate alloc] initWithParentAdapter: self serverParameters: parameters.serverParameters andNotify: delegate];
    [nativeAdLoader loadNativeAdWithDelegate:self.nativeAdAdapterDelegate withZoneID:zoneId withAppToken:appToken];
}

@end

@implementation AppLovinMediationVerveBannerDelegate

- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adViewDidLoad:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView ad loaded"];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"AdView failed to load: %@", error];
    
    MAAdapterError *adapterError = [AppLovinMediationVerveCustomNetworkAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView did track impression: %@", adView];
    [self.delegate didDisplayAdViewAd];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView clicked: %@", adView];
    [self.delegate didClickAdViewAd];
}

@end

@implementation AppLovinMediationVerveInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidLoad
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [AppLovinMediationVerveCustomNetworkAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialDidTrackImpression
{
    [self.parentAdapter log: @"Interstitial did track impression"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialDidTrackClick
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialDidDismiss
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation AppLovinMediationVerveRewardedAdsDelegate

- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedDidLoad
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [AppLovinMediationVerveCustomNetworkAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedDidTrackImpression
{
    [self.parentAdapter log: @"Rewarded ad did track impression"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)rewardedDidTrackClick
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)onReward
{
    [self.parentAdapter log: @"Rewarded ad reward granted"];
    self.grantedReward = YES;
}

- (void)rewardedDidDismiss
{
    [self.parentAdapter log: @"Rewarded ad did disappear"];
    [self.delegate didCompleteRewardedAdVideo];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

@end

@implementation AppLovinMediationVerveNativeAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *,id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.serverParameters = serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad loaded"];
    
    if ( !self.parentAdapter.nativeAd )
    {
        [self.parentAdapter log: @"Native ad failed to load: no fill"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
            
        return;
    }
    
    self.parentAdapter.nativeAd = nativeAd;
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    
    if ( ![self hasRequiredAssetsInAd: self.parentAdapter.nativeAd isTemplateAd: isTemplateAd] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
            
        return;
    }
    
    [nativeAd fetchNativeAdAssetsWithDelegate:self];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Native ad failed to load: %@", error];
    
    MAAdapterError *adapterError = [AppLovinMediationVerveCustomNetworkAdapter toMaxError: error];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdDidFinishFetching:(HyBidNativeAd *)nativeAd
{
    
}

- (void)nativeAd:(HyBidNativeAd *)nativeAd didFailFetchingWithError:(NSError *)error
{
    [self.parentAdapter log: @"Native ad failed to fetch assets: %@", error];
    
    MAAdapterError *adapterError = [AppLovinMediationVerveCustomNetworkAdapter toMaxError: error];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view
{
    [self.parentAdapter log: @"Native ad shown"];
    if (self.delegate) {
        [self.delegate didDisplayNativeAdWithExtraInfo:nil];
    }
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked"];
    if (self.delegate) {
        [self.delegate didClickNativeAd];
    }
}

- (BOOL)hasRequiredAssetsInAd:(HyBidNativeAd *)nativeAd isTemplateAd:(BOOL)isTemplateAd
{
    if ( isTemplateAd )
    {
        return [nativeAd.title al_isValidString];
    }
    else
    {
        return [nativeAd.title al_isValidString]
        && [nativeAd.callToActionTitle al_isValidString]
        && [nativeAd.bannerUrl al_isValidString];
    }
}

- (void)processNativeAd
{
    dispatchOnMainQueueNow(^{
        MAVerveMediationNativeAd *verveNativeAd = [[MAVerveMediationNativeAd alloc] initWithParentAdapter:self.parentAdapter builderBlock:^(MANativeAdBuilder *builder){
            
            UIView* bannerView = self.parentAdapter.nativeAd.banner;
            if (bannerView) {
                builder.mediaView = bannerView;
            }
            
            UIImage *iconImage = self.parentAdapter.nativeAd.icon;
            if (iconImage) {
                MANativeAdImage* icon = [[MANativeAdImage alloc] initWithImage: iconImage];
                builder.icon = icon;
            }
            
            if ([self.parentAdapter.nativeAd.title al_isValidString]) {
                builder.title = self.parentAdapter.nativeAd.title;
            }
            
            if ([self.parentAdapter.nativeAd.body al_isValidString]) {
                builder.body = self.parentAdapter.nativeAd.body;
            }
            
            if ([self.parentAdapter.nativeAd.callToActionTitle al_isValidString]) {
                builder.callToAction = self.parentAdapter.nativeAd.callToActionTitle;
            }
            
            HyBidContentInfoView *contentInfoView = self.parentAdapter.nativeAd.contentInfo;
            if (contentInfoView) {
                builder.optionsView = contentInfoView;
            }
        }];
        
        [self.delegate didLoadAdForNativeAd:verveNativeAd withExtraInfo:nil];
    });
}

@end

@implementation MAVerveMediationNativeAd

- (instancetype)initWithParentAdapter:(AppLovinMediationVerveCustomNetworkAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)nativeAdView
{
    if (!self.parentAdapter.nativeAd) {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return;
    }
    
    [self.parentAdapter.nativeAd startTrackingView:nativeAdView withDelegate:self.parentAdapter.nativeAdAdapterDelegate];
}

@end
