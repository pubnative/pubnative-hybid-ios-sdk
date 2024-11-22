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
#define kHyBidISAppID @"1224c378d"
#define kHyBidALMediationNativeAdUnitID @"9f0b0f8353e2c66b"
#define kHyBidALMediationBannerAdUnitID @"5bf23910ded6430b"
#define kHyBidALMediationMRectAdUnitID @"23993b2ff0e8b324"
#define kHyBidALMediationInterstitialAdUnitID @"b4e84023ebd34e19"
#define kHyBidALMediationRewardedAdUnitID @"0b5163532e4dc1a5"
#define kHyBidChartboostAppID @"65c244faf5066be5b001df1b"
#define kHyBidChartboostAppSignature @"05cff89cca5270c0257319817d9c8fdc242a41c1"
#define kHyBidChartboostBannerPosition @"hybid-ios-banner"
#define kHyBidChartboostMRectHTMLPosition @"hybid-ios-mrect-html"
#define kHyBidChartboostMRectVideoPosition @"hybid-ios-mrect-video"
#define kHyBidChartboostInterstitialHTMLPosition @"hybid-ios-interstitial-html"
#define kHyBidChartboostInterstitialVideoPosition @"hybid-ios-interstitial-video"
#define kHyBidChartboostRewardedHTMLPosition @"hybid-ios-rewarded-html"
#define kHyBidChartboostRewardedVideoPosition @"hybid-ios-rewarded-video"

static NSString * const bullet = @"•  ";

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
        [self createSDKConfigAlertMessage];
        [self createSDKConfigAlertAttributes];
        [self createPublisherModeAlertMessage];
        [self createPublisherModeAlertAttributes];
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
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidISAppID forKey:kHyBidISAppIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidALMediationNativeAdUnitID forKey:kHyBidALMediationNativeAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidALMediationBannerAdUnitID forKey:kHyBidALMediationBannerAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidALMediationMRectAdUnitID forKey:kHyBidALMediationMRectAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidALMediationInterstitialAdUnitID forKey:kHyBidALMediationInterstitialAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidALMediationRewardedAdUnitID forKey:kHyBidALMediationRewardedAdUnitIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostAppID forKey:kHyBidChartboostAppIDKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostAppSignature forKey:kHyBidChartboostAppSignatureKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostBannerPosition forKey:kHyBidChartboostBannerPositionKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostMRectHTMLPosition forKey:kHyBidChartboostMRectHTMLPositionKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostMRectVideoPosition forKey:kHyBidChartboostMRectVideoPositionKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostInterstitialHTMLPosition forKey:kHyBidChartboostInterstitialHTMLPositionKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostInterstitialVideoPosition forKey:kHyBidChartboostInterstitialVideoPositionKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostRewardedHTMLPosition forKey:kHyBidChartboostRewardedHTMLPositionKey];
        [[NSUserDefaults standardUserDefaults] setObject:kHyBidChartboostRewardedVideoPosition forKey:kHyBidChartboostRewardedVideoPositionKey];
    }
}

- (void)createSDKConfigAlertMessage {
    NSMutableArray<NSString *> *strings = [NSMutableArray array];
    [strings addObject:@"Production: Tap \"Production URL\""];
    [strings addObject:@"Testing: Provide the SDK Config URL, then tap \"Testing URL\""];
    for (NSUInteger i = 0; i < strings.count; i++) {
        strings[i] = [bullet stringByAppendingString:strings[i]];
    }
    self.sdkConfigAlertMessage = [@"\n" stringByAppendingString: [strings componentsJoinedByString:@"\n\n"]];
}

- (void)createSDKConfigAlertAttributes {
    self.sdkConfigAlertAttributes = [NSMutableDictionary dictionary];
    self.sdkConfigAlertAttributes[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = [bullet sizeWithAttributes:self.sdkConfigAlertAttributes].width;
    self.sdkConfigAlertAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
}

- (void)createPublisherModeAlertMessage {
    NSMutableArray<NSString *> *strings = [NSMutableArray array];
    [strings addObject:@"Initialisation: Next run cycle"];
    [strings addObject:@"Everything else: Ready"];
    for (NSUInteger i = 0; i < strings.count; i++) {
        strings[i] = [bullet stringByAppendingString:strings[i]];
    }
    self.publisherModeAlertMessage = [@"\n" stringByAppendingString: [strings componentsJoinedByString:@"\n\n"]];
}

- (void)createPublisherModeAlertAttributes {
    self.publisherModeAlertAttributes = [NSMutableDictionary dictionary];
    self.publisherModeAlertAttributes[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = [bullet sizeWithAttributes:self.publisherModeAlertAttributes].width;
    self.publisherModeAlertAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
}
@end
