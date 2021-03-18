//
//  NEXWeather.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NEWeather.h"

/**
 * Contains a NEWeather value: a representation of weather, comprising semantic temperature and conditions.
 *
 * The temperature is relative to the user's expectations: 15C is warm for Iceland, but cold for Ethiopia.
 * The conditions are an abstracted representation of the weather summary.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXWeather : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NEWeather value;

+(NSString *)stringFromTemperature:(NEWeatherTemperature)temperature;

@end
NS_ASSUME_NONNULL_END
