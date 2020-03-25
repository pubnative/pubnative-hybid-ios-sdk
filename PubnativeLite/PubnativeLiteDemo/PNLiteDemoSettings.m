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
NSString *const PNLiteDemoPartnerKeyword = @"adsdkexample";
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
NSString *const PNLiteDemoAdMobMediationAppID = @"ca-app-pub-2576283444991206~5819414108";
NSString *const PNLiteDemoAdMobMediationBannerAdUnitID = @"ca-app-pub-2576283444991206/7675421252";
NSString *const PNLiteDemoAdMobMediationMRectAdUnitID = @"ca-app-pub-2576283444991206/1943393054";
NSString *const PNLiteDemoAdMobMediationLeaderboardAdUnitID = @"ca-app-pub-2576283444991206/2969889488";
NSString *const PNLiteDemoAdMobMediationInterstitialAdUnitID = @"ca-app-pub-2576283444991206/1852248931";

NSString *const PNLiteDemoAPIURL = @"https://api.pubnative.net";

@implementation PNLiteDemoSettings

- (void)dealloc {
    self.appToken = nil;
    self.partnerKeyword = nil;
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
    self.adMobMediationAppID = nil;
    self.adMobMediationBannerAdUnitID = nil;
    self.adMobMediationMRectAdUnitID = nil;
    self.adMobMediationLeaderboardAdUnitID = nil;
    self.adMobMediationInterstitialAdUnitID = nil;
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
        self.partnerKeyword = PNLiteDemoPartnerKeyword;
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
        self.adMobMediationAppID = PNLiteDemoAdMobMediationAppID;
        self.adMobMediationBannerAdUnitID = PNLiteDemoAdMobMediationBannerAdUnitID;
        self.adMobMediationMRectAdUnitID = PNLiteDemoAdMobMediationMRectAdUnitID;
        self.adMobMediationLeaderboardAdUnitID = PNLiteDemoAdMobMediationLeaderboardAdUnitID;
        self.adMobMediationInterstitialAdUnitID = PNLiteDemoAdMobMediationInterstitialAdUnitID;
        self.targetingModel = [[HyBidTargetingModel alloc] init];
        self.apiURL = PNLiteDemoAPIURL;
        [self createBannerSizeArray];
    }
    return self;
}

- (void)createBannerSizeArray {
    NSValue *value320x50 = [NSValue valueWithBytes:&SIZE_320x50 objCType:@encode(HyBidAdSize)];
    NSValue *value300x250 = [NSValue valueWithBytes:&SIZE_300x250 objCType:@encode(HyBidAdSize)];
    NSValue *value300x50 = [NSValue valueWithBytes:&SIZE_300x50 objCType:@encode(HyBidAdSize)];
    NSValue *value320x480 = [NSValue valueWithBytes:&SIZE_320x480 objCType:@encode(HyBidAdSize)];
    NSValue *value1024x768 = [NSValue valueWithBytes:&SIZE_1024x768 objCType:@encode(HyBidAdSize)];
    NSValue *value768x1024 = [NSValue valueWithBytes:&SIZE_768x1024 objCType:@encode(HyBidAdSize)];
    NSValue *value728x90 = [NSValue valueWithBytes:&SIZE_728x90 objCType:@encode(HyBidAdSize)];
    NSValue *value160x600 = [NSValue valueWithBytes:&SIZE_160x600 objCType:@encode(HyBidAdSize)];
    NSValue *value250x250 = [NSValue valueWithBytes:&SIZE_250x250 objCType:@encode(HyBidAdSize)];
    NSValue *value300x600 = [NSValue valueWithBytes:&SIZE_300x600 objCType:@encode(HyBidAdSize)];
    NSValue *value320x100 = [NSValue valueWithBytes:&SIZE_320x100 objCType:@encode(HyBidAdSize)];
    NSValue *value480x320 = [NSValue valueWithBytes:&SIZE_480x320 objCType:@encode(HyBidAdSize)];
    
    self.bannerSizesArray = [NSMutableArray arrayWithObjects:@"Choose Banner Size", value320x50, value300x250, value300x50, value320x480, value1024x768, value768x1024, value728x90, value160x600, value250x250, value300x600, value320x100, value480x320, nil];
}

@end
