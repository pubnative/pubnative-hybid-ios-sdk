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

#import "AppMonet+DFP.h"
#import <HyBid/HyBid.h>
#import "AppMonetConfigurations.h"
#import "HyBidLogger.h"

@import GoogleMobileAds;

@interface AppMonet ()

@property (class, nonatomic, strong) HyBidAdRequest *adRequest;
@property (class, nonatomic, strong) HyBidInterstitialAdRequest *interstitialAdRequest;
@property (class, nonatomic) NSMutableDictionary *dict;

typedef struct {
    DFPRequest *dfpRequest;
    void (^onReadyBlock)(DFPRequest *dfpRequest); }
AppMonetDFPStruct;

@end

@implementation AppMonet (DFP)

+ (void)init:(AppMonetConfigurations *)appMonetConfigurations withBlock:(void (^)(NSError *))block {
    [AppMonet initialize:appMonetConfigurations withBlock:block];
}

+ (void)initialize:(AppMonetConfigurations *)appMonetConfigurations withBlock:(void (^)(NSError *))block {
    AppMonetConfigurations *internalConfigurations = appMonetConfigurations;
    if (appMonetConfigurations == nil) {
        internalConfigurations = [AppMonetConfigurations configurationWithBlock:^(AppMonetConfigurations *builder) {
            // do nothing
        }];
    }
}

+ (void) addBids:(DFPBannerView *)adView andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andDfpAdRequest:(DFPRequest *)adRequest andTimeout:(NSNumber *)timeout
andDfpRequestBlock:(void (^)(DFPRequest *dfpRequest))dfpRequestBlock
{
    AppMonetDFPStruct dfpStruct;
    dfpStruct.dfpRequest = adRequest;
    dfpStruct.onReadyBlock = dfpRequestBlock;
    [AppMonet.dict setObject:[NSValue valueWithPointer:&dfpStruct] forKey:appMonetAdUnitId];
    
    self.adRequest = [[HyBidAdRequest alloc] init];
    self.adRequest.adSize = [self getAdSize:adView.adSize];
    [self.adRequest requestAdWithDelegate:(id<HyBidAdRequestDelegate>)self withZoneID:appMonetAdUnitId];
}

+ (DFPRequest *)addBids:(DFPBannerView *)adView andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andDfpAdRequest:(DFPRequest *)adRequest
{
    // This will be left empty because there's no synchronous API supported for this.
    return adRequest;
}

+ (void)addBids:(DFPRequest *)adRequest andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andTimeout:(NSNumber *)timeout andDfpRequestBlock:(void (^)(DFPRequest *dfpRequest))dfpRequestBlock
{
    self.adRequest = [[HyBidAdRequest alloc] init];
    self.adRequest.adSize = HyBidAdSize.SIZE_300x250;
    [self.adRequest requestAdWithDelegate:(id<HyBidAdRequestDelegate>)self withZoneID:appMonetAdUnitId];
}

+ (DFPRequest *)addBids:(DFPRequest *)adRequest andAppMonetAdUnitId:(NSString *)appMonetAdUnitId
{
    // This will be left empty because there's no synchronous API supported for this.
    return adRequest;
}

+ (void)addBids:(GADBannerView *)adView andGadRequest:(GADRequest *)adRequest
andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andTimeout:(NSNumber *)timeout
 andGadRequestBlock:(void (^)(GADRequest *gadRequest))gadRequestBlock
{
    self.adRequest = [[HyBidAdRequest alloc] init];
    self.adRequest.adSize = HyBidAdSize.SIZE_300x250;
    [self.adRequest requestAdWithDelegate:(id<HyBidAdRequestDelegate>)self withZoneID:appMonetAdUnitId];
}

+ (void)addBids:(GADBannerView *)adView andDfpRequest:(DFPRequest *)adRequest
andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andTimeout:(NSNumber *)timeout
 andDfpRequestBlock:(void (^)(DFPRequest *dfpRequest))dfpRequestBlock
{
    self.adRequest = [[HyBidAdRequest alloc] init];
    self.adRequest.adSize = [self getAdSize:adView.adSize];
    [self.adRequest requestAdWithDelegate:(id<HyBidAdRequestDelegate>)self withZoneID:appMonetAdUnitId];
}

+ (GADRequest *)addBids:(GADBannerView *)adView andGadRequest:(GADRequest *)adRequest
    andAppMonetAdUnitId:(NSString *)appMonetAdUnitId
{
    // This will be left empty because there's no synchronous API supported for this.
    return adRequest;
}

