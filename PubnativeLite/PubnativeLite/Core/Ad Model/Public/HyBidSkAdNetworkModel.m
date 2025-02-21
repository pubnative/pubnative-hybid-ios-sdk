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

#import "HyBidSkAdNetworkModel.h"
#import "HyBidSKAdNetworkParameter.h"
#import <StoreKit/SKAdNetwork.h>
#import <StoreKit/SKStoreProductViewController.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidSkAdNetworkModel

NSString * const REQUEST_SKADNETWORK_V1 = @"1.0";
NSString * const REQUEST_SKADNETWORK_V2 = @"2.0";
NSString * const REQUEST_SKADNETWORK_V2_2 = @"2.2";
NSString * const REQUEST_SKADNETWORK_V3 = @"3.0";
NSString * const REQUEST_SKADNETWORK_V4 = @"4.0";

- (instancetype)initWithParameters:(NSDictionary *)productParams {
    self = [super init];
    if (self) {
        self.productParameters = productParams;
    }
    return self;
}

- (NSDictionary *)getStoreKitParameters {
    NSMutableDictionary* storeKitParameters = [[NSMutableDictionary alloc] init];
    
    if ([self areProductParametersValid:self.productParameters]) {
        
        NSString* skAdNetworkVersion = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.version];
        
        BOOL isSkAdNetworkHigher_v2 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2_2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V3] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V4];
        
        BOOL isSkAdNetworkHigher_v2_2 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2_2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V3] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V4];
        
        BOOL isSkAdNetworkHigher_v4_0 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V4];
        
        // SkAdNetwork v1.0 and later
        if (@available(iOS 11.3, *)) {
            if ([self.productParameters objectForKey:HyBidSKAdNetworkParameter.network] != nil) {
                [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.network] forKey:SKStoreProductParameterAdNetworkIdentifier];
            }
            
            // SkAdNetwork v4.0
            if (isSkAdNetworkHigher_v4_0) {
                if (@available(iOS 16.1, *)) {
                    if ([self.productParameters objectForKey:HyBidSKAdNetworkParameter.sourceIdentifier] != nil) {
                        NSString *sourceIdString = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.sourceIdentifier];
                        NSNumber *sourceId = [self getNSNumberFromString:sourceIdString];
                        if (sourceId != nil) {
                            [storeKitParameters setObject:sourceId forKey:SKStoreProductParameterAdNetworkSourceIdentifier];
                        }
                    }
                }
            } else {
                NSNumber *campaign = [self getNSNumberFromString:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.campaign]];
                if (campaign != nil) {
                    [storeKitParameters setObject:campaign forKey:SKStoreProductParameterAdNetworkCampaignIdentifier];
                }
            }
            
            if (![[HyBidSettings sharedInstance] supportMultipleFidelities]) {
                NSNumber *timestamp = [self getNSNumberFromString:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.timestamp]];
                if (timestamp != nil) {
                    [storeKitParameters setObject:timestamp forKey:SKStoreProductParameterAdNetworkTimestamp];
                }
                
                if ([[NSUUID alloc] initWithUUIDString:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.nonce]] != nil) {
                    [storeKitParameters setObject:[[NSUUID alloc] initWithUUIDString:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.nonce]] forKey:SKStoreProductParameterAdNetworkNonce];
                }
            }
        } else {
            // Fallback on earlier versions
        }
        if ([[self.productParameters objectForKey:HyBidSKAdNetworkParameter.itunesitem] isKindOfClass:[NSString class]]) {
        NSNumber *itunesItem = [self getNSNumberFromString:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.itunesitem]];
        if (itunesItem != nil) {
            [storeKitParameters setObject:itunesItem forKey:SKStoreProductParameterITunesItemIdentifier];
            }
        }
        
        NSNumber *present = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.present];
        if (present != nil) {
            [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.present] forKey:HyBidSKAdNetworkParameter.present];
        }
        
        NSNumber *position = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.position];
        if (position != nil) {
            [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.position] forKey:HyBidSKAdNetworkParameter.position];
        }
        
        NSNumber *dismissible = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.dismissible];
        if (dismissible != nil) {
            [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.dismissible] forKey:HyBidSKAdNetworkParameter.dismissible];
        }
        
        NSNumber *delay = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.delay];
        if (delay != nil) {
            [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.delay] forKey:HyBidSKAdNetworkParameter.delay];
        }
        
        NSNumber *endcardDelay = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay];
        if (endcardDelay != nil) {
            [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] forKey:HyBidSKAdNetworkParameter.endcardDelay];
        }
        
        NSNumber *autoClose = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.autoClose];
        if (autoClose != nil) {
            [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.autoClose] forKey:HyBidSKAdNetworkParameter.autoClose];
        }
               
        // SkAdNetwork v2.0 and later
        if (@available(iOS 14, *)) {

            if (isSkAdNetworkHigher_v2) {
                if (skAdNetworkVersion != nil) {
                    [storeKitParameters setObject:skAdNetworkVersion forKey:SKStoreProductParameterAdNetworkVersion];
                }
                
                NSString *sourceAppString = [self.productParameters objectForKey:HyBidSKAdNetworkParameter.sourceapp];
                
                if (sourceAppString != nil) {
                    NSNumber *sourceAppID = [self getNSNumberFromString:sourceAppString] != nil
                    ? [self getNSNumberFromString:sourceAppString]
                    : @0;
                    
                    [storeKitParameters setObject:sourceAppID forKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
                }
            }
            
            if (![[HyBidSettings sharedInstance] supportMultipleFidelities]) {
                if ([self.productParameters objectForKey:HyBidSKAdNetworkParameter.signature] != nil) {
                    [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.signature] forKey:SKStoreProductParameterAdNetworkAttributionSignature];
                }
            }
            
            if (isSkAdNetworkHigher_v2_2) {
                if (![[HyBidSettings sharedInstance] supportMultipleFidelities]) {
                    if ([self.productParameters objectForKey:HyBidSKAdNetworkParameter.fidelityType] != nil) {
                        [storeKitParameters setObject:[self.productParameters objectForKey:HyBidSKAdNetworkParameter.fidelityType] forKey:HyBidSKAdNetworkParameter.fidelityType];
                    }
                } else {
                    if (self.productParameters[HyBidSKAdNetworkParameter.fidelities] != nil) {
                        [storeKitParameters setObject:self.productParameters[HyBidSKAdNetworkParameter.fidelities] forKey:HyBidSKAdNetworkParameter.fidelities];
                    }
                }
            }
        }
        
    }
    
    return storeKitParameters;
}

