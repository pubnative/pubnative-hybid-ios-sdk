//
//  NEXSituation.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NEDevicePosition.h"

/**
 * Contains a NEDevicePosition value which represents a device's position relative to the user, and its orientation.
 *
 * The state represents the position relative to the user.
 * The orientation represents the device's physical orientation.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXDevicePosition : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NEDevicePosition value;

+(NSString *)stringFromState:(NEDevicePositionState)state;
+(NSString *)stringFromOrientation:(NEDevicePositionOrientation)orientation;

@end
NS_ASSUME_NONNULL_END
