// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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

+ (NSMutableDictionary *)skanImpressionsDictionary;
+ (NSMutableDictionary *)aakImpressionsDictionary;

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

+ (NSMutableDictionary *)skanImpressionsDictionary {
    static NSMutableDictionary *skanImpressionsDictionary = nil;
    if (skanImpressionsDictionary == nil) {
        skanImpressionsDictionary = [NSMutableDictionary dictionary];
    }
    return skanImpressionsDictionary;
}

+ (NSMutableDictionary *)aakImpressionsDictionary {
    static NSMutableDictionary *aakImpressionsDictionary = nil;
    if (aakImpressionsDictionary == nil) {
        aakImpressionsDictionary = [NSMutableDictionary dictionary];
    }
    return aakImpressionsDictionary;
}

#pragma mark - SKAN impression functions

- (void)removeSkanImpressionForAd:(HyBidAd *)ad
{
    HyBidAdImpression.skanImpressionsDictionary[ad.impressionID] = nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140500

- (void)addSkanImpression:(SKAdImpression *)impression forAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    HyBidAdImpression.skanImpressionsDictionary[ad.impressionID] = impression;
}

- (SKAdImpression *)getImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    return HyBidAdImpression.skanImpressionsDictionary[ad.impressionID];
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

- (void)startSKANImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    HyBidSkAdNetworkModel *model = [self getSkAdNetworkModelForAd:ad];
    SKAdImpression *impression = [self generateSkAdImpressionFrom:model];
    
    if (impression != nil && model.productParameters.count > 0){
        if (@available(iOS 14.5, *)) {
            [SKAdNetwork startImpression:impression completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error: %@",error.localizedDescription]];
                    if ([HyBidSDKConfig sharedConfig].reporting) {
                        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                        [[HyBid reportingManager] reportEventFor:reportingEvent];
                    }
                } else {
                    [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression started successfully."];
                    [self addSkanImpression:impression forAd:ad];
                }
            }];
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)endSKANImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(14.5))
{
    SKAdImpression *impression = HyBidAdImpression.skanImpressionsDictionary[ad.impressionID];
    
    if (impression != nil) {
        if (@available(iOS 14.5, *)) {
            [SKAdNetwork endImpression:impression completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error: %@",error.localizedDescription]];
                    if ([HyBidSDKConfig sharedConfig].reporting) {
                        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                        [[HyBid reportingManager] reportEventFor:reportingEvent];
                    }
                }
                
                [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Impression ended successfully."];
                [self removeSkanImpressionForAd:ad];
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

#pragma mark - AAK impression functions

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 170400

- (void)addAAKImpression:(HyBidAppImpressionWrapper *)impression forAd:(HyBidAd *)ad
API_AVAILABLE(ios(17.4))
{
    HyBidAdImpression.aakImpressionsDictionary[ad.impressionID] = impression;
}

- (HyBidAppImpressionWrapper *)getAAKImpressionForAd:(HyBidAd *)ad
API_AVAILABLE(ios(17.4))
{
    return HyBidAdImpression.aakImpressionsDictionary[ad.impressionID];
}

- (void)startAAKImpressionForAd:(HyBidAd *)ad adFormat:(NSString *)adFormat
API_AVAILABLE(ios(17.4))
{
    [[HyBidAppImpressionWrapper alloc] createWithAd:ad adFormat:adFormat completion:^(HyBidAppImpressionWrapper *impressionWrapper) {
        if(impressionWrapper) {
            [impressionWrapper beginViewForAdFormat:adFormat completion:^(BOOL success) {
                if (success) {
                    [self addAAKImpression:impressionWrapper forAd:ad];
                } else {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error starting AdAttribution View-through Impression"]];
                }
            }];
            
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error creating HyBidAppImpressionWrapper"]];
        }
    }];
}

- (void)endAAKImpressionForAd:(HyBidAd *)ad adFormat:(NSString *)adFormat
API_AVAILABLE(ios(17.4))
{
    HyBidAppImpressionWrapper *aakAppImpressionWrapper = HyBidAdImpression.aakImpressionsDictionary[ad.impressionID];
    
    if (aakAppImpressionWrapper != nil) {
        [aakAppImpressionWrapper endViewForAdFormat:@"" completion:^(BOOL success) {
            if (success) {
                //impression did ended successfully
                [self removeAAKImpressionForAd:ad];
            } else {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error ending AdAttribution View-through Impression"]];
            }
        }];
    }
}

#endif

- (void)removeAAKImpressionForAd:(HyBidAd *)ad
{
    HyBidAdImpression.aakImpressionsDictionary[ad.impressionID] = nil;
}

@end
