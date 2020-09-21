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

@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) NSString *network;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *campaign;
@property (nonatomic, strong) NSString *itunesitem;
@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSString *sourceapp;
@property (nonatomic, strong) NSString *timestamp;

@end

NS_ASSUME_NONNULL_END
