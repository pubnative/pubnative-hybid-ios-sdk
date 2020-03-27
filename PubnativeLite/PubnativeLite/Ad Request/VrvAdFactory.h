//
//  VrvAdFactory.h
//  HyBid
//
//  Created by Eros Garcia Ponte on 23.03.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VrvAdRequestModel.h"
#import "HyBidAdSize.h"

@interface VrvAdFactory : NSObject

- (VrvAdRequestModel *)createVrvAdRequestWithZoneID:(NSString *) zoneID
         withAdSize:(HyBidAdSize*) adSize;

@end
