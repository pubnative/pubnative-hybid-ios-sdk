//
//  NEXMotion.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 20/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NEMovement.h"

#import <Foundation/Foundation.h>

/**
 * Contains a NEMovement value which represents whether the device is moving or not moving.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXMovement : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NEMovement value;

+(NSString *)stringFromState:(NEMovementState)state;

@end
NS_ASSUME_NONNULL_END
