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

NSString *const PNLiteDemoAppToken = @"543027b8e954474cbcd9a98481622a3b";
NSString *const PNLiteDemoZoneID;
NSString *const PNLiteDemoMoPubLeaderboardAdUnitID = @"990b5957b0374238a4ce6fcf451c8e89";
NSString *const PNLiteDemoMoPubBannerAdUnitID = @"a4eac931d95444f0a95adc77093a22ab";
NSString *const PNLiteDemoMoPubMRectAdUnitID = @"7f797ff5c287480cbf15e9f1735fb8d7";
NSString *const PNLiteDemoMoPubInterstitialAdUnitID = @"a91bc5a72fd54888ac248e7656b69b2e";
NSString *const PNLiteDemoMoPubMediationNativeAdUnitID = @"823d7538cf714f2ab344436b2027f8ea";
NSString *const PNLiteDemoMoPubMediationLeaderboardAdUnitID = @"8c18da9010144ebabeb85eead8141bf6";
NSString *const PNLiteDemoMoPubMediationBannerAdUnitID = @"8ba4f63a03da4c1ba84653c4bc66d11e";
NSString *const PNLiteDemoMoPubMediationMRectAdUnitID = @"038dfd33ec4d4391aee61557ffd3ed8b";
NSString *const PNLiteDemoMoPubMediationInterstitialAdUnitID = @"a50d6ad8b2b84ea0af8049b8dfd32126";
NSString *const PNLiteDemoDFPLeaderboardAdUnitID = @"/6499/example/banner";
NSString *const PNLiteDemoDFPBannerAdUnitID = @"/6499/example/banner";
NSString *const PNLiteDemoDFPMRectAdUnitID = @"/6499/example/banner";
NSString *const PNLiteDemoDFPInterstitialAdUnitID = @"/6499/example/interstitial";
NSString *const PNLiteDemoAdMobMediationBannerAdUnitID = @"ca-app-pub-3940256099942544/2934735716";
NSString *const PNLiteDemoAdMobMediationMRectAdUnitID = @"ca-app-pub-3940256099942544/2934735716";

NSString *const PNLiteDemoAPIURL = @"https://api.pubnative.net";

@implementation PNLiteDemoSettings

- (void)dealloc {
    self.appToken = nil;
    self.zoneID = nil;
    self.moPubLeaderboardAdUnitID = nil;
    self.moPubBannerAdUnitID = nil;
    self.moPubMRectAdUnitID = nil;
    self.moPubInterstitialAdUnitID = nil;
    self.moPubMediationNativeAdUnitID = nil;
    self.moPubMediationLeaderboardAdUnitID = nil;
    self.moPubMediationBannerAdUnitID = nil;
    self.moPubMediationMRectAdUnitID = nil;
    self.moPubMediationInterstitialAdUnitID = nil;
    self.dfpLeaderboardAdUnitID = nil;
    self.dfpBannerAdUnitID = nil;
    self.dfpMRectAdUnitID = nil;
    self.dfpInterstitialAdUnitID = nil;
    self.adMobMediationBannerAdUnitID = nil;
    self.adMobMediationMRectAdUnitID = nil;
    self.keywords = nil;
    self.targetingModel = nil;
    self.apiURL = nil;
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
        self.appToken = PNLiteDemoAppToken;
        self.zoneID = PNLiteDemoZoneID;
        self.moPubLeaderboardAdUnitID = PNLiteDemoMoPubLeaderboardAdUnitID;
        self.moPubBannerAdUnitID = PNLiteDemoMoPubBannerAdUnitID;
        self.moPubMRectAdUnitID = PNLiteDemoMoPubMRectAdUnitID;
        self.moPubInterstitialAdUnitID = PNLiteDemoMoPubInterstitialAdUnitID;
        self.moPubMediationNativeAdUnitID = PNLiteDemoMoPubMediationNativeAdUnitID;
        self.moPubMediationLeaderboardAdUnitID = PNLiteDemoMoPubMediationLeaderboardAdUnitID;
        self.moPubMediationBannerAdUnitID = PNLiteDemoMoPubMediationBannerAdUnitID;
        self.moPubMediationMRectAdUnitID = PNLiteDemoMoPubMediationMRectAdUnitID;
        self.moPubMediationInterstitialAdUnitID = PNLiteDemoMoPubMediationInterstitialAdUnitID;
        self.dfpLeaderboardAdUnitID = PNLiteDemoDFPLeaderboardAdUnitID;
        self.dfpBannerAdUnitID = PNLiteDemoDFPBannerAdUnitID;
        self.dfpMRectAdUnitID = PNLiteDemoDFPMRectAdUnitID;
        self.dfpInterstitialAdUnitID = PNLiteDemoDFPInterstitialAdUnitID;
        self.adMobMediationBannerAdUnitID = PNLiteDemoAdMobMediationBannerAdUnitID;
        self.adMobMediationMRectAdUnitID = PNLiteDemoAdMobMediationMRectAdUnitID;
        self.targetingModel = [[HyBidTargetingModel alloc] init];
        self.apiURL = PNLiteDemoAPIURL;
    }
    return self;
}

@end
