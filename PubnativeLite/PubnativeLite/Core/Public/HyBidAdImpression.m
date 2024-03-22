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
#import "HyBid.h"
#import "HyBidSKAdNetworkParameter.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

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

- (SKAdImpression *)generateSkAdImpressionFrom:(HyBidSkAdNetworkModel *)model
API_AVAILABLE(ios(14.5)){
    
    double skanVersion = [[model productParameters][HyBidSKAdNetworkParameter.version] doubleValue];

    if (@available(iOS 14.5, *)) {
        SKAdImpression *impression = [[SKAdImpression alloc] init];
        
        if (model.productParameters[HyBidSKAdNetworkParameter.network] != nil) {
            [impression setAdNetworkIdentifier:model.productParameters[HyBidSKAdNetworkParameter.network]];
        }
        if (model.productParameters[HyBidSKAdNetworkParameter.sourceapp] != nil) {
            NSNumber *sourceApp = [self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.sourceapp]] != nil
            ? [self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.sourceapp]]
            : @0;
            
            [impression setSourceAppStoreItemIdentifier:sourceApp];
        }
        if ([model.productParameters[HyBidSKAdNetworkParameter.itunesitem] isKindOfClass:[NSString class]]) {
            if ([self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.itunesitem]] != nil) {
                [impression setAdvertisedAppStoreItemIdentifier:[self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.itunesitem]]];
            }
        }
        
        if (model.productParameters[HyBidSKAdNetworkParameter.version] != nil) {
            [impression setVersion:model.productParameters[HyBidSKAdNetworkParameter.version]];
        }
        
        if (skanVersion >= 4.0) {
            if (@available(iOS 16.1, *) ) {
                if ([self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.sourceIdentifier]] != nil) {
                    [impression setSourceIdentifier:[self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.sourceIdentifier]]];
                }
            }
        } else {
            if ([self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.campaign]] != nil) {
                [impression setAdCampaignIdentifier:[self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.campaign]]];
            }
        }
        
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [model.productParameters[HyBidSKAdNetworkParameter.fidelities] count] > 0) {
            for (NSData *data in model.productParameters[HyBidSKAdNetworkParameter.fidelities]) {
                SKANObject skanObject;
                [data getBytes:&skanObject length:sizeof(skanObject)];
                
                if (skanObject.fidelity == 0) { // 0 is View-Through ad
                    if ([NSString stringWithUTF8String:skanObject.signature] != nil) {
                        [impression setSignature: [NSString stringWithUTF8String:skanObject.signature]];
                    }
                    if ([NSString stringWithUTF8String:skanObject.nonce] != nil) {
                        [impression setAdImpressionIdentifier:[NSString stringWithUTF8String:skanObject.nonce]];
                    }
                    if ([self getNSNumberFromString:[NSString stringWithUTF8String:skanObject.timestamp]] != nil) {
                        [impression setTimestamp:[self getNSNumberFromString:[NSString stringWithUTF8String:skanObject.timestamp]]];
                    }
                }
            }
        } else {
            if (model.productParameters[HyBidSKAdNetworkParameter.signature] != nil) {
                [impression setSignature:model.productParameters[HyBidSKAdNetworkParameter.signature]];
            }
            if (model.productParameters[HyBidSKAdNetworkParameter.nonce] != nil) {
                [impression setAdImpressionIdentifier:model.productParameters[HyBidSKAdNetworkParameter.nonce]];
            }
            if ([self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.timestamp]] != nil) {
                [impression setTimestamp:[self getNSNumberFromString:model.productParameters[HyBidSKAdNetworkParameter.timestamp]]];
            }
        }
           
        return impression;
    } else {
        return nil;
    }
}

- (NSNumber *)getNSNumberFromString:(NSString *)string
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [numberFormatter numberFromString:string];
    
    return number;
}

- (void)startImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    HyBidSkAdNetworkModel *model = [self getSkAdNetworkModelForAd:ad];
    SKAdImpression *impression = [self generateSkAdImpressionFrom:model];
    
    if (impression != nil && model.productParameters.count > 0){
        if (@available(iOS 14.5, *)) {
            [SKAdNetwork startImpression:impression completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error: %@",error.localizedDescription]];
                    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                    [[HyBid reportingManager] reportEventFor:reportingEvent];
                } else {
                    [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression started successfully."];
                    [self addImpression:impression forAd:ad];
                }
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
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error: %@",error.localizedDescription]];
                    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                    [[HyBid reportingManager] reportEventFor:reportingEvent];
                }
                
                [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression ended successfully."];
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