- (NSNumber *)getNSNumberFromString:(NSString *)string
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [numberFormatter numberFromString:string];
    
    return number;
}

- (BOOL)areProductParametersValid:(NSDictionary *)dict {
    HyBidSettings *sharedSettings = [HyBidSettings sharedInstance];
    BOOL supportsMultipleFidelities = [sharedSettings supportMultipleFidelities];
    
    NSString* skAdNetworkVersion = dict[HyBidSKAdNetworkParameter.version];
    BOOL isSkAdNetwork_v2_0 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2];
    BOOL isSkAdNetwork_v2_2_or_v3_0 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2_2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V3];
    BOOL isSkAdNetwork_v4_0 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V4];
    
    if (@available(iOS 11.3, *)) {
        BOOL areBasicParametersValid = [self checkBasicParameters:dict supportMultipleFidelities:supportsMultipleFidelities];
        if (!areBasicParametersValid) {
            return NO;
        }
    }
    
    if (@available(iOS 14, *)) {
        if (isSkAdNetwork_v2_0) {
            if(![self checkV2Parameters:dict]) {
                return NO;
            }
        }
        if (isSkAdNetwork_v2_2_or_v3_0) {
            if(![self checkV2Parameters:dict] || ![self checkV2_2_Parameters:dict supportMultipleFidelities:supportsMultipleFidelities]) {
                return NO;
            }
        }
    }
        
    if (isSkAdNetwork_v4_0) {
        if (@available(iOS 16.1, *)) {
            if(![self checkV2Parameters:dict] || ![self checkV2_2_Parameters:dict supportMultipleFidelities:supportsMultipleFidelities] || ![self checkV4_0_Parameters:dict]) {
            return NO;
            }
        } else {
            return NO;
        }
    } else {
        NSString *campaignID = [NSString stringWithFormat:@"%@", dict[HyBidSKAdNetworkParameter.campaign]];
        if(!(dict[HyBidSKAdNetworkParameter.campaign] && [campaignID length] > 0)) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)checkBasicParameters:(NSDictionary *)dict supportMultipleFidelities:(BOOL)supportsMultipleFidelities {
    BOOL isValid = NO;
    
    NSString *timestamp = [NSString stringWithFormat:@"%@", dict[HyBidSKAdNetworkParameter.timestamp]];
    NSString *nonce = [NSString stringWithFormat:@"%@", dict[HyBidSKAdNetworkParameter.nonce]];
    NSString *itunesitem;
    if([dict[HyBidSKAdNetworkParameter.itunesitem] isKindOfClass:[NSString class]]) {
        itunesitem = [NSString stringWithFormat:@"%@", dict[HyBidSKAdNetworkParameter.itunesitem]];
    }
    
    if (supportsMultipleFidelities) {
        isValid = itunesitem != nil && [itunesitem length] > 0 &&
        dict[HyBidSKAdNetworkParameter.network] && [dict[HyBidSKAdNetworkParameter.network] length] > 0;
    } else {
        isValid = dict[HyBidSKAdNetworkParameter.signature] != nil && [dict[HyBidSKAdNetworkParameter.signature] length] > 0 &&
                  itunesitem != nil && [itunesitem length] > 0 &&
                  dict[HyBidSKAdNetworkParameter.network] && [dict[HyBidSKAdNetworkParameter.network] length] > 0 &&
                  dict[HyBidSKAdNetworkParameter.timestamp] && [timestamp length] > 0 &&
                  dict[HyBidSKAdNetworkParameter.nonce] && [nonce length] > 0;
    }
    
    return isValid;
}

