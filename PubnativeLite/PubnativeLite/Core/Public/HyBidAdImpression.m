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
    if (@available(iOS 14.5, *)) {
        SKAdImpression *impression = [[SKAdImpression alloc] init];
        
        if (model.productParameters[@"network"] != nil) {
            [impression setAdNetworkIdentifier:model.productParameters[@"network"]];
        }
        if (model.productParameters[@"sourceapp"] != nil) {
            NSNumber *sourceApp = [self getNSNumberFromString:model.productParameters[@"sourceapp"]] != nil
            ? [self getNSNumberFromString:model.productParameters[@"sourceapp"]]
            : @0;
            
            [impression setSourceAppStoreItemIdentifier:sourceApp];
        }
        if ([self getNSNumberFromString:model.productParameters[@"itunesitem"]] != nil) {
            [impression setAdvertisedAppStoreItemIdentifier:[self getNSNumberFromString:model.productParameters[@"itunesitem"]]];
        }
        if (model.productParameters[@"version"] != nil) {
            [impression setVersion:model.productParameters[@"version"]];
        }
        if ([self getNSNumberFromString:model.productParameters[@"campaign"]] != nil) {
            [impression setAdCampaignIdentifier:[self getNSNumberFromString:model.productParameters[@"campaign"]]];
        }
        
        double skanVersion = [[model productParameters][@"version"] doubleValue];
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [model.productParameters[@"fidelities"] count] > 0) {
            for (NSData *data in model.productParameters[@"fidelities"]) {
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
            if (model.productParameters[@"signature"] != nil) {
                [impression setSignature:model.productParameters[@"signature"]];
            }
            if (model.productParameters[@"nonce"] != nil) {
                [impression setAdImpressionIdentifier:model.productParameters[@"nonce"]];
            }
            if ([self getNSNumberFromString:model.productParameters[@"timestamp"]] != nil) {
                [impression setTimestamp:[self getNSNumberFromString:model.productParameters[@"timestamp"]]];
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
    
    if (impression != nil) {
        if (@available(iOS 14.5, *)) {
            [SKAdNetwork startImpression:impression completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error.localizedDescription);
                    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                    [[HyBid reportingManager] reportEventFor:reportingEvent];
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
                    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                    [[HyBid reportingManager] reportEventFor:reportingEvent];
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
