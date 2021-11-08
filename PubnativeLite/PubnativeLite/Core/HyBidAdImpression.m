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

#import "HyBidAdImpression.h"

@interface HyBidAdImpression ()

+ (NSMutableDictionary *)impressionsDictionary;

@end

@implementation HyBidAdImpression

+ (HyBidAdImpression *)sharedInstance {
    static HyBidAdImpression *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HyBidAdImpression alloc] init];
    });
    return _instance;
}

+ (NSMutableDictionary *)impressionsDictionary {
    static NSMutableDictionary *impressionsDictionary = nil;
    if (impressionsDictionary == nil) {
        impressionsDictionary = [NSMutableDictionary dictionary];
    }
    return impressionsDictionary;
}

- (void)removeImpressionForAd:(HyBidAd *)ad
{
    HyBidAdImpression.impressionsDictionary[ad.impressionID] = nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500

- (void)addImpression:(SKAdImpression *)impression forAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    HyBidAdImpression.impressionsDictionary[ad.impressionID] = impression;
}

- (SKAdImpression *)getImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    return HyBidAdImpression.impressionsDictionary[ad.impressionID];
}

- (SKAdImpression *)generateSkAdImpressionFromModel:(HyBidSkAdNetworkModel *)model
API_AVAILABLE(ios(14.5)){
    if (@available(iOS 14.5, *)) {
        SKAdImpression *impression = [[SKAdImpression alloc] init];
        [impression setAdNetworkIdentifier:model.productParameters[@"network"]];
        [impression setSourceAppStoreItemIdentifier:model.productParameters[@"sourceapp"]];
        [impression setAdvertisedAppStoreItemIdentifier:model.productParameters[@"itunesitem"]];
        [impression setVersion:model.productParameters[@"version"]];
        [impression setAdCampaignIdentifier:model.productParameters[@"campaign"]];
        [impression setTimestamp:model.productParameters[@"timestamp"]];
        [impression setAdImpressionIdentifier:model.productParameters[@"nonce"]];
        [impression setSignature:model.productParameters[@"signature"]];
                
        return impression;
    } else {
        return nil;
    }
}

- (void)startImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    HyBidSkAdNetworkModel *model = [self getSkAdNetworkModelForAd:ad];
    SKAdImpression *impression = [self generateSkAdImpressionFromModel:model];
    
    if (impression != nil) {
        if (@available(iOS 14.5, *)) {
            [SKAdNetwork startImpression:impression completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                    return;
                }
                
                NSLog(@"Impression started successfully.");
                [self addImpression:impression forAd:ad];
            }];
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)endImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    SKAdImpression *impression = HyBidAdImpression.impressionsDictionary[ad.impressionID];
    
    if (impression != nil) {
        if (@available(iOS 14.5, *)) {
            [SKAdNetwork endImpression:impression completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
                
                NSLog(@"Impression ended successfully.");
                [self removeImpressionForAd:ad];
            }];
        } else {
            // Fallback on earlier versions
        }
    }
}

#endif

- (HyBidSkAdNetworkModel *)getSkAdNetworkModelForAd: (HyBidAd *)ad
{
    return ad.isUsingOpenRTB ? [ad getOpenRTBSkAdNetworkModel] : [ad getSkAdNetworkModel];
}

@end
