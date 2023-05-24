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

NSString * const RESPONSE_AD_NETWORK_ID_KEY = @"network";
NSString * const RESPONSE_SOURCE_APP_ID_KEY = @"sourceapp";
NSString * const RESPONSE_SKADNETWORK_VERSION_KEY = @"version";
NSString * const RESPONSE_TARGET_APP_ID_KEY = @"itunesitem";
NSString * const RESPONSE_SIGNATURE_KEY = @"signature";
NSString * const RESPONSE_CAMPAIGN_ID_KEY = @"campaign";
NSString * const RESPONSE_TIMESTAMP_KEY = @"timestamp";
NSString * const RESPONSE_NONCE_KEY = @"nonce";
NSString * const RESPONSE_FIDELITY_TYPE_KEY = @"fidelity-type";
NSString * const RESPONSE_SOURCE_IDENTIFIER_KEY = @"sourceIdentifier";

- (instancetype)initWithParameters:(NSDictionary *)productParams {
    self = [super init];
    if (self) {
        self.productParameters = productParams;
    }
    return self;
}

- (NSDictionary *) getStoreKitParameters {
    NSMutableDictionary* storeKitParameters = [[NSMutableDictionary alloc] init];
    
    if ([self areProductParametersValid:self.productParameters]) {
        // SkAdNetwork v1.0 and later
        if (@available(iOS 11.3, *)) {
            if ([self.productParameters objectForKey:RESPONSE_AD_NETWORK_ID_KEY] != nil) {
                [storeKitParameters setObject:[self.productParameters objectForKey:RESPONSE_AD_NETWORK_ID_KEY] forKey:SKStoreProductParameterAdNetworkIdentifier];
            }
            
            // SkAdNetwork v4.0
            if (@available(iOS 16.1, *)) {
                if ([self.productParameters objectForKey:RESPONSE_SIGNATURE_KEY] != nil) {
                    [storeKitParameters setObject:[self.productParameters objectForKey:RESPONSE_SOURCE_IDENTIFIER_KEY] forKey:RESPONSE_SOURCE_IDENTIFIER_KEY];
                }
            } else {
                NSNumber *campaign = [self getNSNumberFromString:[self.productParameters objectForKey:RESPONSE_CAMPAIGN_ID_KEY]];
                if (campaign != nil) {
                    [storeKitParameters setObject:campaign forKey:SKStoreProductParameterAdNetworkCampaignIdentifier];
                }
            }
            
            if (![[HyBidSettings sharedInstance] supportMultipleFidelities]) {
                NSNumber *timestamp = [self getNSNumberFromString:[self.productParameters objectForKey:RESPONSE_TIMESTAMP_KEY]];
                if (timestamp != nil) {
                    [storeKitParameters setObject:timestamp forKey:SKStoreProductParameterAdNetworkTimestamp];
                }
                
                if ([[NSUUID alloc] initWithUUIDString:[self.productParameters objectForKey:RESPONSE_NONCE_KEY]] != nil) {
                    [storeKitParameters setObject:[[NSUUID alloc] initWithUUIDString:[self.productParameters objectForKey:RESPONSE_NONCE_KEY]] forKey:SKStoreProductParameterAdNetworkNonce];
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        NSNumber *itunesItem = [self getNSNumberFromString:[self.productParameters objectForKey:RESPONSE_TARGET_APP_ID_KEY]];
        if (itunesItem != nil) {
            [storeKitParameters setObject:itunesItem forKey:SKStoreProductParameterITunesItemIdentifier];
        }
               
        // SkAdNetwork v2.0 and later
        if (@available(iOS 14, *)) {
            NSString* skAdNetworkVersion = [self.productParameters objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY];
            
            BOOL isSkAdNetworkHigher_v2 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2_2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V3];
            
            BOOL isSkAdNetworkHigher_v2_2 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2_2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V3];
            
            if (isSkAdNetworkHigher_v2) {
                if (skAdNetworkVersion != nil) {
                    [storeKitParameters setObject:skAdNetworkVersion forKey:SKStoreProductParameterAdNetworkVersion];
                }
                
                NSString *sourceAppString = [self.productParameters objectForKey:RESPONSE_SOURCE_APP_ID_KEY];
                
                if (sourceAppString != nil) {
                    NSNumber *sourceAppID = [self getNSNumberFromString:sourceAppString] != nil
                    ? [self getNSNumberFromString:sourceAppString]
                    : @0;
                    
                    [storeKitParameters setObject:sourceAppID forKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
                }
            }
            
            if (![[HyBidSettings sharedInstance] supportMultipleFidelities]) {
                if ([self.productParameters objectForKey:RESPONSE_SIGNATURE_KEY] != nil) {
                    [storeKitParameters setObject:[self.productParameters objectForKey:RESPONSE_SIGNATURE_KEY] forKey:SKStoreProductParameterAdNetworkAttributionSignature];
                }
            }
            
            if (isSkAdNetworkHigher_v2_2) {
                if (![[HyBidSettings sharedInstance] supportMultipleFidelities]) {
                    if ([self.productParameters objectForKey:RESPONSE_FIDELITY_TYPE_KEY] != nil) {
                        [storeKitParameters setObject:[self.productParameters objectForKey:RESPONSE_FIDELITY_TYPE_KEY] forKey:RESPONSE_FIDELITY_TYPE_KEY];
                    }
                } else {
                    if (self.productParameters[@"fidelities"] != nil) {
                        [storeKitParameters setObject:self.productParameters[@"fidelities"] forKey:@"fidelities"];
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

- (BOOL) areProductParametersValid:(NSDictionary *)dict
{
    NSString* skAdNetworkVersion = [dict objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY];
    BOOL isSkAdNetworkHigher_v2_2 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2_2] || [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V3];
    BOOL isSkAdNetworkHigher_v4_0 = [skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V4];

    BOOL areBasicParametersValid = FALSE;
    if (@available(iOS 11.3, *)) {
        NSString *campaignID = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_CAMPAIGN_ID_KEY]]];
        NSString *timestamp = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_TIMESTAMP_KEY]]];
        NSString *nonce = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_NONCE_KEY]]];
        
        if ([[HyBidSettings sharedInstance] supportMultipleFidelities]) {
            areBasicParametersValid =
            [dict objectForKey:RESPONSE_TARGET_APP_ID_KEY] != nil &&
            [(NSString *)[dict objectForKey:RESPONSE_TARGET_APP_ID_KEY] length] > 0 &&
            [dict objectForKey:RESPONSE_AD_NETWORK_ID_KEY] &&
            [(NSString *)[dict objectForKey:RESPONSE_AD_NETWORK_ID_KEY] length] > 0 &&
            [dict objectForKey:RESPONSE_CAMPAIGN_ID_KEY] &&
            [campaignID length] > 0;
        } else {
            areBasicParametersValid = [dict objectForKey:RESPONSE_SIGNATURE_KEY] != nil &&
            [(NSString *)[dict objectForKey:RESPONSE_SIGNATURE_KEY] length] > 0 &&
            [dict objectForKey:RESPONSE_TARGET_APP_ID_KEY] != nil &&
            [(NSString *)[dict objectForKey:RESPONSE_TARGET_APP_ID_KEY] length] > 0 &&
            [dict objectForKey:RESPONSE_AD_NETWORK_ID_KEY] &&
            [(NSString *)[dict objectForKey:RESPONSE_AD_NETWORK_ID_KEY] length] > 0 &&
            [dict objectForKey:RESPONSE_CAMPAIGN_ID_KEY] &&
            [campaignID length] > 0 &&
            [dict objectForKey:RESPONSE_TIMESTAMP_KEY] &&
            [timestamp length] > 0 &&
            [dict objectForKey:RESPONSE_NONCE_KEY] &&
            [nonce length] > 0;
        }
    }
    
    BOOL areV2ParametersValid = FALSE;
    if (@available(iOS 14, *)) {
        NSString *appStoreID = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_SOURCE_APP_ID_KEY]]];
        
        areV2ParametersValid =
        [dict objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY] &&
        [(NSString *)[dict objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY] length] > 0 &&
        [dict objectForKey:RESPONSE_SOURCE_APP_ID_KEY] &&
        [appStoreID length] > 0;
    }
    
    BOOL areV2_2_ParametersValid = FALSE;
    if (@available(iOS 14, *)) {
        if (isSkAdNetworkHigher_v2_2) {
            if ([[HyBidSettings sharedInstance] supportMultipleFidelities]) {
                NSArray<NSData *> *fidelitiesData = dict[@"fidelities"];
                
                areV2_2_ParametersValid = [fidelitiesData count] > 0;
                
                for (NSData *data in fidelitiesData) {
                    SKANObject fidelityObject;
                    [data getBytes:&fidelityObject length:sizeof(fidelityObject)];
                    
                    areV2_2_ParametersValid =
                    fidelityObject.signature != nil &&
                    [[NSString stringWithUTF8String:fidelityObject.signature] length] > 0 &&
                    fidelityObject.nonce != nil &&
                    [[NSString stringWithUTF8String:fidelityObject.nonce] length] > 0 &&
                    fidelityObject.timestamp != nil &&
                    [[NSString stringWithUTF8String:fidelityObject.timestamp] length] > 0;
                    
                    break; // Checking only for the first item is enough
                }
            } else {
                areV2_2_ParametersValid = ([dict objectForKey:RESPONSE_FIDELITY_TYPE_KEY] != nil)
                && [[NSString stringWithFormat:@"%@", [dict objectForKey:RESPONSE_FIDELITY_TYPE_KEY]] length] > 0;
            }
        } else {
            areV2_2_ParametersValid = TRUE; // No need in versions below v2.2
        }
    }
    
    BOOL areV4_0_ParametersValid = FALSE;
    if (@available(iOS 16.1, *)) {
        areV4_0_ParametersValid = [dict objectForKey:RESPONSE_SOURCE_IDENTIFIER_KEY];
    }
    return areBasicParametersValid && areV2ParametersValid && areV2_2_ParametersValid && areV4_0_ParametersValid;
}

- (BOOL)isSKAdNetworkIDVisible:(NSDictionary*) productParams{
   NSArray *networkItems = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SKAdNetworkItems"];
    
    if (networkItems == NULL || [networkItems count] == 0) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"The key `SKAdNetworkItems` could not be found in `info.plist` file of the app. Please add the required item and try again."];
        return NO;
    }

   for (NSDictionary* skAdNetworkID in networkItems) {
       if ([[NSString stringWithFormat:@"%@",skAdNetworkID[@"SKAdNetworkIdentifier"]] isEqual:
            [NSString stringWithFormat:@"%@",productParams[@"adNetworkId"]]]) {
           return YES;
       }
   }
   return NO;
}

@end
