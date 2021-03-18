//
//  NEXLocationCluster.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#include "NELocationCluster.h"

#import "NEXSensorItem.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NEXLocationCluster : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NELocationCluster value;

@end
NS_ASSUME_NONNULL_END
