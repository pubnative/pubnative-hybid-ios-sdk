//
//  SKAdNetworkViewController.h
//  HyBid
//
//  Created by Orkhan Alizada on 21.09.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <StoreKit/SKStoreProductViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidSKAdNetworkViewController : SKStoreProductViewController {
    NSDictionary* productParameters;
}

- (id)initWithProductParameters:(NSDictionary*)productParameters;
@end

NS_ASSUME_NONNULL_END
