//
//  NEXIndoorOutdoor.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NEIndoorOutdoor.h"

/**
 * Contains a NEIndoorOutdoor value which represents whether a user is indoors, outdoors, or enclosed.
 *
 * Enclosed in this case means that the user is outside, but under some sort of canopy.
 * This could be a bus shelter or a train for example.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXIndoorOutdoor : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NEIndoorOutdoor value;

+(NSString *)stringFromState:(NEIndoorOutdoorState)state;

@end
NS_ASSUME_NONNULL_END
