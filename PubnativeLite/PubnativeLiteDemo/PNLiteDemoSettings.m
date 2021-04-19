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

#import "PNLiteDemoSettings.h"

#define kHyBidDemoAppToken @"543027b8e954474cbcd9a98481622a3b"
#define kHyBidDemoZoneID @""
#define kHyBidMoPubHeaderBiddingLeaderboardAdUnitID @"990b5957b0374238a4ce6fcf451c8e89"
#define kHyBidMoPubHeaderBiddingBannerAdUnitID @"a4eac931d95444f0a95adc77093a22ab"
#define kHyBidMoPubHeaderBiddingMRectAdUnitID @"7f797ff5c287480cbf15e9f1735fb8d7"
#define kHyBidMoPubHeaderBiddingMRectVideoAdUnitID @"e1f164a8c7554fdc9f0ad3740ff80c5e"
#define kHyBidMoPubHeaderBiddingInterstitialAdUnitID @"a91bc5a72fd54888ac248e7656b69b2e"
#define kHyBidMoPubHeaderBiddingRewardedAdUnitID @"0d6a3e5d883540ad98f1baf5d2a5d710"
#define kHyBidMoPubHeaderBiddingInterstitialVideoAdUnitID @"766c0edcd4c2496884a697ad406a8555"
#define kHyBidMoPubMediationNativeAdUnitID @"823d7538cf714f2ab344436b2027f8ea"
#define kHyBidMoPubMediationLeaderboardAdUnitID @"8c18da9010144ebabeb85eead8141bf6"
#define kHyBidMoPubMediationBannerAdUnitID @"8ba4f63a03da4c1ba84653c4bc66d11e"
#define kHyBidMoPubMediationMRectAdUnitID @"038dfd33ec4d4391aee61557ffd3ed8b"
#define kHyBidMoPubMediationInterstitialAdUnitID @"a50d6ad8b2b84ea0af8049b8dfd32126"
#define kHyBidMoPubMediationRewardedAdUnitID @"b514d9fc570742a4b974e59d33aee494"
#define kHyBidGAMLeaderboardAdUnitID @"/6499/example/banner"
#define kHyBidGAMBannerAdUnitID @"/6499/example/banner"
#define kHyBidGAMMRectAdUnitID @"/6499/example/banner"
#define kHyBidGAMInterstitialAdUnitID @"/6499/example/interstitial"
#define kHyBidGADAppID @"ca-app-pub-8741261465579918~3720290336"
#define kHyBidGADNativeAdUnitID @"ca-app-pub-8741261465579918/8160924764"
#define kHyBidGADBannerAdUnitID @"ca-app-pub-8741261465579918/4075513559"
#define kHyBidGADMRectAdUnitID @"ca-app-pub-8741261465579918/6510105208"
#define kHyBidGADLeaderboardAdUnitID @"ca-app-pub-8741261465579918/4943734481"
#define kHyBidGADInterstitialAdUnitID @"ca-app-pub-8741261465579918/1815008264"
#define kHyBidGADRewardedAdUnitID @"ca-app-pub-8741261465579918/7366717846"
#define kHyBidDemoAPIURL @"https://api.pubnative.net"
#define kHyBidDemoOpenRTBAPIURL @"https://dsp.pubnative.net"
#define kIsAppLaunchedPreviouslyKey @"isAppLaunchedPreviously"

@implementation PNLiteDemoSettings

- (void)dealloc {
    self.targetingModel = nil;
    self.adSize = nil;
}

+ (PNLiteDemoSettings *)sharedInstance {
    static PNLiteDemoSettings * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PNLiteDemoSettings alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.targetingModel = [[HyBidTargetingModel alloc] init];
        [self createBannerSizeArray];
        [self setInitialValuesForUserDefaults];
    }
    return self;
}

- (void)createBannerSizeArray {
    self.bannerSizesArray = [NSMutableArray arrayWithObjects:@"Choose Banner Size", HyBidAdSize.SIZE_320x50, HyBidAdSize.SIZE_300x250, HyBidAdSize.SIZE_300x50, HyBidAdSize.SIZE_320x480, HyBidAdSize.SIZE_1024x768, HyBidAdSize.SIZE_768x1024, HyBidAdSize.SIZE_728x90, HyBidAdSize.SIZE_160x600, HyBidAdSize.SIZE_250x250, HyBidAdSize.SIZE_300x600, HyBidAdSize.SIZE_320x100, HyBidAdSize.SIZE_480x320, nil];
}

- (void)setInitialValuesForUserDefaults {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsAppLaunchedPreviouslyKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidDemoAppToken forKey:kHyBidDemoAppTokenKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidDemoZoneID forKey:kHyBidDemoZoneIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubHeaderBiddingLeaderboardAdUnitID forKey:kHyBidMoPubHeaderBiddingLeaderboardAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubHeaderBiddingBannerAdUnitID forKey:kHyBidMoPubHeaderBiddingBannerAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubHeaderBiddingMRectAdUnitID forKey:kHyBidMoPubHeaderBiddingMRectAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubHeaderBiddingMRectVideoAdUnitID forKey:kHyBidMoPubHeaderBiddingMRectVideoAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubHeaderBiddingInterstitialAdUnitID forKey:kHyBidMoPubHeaderBiddingInterstitialAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubHeaderBiddingInterstitialVideoAdUnitID forKey:kHyBidMoPubHeaderBiddingInterstitialVideoAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubHeaderBiddingRewardedAdUnitID forKey:kHyBidMoPubHeaderBiddingRewardedAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubMediationNativeAdUnitID forKey:kHyBidMoPubMediationNativeAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubMediationLeaderboardAdUnitID forKey:kHyBidMoPubMediationLeaderboardAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubMediationBannerAdUnitID forKey:kHyBidMoPubMediationBannerAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubMediationMRectAdUnitID forKey:kHyBidMoPubMediationMRectAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubMediationInterstitialAdUnitID forKey:kHyBidMoPubMediationInterstitialAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidMoPubMediationRewardedAdUnitID forKey:kHyBidMoPubMediationRewardedAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGAMLeaderboardAdUnitID forKey:kHyBidGAMLeaderboardAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGAMBannerAdUnitID forKey:kHyBidGAMBannerAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGAMMRectAdUnitID forKey:kHyBidGAMMRectAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGAMInterstitialAdUnitID forKey:kHyBidGAMInterstitialAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidDemoAPIURL forKey:kHyBidDemoAPIURLKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidDemoOpenRTBAPIURL forKey:kHyBidDemoOpenRTBAPIURLKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGADAppID forKey:kHyBidGADAppIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGADNativeAdUnitID forKey:kHyBidGADNativeAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGADBannerAdUnitID forKey:kHyBidGADBannerAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGADMRectAdUnitID forKey:kHyBidGADMRectAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGADLeaderboardAdUnitID forKey:kHyBidGADLeaderboardAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGADInterstitialAdUnitID forKey:kHyBidGADInterstitialAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidGADRewardedAdUnitID forKey:kHyBidGADRewardedAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsAppLaunchedPreviouslyKey];
    }
}

@end
