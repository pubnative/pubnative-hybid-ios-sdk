//
//  HyBidSkAdNetworkModel.m
//  HyBid
//
//  Created by Orkhan Alizada on 18.09.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
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

- (NSDictionary *) getProductParameters:(NSDictionary *)dict {
    NSMutableDictionary* productParameters = [[NSMutableDictionary alloc] init];
    
    if (@available(iOS 11.3, *)) {
        [productParameters setObject:[dict objectForKey:RESPONSE_SIGNATURE_KEY] forKey:SKStoreProductParameterAdNetworkAttributionSignature];
        [productParameters setObject:[dict objectForKey:RESPONSE_AD_NETWORK_ID_KEY] forKey:SKStoreProductParameterAdNetworkIdentifier];
        [productParameters setObject:@([[dict objectForKey:RESPONSE_CAMPAIGN_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkCampaignIdentifier];
        [productParameters setObject:@([[dict objectForKey:RESPONSE_TIMESTAMP_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkTimestamp];
        [productParameters setObject:[[NSUUID alloc] initWithUUIDString:[dict objectForKey:RESPONSE_NONCE_KEY]] forKey:SKStoreProductParameterAdNetworkNonce];
    } else {
        // Fallback on earlier versions
    }
    [productParameters setObject:[dict objectForKey:RESPONSE_TARGET_APP_ID_KEY] forKey:SKStoreProductParameterITunesItemIdentifier];

    if (@available(iOS 14, *)) {
        NSString* skAdNetworkVersion = [dict objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY];
        
        // These product params are only included in SKAdNetwork version 2.0
        if ([skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2]) {
            [productParameters setObject:skAdNetworkVersion forKey:SKStoreProductParameterAdNetworkVersion];
            [productParameters setObject:@([[dict objectForKey:RESPONSE_SOURCE_APP_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
        }
    }
    
    return productParameters;
}

@end
