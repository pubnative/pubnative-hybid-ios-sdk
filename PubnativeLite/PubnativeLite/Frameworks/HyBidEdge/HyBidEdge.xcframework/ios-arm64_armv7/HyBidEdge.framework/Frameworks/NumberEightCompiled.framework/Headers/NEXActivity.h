//
//  NEXActivity.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NEActivity.h"

/**
 * Contains a NEActivity value: a user's physical activity, comprising a state and a mode.
 *
 * The state represents the main category of the activity, e.g. walking, running, and in vehicle.
 * The mode represents what type of vehicle is in use, if any.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXActivity : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NEActivity value;

+(NSString *)stringFromState:(NEActivityState)state;
+(NSString *)stringFromMode:(NEActivityMode)mode;

@end
NS_ASSUME_NONNULL_END
