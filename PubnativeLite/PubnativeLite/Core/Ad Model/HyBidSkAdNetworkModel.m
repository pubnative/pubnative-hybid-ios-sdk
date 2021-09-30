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

@implementation HyBidSkAdNetworkModel

NSString * const REQUEST_SKADNETWORK_V1 = @"1.0";
NSString * const REQUEST_SKADNETWORK_V2 = @"2.0";

NSString * const RESPONSE_AD_NETWORK_ID_KEY = @"network";
NSString * const RESPONSE_SOURCE_APP_ID_KEY = @"sourceapp";
NSString * const RESPONSE_SKADNETWORK_VERSION_KEY = @"version";
NSString * const RESPONSE_TARGET_APP_ID_KEY = @"itunesitem";
NSString * const RESPONSE_SIGNATURE_KEY = @"signature";
NSString * const RESPONSE_CAMPAIGN_ID_KEY = @"campaign";
NSString * const RESPONSE_TIMESTAMP_KEY = @"timestamp";
NSString * const RESPONSE_NONCE_KEY = @"nonce";
NSString * const RESPONSE_FIDELITY_KEY = @"fidelity-type";

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
        if (@available(iOS 11.3, *)) {
            [storeKitParameters setObject:[self.productParameters objectForKey:RESPONSE_SIGNATURE_KEY] forKey:SKStoreProductParameterAdNetworkAttributionSignature];
            [storeKitParameters setObject:[self.productParameters objectForKey:RESPONSE_AD_NETWORK_ID_KEY] forKey:SKStoreProductParameterAdNetworkIdentifier];
            [storeKitParameters setObject:@([[self.productParameters objectForKey:RESPONSE_CAMPAIGN_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkCampaignIdentifier];
            [storeKitParameters setObject:@([[self.productParameters objectForKey:RESPONSE_TIMESTAMP_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkTimestamp];
            [storeKitParameters setObject:[[NSUUID alloc] initWithUUIDString:[self.productParameters objectForKey:RESPONSE_NONCE_KEY]] forKey:SKStoreProductParameterAdNetworkNonce];
        } else {
            // Fallback on earlier versions
        }
        [storeKitParameters setObject:[self.productParameters objectForKey:RESPONSE_TARGET_APP_ID_KEY] forKey:SKStoreProductParameterITunesItemIdentifier];
        
        if (@available(iOS 14, *)) {
            NSString* skAdNetworkVersion = [self.productParameters objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY];
            
            // These product params are only included in SKAdNetwork version 2.0
            if ([skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2]) {
                [storeKitParameters setObject:skAdNetworkVersion forKey:SKStoreProductParameterAdNetworkVersion];
                [storeKitParameters setObject:@([[self.productParameters objectForKey:RESPONSE_SOURCE_APP_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
            }
        }
    }
    
    return storeKitParameters;
}

- (BOOL) areProductParametersValid:(NSDictionary *)dict
{
    BOOL areBasicParametersValid = FALSE;
    if (@available(iOS 11.3, *)) {
        NSString *campaignID = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_CAMPAIGN_ID_KEY]]];
        NSString *timestamp = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_TIMESTAMP_KEY]]];
        NSString *nonce = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_NONCE_KEY]]];
        
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
    
    BOOL areV2ParametersValid = FALSE;
    if (@available(iOS 14, *)) {
        NSString *appStoreID = [NSString stringWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:RESPONSE_SOURCE_APP_ID_KEY]]];
        
        areV2ParametersValid = [dict objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY] &&
        [(NSString *)[dict objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY] length] > 0 &&
        [dict objectForKey:RESPONSE_SOURCE_APP_ID_KEY] &&
        [appStoreID length] > 0;
    }
    
    return areBasicParametersValid && areV2ParametersValid;
}

@end
