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

#import "AppMonet+MoPub.h"
#import <HyBid/HyBid.h>
#import "AppMonetInterstitialAdViewClass.h"
#import "AppMonetAdViewClass.h"

@interface AppMonet ()

@end

@implementation AppMonet (MoPub)

static NSMutableDictionary *_dict=nil;
+ (NSMutableDictionary *)dict {
  if (_dict == nil) {
    _dict = [[NSMutableDictionary alloc] init];
  }
  return _dict;
}

static NSMutableDictionary *_interstitialDict=nil;
+ (NSMutableDictionary *)interstitialDict {
  if (_interstitialDict == nil) {
      _interstitialDict = [[NSMutableDictionary alloc] init];
  }
  return _interstitialDict;
}

static HyBidAdRequest *_adRequest=nil;
+ (HyBidAdRequest *)adRequest {
  if (_adRequest == nil) {
      _adRequest = [[HyBidAdRequest alloc] init];
  }
  return _adRequest;
}

static HyBidInterstitialAdRequest *_interstitialAdRequest=nil;
+ (HyBidInterstitialAdRequest *)interstitialAdRequest {
  if (_interstitialAdRequest == nil) {
      _interstitialAdRequest = [[HyBidInterstitialAdRequest alloc] init];
  }
  return _interstitialAdRequest;
}

+ (void)addBids:(MPAdView *)adView andAppMonetAdUnitId:(NSString *)appMonetAdUinitId andTimeout:(NSNumber *)timeout :(void (^)(void))onReadyBlock
{
    AppMonetAdViewClass *appMonetAdViewClass = [[AppMonetAdViewClass alloc]init];
    appMonetAdViewClass.adView = adView;
    appMonetAdViewClass.onReadyBlock = onReadyBlock;

    [AppMonet.dict setObject:appMonetAdViewClass forKey:appMonetAdUinitId];

    self.adRequest.adSize = HyBidAdSize.SIZE_300x250;
    [self.adRequest requestAdWithDelegate:AppMonet.self withZoneID:appMonetAdUinitId];
}

+ (void)addInterstitialBids:(MPInterstitialAdController *)interstitial andAppMonetAdUnitId:(NSString *)appMonetAdUinitId andTimeout:(NSNumber *)timeout :(void (^)(void))onReadyBlock __attribute__((deprecated))
{
    AppMonetInterstitialAdViewClass *appMonetInterstitialAdViewClass = [[AppMonetInterstitialAdViewClass alloc]init];
    appMonetInterstitialAdViewClass.interstitial = interstitial;
    appMonetInterstitialAdViewClass.onReadyBlock = onReadyBlock;
    
    [AppMonet.interstitialDict setObject:appMonetInterstitialAdViewClass forKey:appMonetAdUinitId];

    [self.interstitialAdRequest requestAdWithDelegate:AppMonet.self withZoneID:appMonetAdUinitId];
}

+ (MPAdView *)addBids:(MPAdView *)adView
{
    // This has been left empty because we don't support any synchronous API.
    return nil;
}

+ (void)addNativeBids:(MPNativeAdRequest *)adRequest andAdUnitId:(NSString *)adUnitId andTimeout:(NSNumber *)timeout :(void (^)(void))onReadyBlock {
    onReadyBlock();
}

+ (void)enableVerboseLogging:(BOOL)verboseLogging {
    [HyBidLogger setLogLevel:HyBidLogLevelDebug];
}

+ (void)invokeDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
}

#pragma mark HyBidAdRequestDelegate

+ (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

+ (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    
    if (request == AppMonet.interstitialAdRequest) {
        NSString *bidKeywords = [HyBidHeaderBiddingUtils createAppMonetHeaderBiddingInterstitialKeywordsStringWithAd:ad];
        
        if (bidKeywords.length != 0) {
            
            AppMonetInterstitialAdViewClass *appMonetInterstitialAdViewClass = (AppMonetInterstitialAdViewClass*)[AppMonet.interstitialDict objectForKey:ad.zoneID];

            if (appMonetInterstitialAdViewClass.interstitial.keywords.length == 0) {
                [appMonetInterstitialAdViewClass.interstitial setKeywords:bidKeywords];
            } else {
                NSString *currentKeywords = appMonetInterstitialAdViewClass.interstitial.keywords;
                appMonetInterstitialAdViewClass.interstitial.keywords = [self mergeKeywords:currentKeywords newKeywords:bidKeywords];
            }
            appMonetInterstitialAdViewClass.onReadyBlock();
            
            [AppMonet.interstitialDict setObject:appMonetInterstitialAdViewClass forKey:ad.zoneID];


        }
    } else {
        NSString *bidKeywords = [HyBidHeaderBiddingUtils createAppMonetHeaderBiddingKeywordsStringWithAd:ad];
        if (bidKeywords.length != 0) {
            
            AppMonetAdViewClass *appMonetAdViewClass = (AppMonetAdViewClass*)[AppMonet.dict objectForKey:ad.zoneID];

            if (appMonetAdViewClass.adView.keywords.length == 0) {
                appMonetAdViewClass.adView.keywords = bidKeywords;
            } else {
                NSString *currentKeywords = appMonetAdViewClass.adView.keywords;
                appMonetAdViewClass.adView.keywords = [self mergeKeywords:currentKeywords newKeywords:bidKeywords];
            }
            appMonetAdViewClass.onReadyBlock();
            
            [AppMonet.dict setObject:appMonetAdViewClass forKey:ad.zoneID];
            
        }
    }
}

+ (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

+ (NSDictionary *)keywordsToDictionary:(NSString *)keywords
{
    NSMutableDictionary *dict= [[NSMutableDictionary alloc]init];
    NSArray *keyValueArray = [keywords componentsSeparatedByString:@","];
    for (NSString *str in keyValueArray) {
        NSArray *splittedKeywords = [str componentsSeparatedByString:@":"];
        if ([splittedKeywords count] == 2) {
            dict[splittedKeywords[0]] = splittedKeywords[1];
        }
    }
    return dict;
}

+ (NSString *)mergeKeywords:(NSString *)currentKeywords newKeywords:(NSString *)newKeywords
{
    NSDictionary *currentDict = [self keywordsToDictionary:currentKeywords];
    NSDictionary *newDict = [self keywordsToDictionary:newKeywords];
    
    NSMutableDictionary *returnDict = [currentDict mutableCopy];
    [returnDict addEntriesFromDictionary:newDict];
    
    return [self getKeywords:returnDict];
}

+ (NSString *)getKeywords:(NSMutableDictionary *)keywords
{
    NSMutableString *str;
    for (NSString *key in keywords.allKeys) {
        [str appendString:key];
        [str appendString:@":"];
        
        NSString *val = [keywords valueForKey:key];
        [str appendString:val];
        [str appendString:@","];
    }
    return str;
}

@end

