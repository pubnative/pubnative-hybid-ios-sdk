//
//  NEXLockStatus.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NELockStatus.h"

/**
 * Contains a NELockStatus value which represents whether the device is locked or unlocked.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXLockStatus : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NELockStatus value;

+(NSString *)stringFromState:(NELockStatusState)state;

@end
NS_ASSUME_NONNULL_END
