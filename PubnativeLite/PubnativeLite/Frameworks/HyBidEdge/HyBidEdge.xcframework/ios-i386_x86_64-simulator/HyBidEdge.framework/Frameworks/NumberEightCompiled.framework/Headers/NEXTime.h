//
//  NEXTimeOfDay.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NETime.h"

/**
 * Contains a NETime value: a representation of semantic time relative to the user's habits, and a type of day.
 *
 * Time of day represents semantic time (e.g. lunch, dinner, evening).
 * Type of day represents whether it is a weekday, weekend, or holiday.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXTime : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NETime value;

+(NSString *)stringFromTime:(NETimeTime)time;
+(NSString *)stringFromType:(NETimeType)type;

@end
NS_ASSUME_NONNULL_END