+ (DFPRequest *)addBids:(GADBannerView *)adView andDfpRequest:(DFPRequest *)adRequest
    andAppMonetAdUnitId:(NSString *)appMonetAdUnitId
{
    // This will be left empty because there's no synchronous API supported for this.
    return adRequest;
}

+ (void)addInterstitialBids:(DFPInterstitial *)interstitial
        andAppMonetAdUnitId:(NSString *)appMonetAdUnitId
            andDfpAdRequest:(DFPRequest *)adRequest
                 andTimeout:(NSNumber *)timeout
                  withBlock:(void (^)(DFPRequest *completeRequest))requestBlock
{
    self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest requestAdWithDelegate:(id<HyBidAdRequestDelegate>)self withZoneID:appMonetAdUnitId];
}

+(void)addInterstitialBids:(GADInterstitial *)interstitial
       andAppMonetAdUnitId:(NSString *)appMonetAdUnitId
              andAdRequest:(GADRequest *)adRequest
                andTimeout:(NSNumber *)timeout
                 withBlock:(void (^)(GADRequest *))requestBlock
{
    self.interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
    [self.interstitialAdRequest requestAdWithDelegate:(id<HyBidAdRequestDelegate>)self withZoneID:appMonetAdUnitId];
}

+ (HyBidAdSize *)getAdSize:(GADAdSize)adSize
{
    if (adSize.size.height == kGADAdSizeBanner.size.height && adSize.size.width == kGADAdSizeBanner.size.width) {
        return HyBidAdSize.SIZE_320x50;
    } else if (adSize.size.height == kGADAdSizeLargeBanner.size.height && adSize.size.width == kGADAdSizeLargeBanner.size.width) {
        return HyBidAdSize.SIZE_320x100;
    } else if (adSize.size.height == kGADAdSizeLeaderboard.size.height && adSize.size.width == kGADAdSizeLeaderboard.size.width) {
        return HyBidAdSize.SIZE_728x90;
    } else if (adSize.size.height == kGADAdSizeSkyscraper.size.height && adSize.size.width == kGADAdSizeSkyscraper.size.width) {
        return HyBidAdSize.SIZE_160x600;
    } else {
        return HyBidAdSize.SIZE_300x250;
    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    
    AppMonetDFPStruct *dfpStruct = (__bridge AppMonetDFPStruct *)([AppMonet.dict objectForKey:ad.zoneID]);
    NSString *bidKeywords = [HyBidHeaderBiddingUtils createAppMonetHeaderBiddingKeywordsStringWithAd:ad];
    
    if (request == AppMonet.interstitialAdRequest) {
        bidKeywords = [HyBidHeaderBiddingUtils createAppMonetHeaderBiddingInterstitialKeywordsStringWithAd:ad];
    }
        
    if (bidKeywords.length != 0) {
        DFPRequest *request = [self addDFPKeywords:dfpStruct->dfpRequest withBidKeywords:bidKeywords];
        dfpStruct->onReadyBlock(request);
    } else {
        dfpStruct->onReadyBlock(dfpStruct->dfpRequest);
    }
}

- (DFPRequest *)addDFPKeywords:(DFPRequest *)adRequest withBidKeywords:(NSString *)bidKeywords
{
    DFPRequest *request = [[DFPRequest alloc] init];
    if (adRequest.contentURL.length != 0) {
        request.contentURL = adRequest.contentURL;
    }
    if (bidKeywords.length != 0) {
        NSArray *newArray = [request.keywords arrayByAddingObject:bidKeywords];
        [request setKeywords:newArray];
        
        NSArray *params = [bidKeywords componentsSeparatedByString:@":"];
        NSDictionary *customTargetDict = @{ params[0]: params[1] };
        [request setCustomTargeting:customTargetDict];
    }
    
    NSMutableArray *newKeywords;
    for (NSString *keyword in adRequest.keywords) {
        [newKeywords addObject:keyword];
    }
    [request setKeywords:newKeywords];
    
    for (NSString *key in adRequest.customTargeting.allKeys) {
        NSMutableDictionary *dict = [request.customTargeting mutableCopy];
        [dict setObject:[adRequest.customTargeting objectForKey:key] forKey:key];
        [request setCustomTargeting:dict];
    }
    
    return request;
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
}

+ (void)enableVerboseLogging:(BOOL)verboseLogging
{
    
}

+ (void)preload:(NSArray<NSString *> *)adUnitIDs
{
    
}

+ (void)clearAdUnit:(NSString *)adUnitID
{
    
}

@end
