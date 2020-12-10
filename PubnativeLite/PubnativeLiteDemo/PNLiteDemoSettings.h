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

#import <Foundation/Foundation.h>
#import <HyBid/HyBid.h>

#define kHyBidDemoAppTokenKey @"appToken"
#define kHyBidDemoZoneIDKey @"zoneID"
#define kHyBidDemoKeywordsKey @"keywords"
#define kHyBidDemoTestModeKey @"testMode"
#define kHyBidDemoCOPPAModeKey @"coppaMode"
#define kHyBidMoPubHeaderBiddingLeaderboardAdUnitIDKey @"moPubHeaderBiddingLeaderboardAdUnitID"
#define kHyBidMoPubHeaderBiddingBannerAdUnitIDKey @"moPubHeaderBiddingBannerAdUnitID"
#define kHyBidMoPubHeaderBiddingMRectAdUnitIDKey @"moPubHeaderBiddingMRectAdUnitID"
#define kHyBidMoPubHeaderBiddingInterstitialAdUnitIDKey @"moPubHeaderBiddingInterstitialAdUnitID"
#define kHyBidMoPubMediationNativeAdUnitIDKey @"moPubMediationNativeAdUnitID"
#define kHyBidMoPubMediationLeaderboardAdUnitIDKey @"moPubMediationLeaderboardAdUnitID"
#define kHyBidMoPubMediationBannerAdUnitIDKey @"moPubMediationBannerAdUnitID"
#define kHyBidMoPubMediationMRectAdUnitIDKey @"moPubMediationMRectAdUnitID"
#define kHyBidMoPubMediationInterstitialAdUnitIDKey @"moPubMediationInterstitialAdUnitID"
#define kHyBidMoPubMediationRewardedAdUnitIDKey @"moPubMediationRewardedAdUnitID"
#define kHyBidDFPHeaderBiddingLeaderboardAdUnitIDKey @"dfpHeaderBiddingLeaderboardAdUnitID"
#define kHyBidDFPHeaderBiddingBannerAdUnitIDKey @"dfpHeaderBiddingBannerAdUnitID"
#define kHyBidDFPHeaderBiddingMRectAdUnitIDKey @"dfpHeaderBiddingMRectAdUnitID"
#define kHyBidDFPHeaderBiddingInterstitialAdUnitIDKey @"dfpHeaderBiddingInterstitialAdUnitID"
#define kHyBidAdMobMediationAppIDKey @"adMobMediationAppID"
#define kHyBidAdMobMediationBannerAdUnitIDKey @"adMobMediationBannerAdUnitID"
#define kHyBidAdMobMediationMRectAdUnitIDKey @"adMobMediationMRectAdUnitID"
#define kHyBidAdMobMediationLeaderboardAdUnitIDKey @"adMobMediationLeaderboardAdUnitID"
#define kHyBidAdMobMediationInterstitialAdUnitIDKey @"adMobMediationInterstitialAdUnitID"
#define kHyBidAdMobMediationRewardedAdUnitIDKey @"adMobMediationRewardedAdUnitID"
#define kHyBidDemoAPIURLKey @"apiURL"
#define kHyBidDemoOpenRTBAPIURLKey @"openRtbApiURL"
#define kHyBidDemoAppID @"1530210244"

@interface PNLiteDemoSettings : NSObject

@property (nonatomic, strong) HyBidTargetingModel *targetingModel;
@property (nonatomic, strong) HyBidAdSize *adSize;
@property (nonatomic, strong) NSMutableArray *bannerSizesArray;

+ (PNLiteDemoSettings *)sharedInstance;

@end
