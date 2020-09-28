//
//  HyBidSkAdNetworkModel.h
//  HyBid
//
//  Created by Orkhan Alizada on 18.09.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HyBidBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HyBidSkAdNetworkModel : HyBidBaseModel

@property (nonatomic, strong) NSDictionary *productParameters;

- (instancetype)initWithParameters:(NSDictionary *)productParams;
- (NSDictionary *) getStoreKitParameters;

@end

NS_ASSUME_NONNULL_END
