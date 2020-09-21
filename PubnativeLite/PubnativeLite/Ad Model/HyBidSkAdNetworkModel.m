//
//  HyBidSkAdNetworkModel.m
//  HyBid
//
//  Created by Orkhan Alizada on 18.09.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "HyBidSkAdNetworkModel.h"

@implementation HyBidSkAdNetworkModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.signature = dictionary[@"signature"];
        self.network = dictionary[@"network"];
        self.version = dictionary[@"version"];
        self.campaign = dictionary[@"campaign"];
        self.itunesitem = dictionary[@"itunesitem"];
        self.nonce = dictionary[@"nonce"];
        self.sourceapp = dictionary[@"sourceapp"];
        self.timestamp = dictionary[@"timestamp"];
    }
    return self;
}

@end