- (BOOL)checkV2Parameters:(NSDictionary *)dict {
    NSString *appStoreID = [NSString stringWithFormat:@"%@", dict[HyBidSKAdNetworkParameter.sourceapp]];
    
    return dict[HyBidSKAdNetworkParameter.version] && [dict[HyBidSKAdNetworkParameter.version] length] > 0 &&
           dict[HyBidSKAdNetworkParameter.sourceapp] && [appStoreID length] > 0;
}

- (BOOL)checkV2_2_Parameters:(NSDictionary *)dict supportMultipleFidelities:(BOOL)supportsMultipleFidelities {
    BOOL isValid = NO;
    
    if (supportsMultipleFidelities) {
        NSArray<NSData *> *fidelitiesData = dict[HyBidSKAdNetworkParameter.fidelities];
        isValid = [fidelitiesData count] > 0;
        
        for (NSData *data in fidelitiesData) {
            SKANObject fidelityObject;
            [data getBytes:&fidelityObject length:sizeof(fidelityObject)];
            
            isValid = fidelityObject.signature != nil && [[NSString stringWithUTF8String:fidelityObject.signature] length] > 0 &&
                      fidelityObject.nonce != nil && [[NSString stringWithUTF8String:fidelityObject.nonce] length] > 0 &&
                      fidelityObject.timestamp != nil && [[NSString stringWithUTF8String:fidelityObject.timestamp] length] > 0;
            
            break; // Checking only for the first item is enough
        }
    } else {
        isValid = dict[HyBidSKAdNetworkParameter.fidelityType] != nil && [[NSString stringWithFormat:@"%@", dict[HyBidSKAdNetworkParameter.fidelityType]] length] > 0;
    }
    
    return isValid;
}

- (BOOL)checkV4_0_Parameters:(NSDictionary *)dict {
    BOOL isValid = [dict[HyBidSKAdNetworkParameter.sourceIdentifier] length] > 0 && dict[HyBidSKAdNetworkParameter.sourceIdentifier] != nil;
    return isValid;
}

- (BOOL)isSKAdNetworkIDVisible:(NSDictionary*) productParams{
   NSArray *networkItems = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SKAdNetworkItems"];
    
    if (networkItems == NULL || [networkItems count] == 0) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"The key `SKAdNetworkItems` could not be found in `info.plist` file of the app. Please add the required item and try again."];
        return NO;
    }

   for (NSDictionary* skAdNetworkID in networkItems) {
       NSString *skAdNetworkIdentifier = [[NSString stringWithFormat:@"%@",skAdNetworkID[@"SKAdNetworkIdentifier"]] lowercaseString];
       NSString *adNetworkId = [[NSString stringWithFormat:@"%@",productParams[@"adNetworkId"]] lowercaseString];
       if ([skAdNetworkIdentifier isEqualToString: adNetworkId]) {
           return YES;
       }
   }
   return NO;
}

@end
