//
//  NEXAmbientPressure.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 28/08/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface NEXAmbientPressure : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) double pressureInHPa;
@property (nonatomic, readonly) double pressureInKPa;

@end
NS_ASSUME_NONNULL_END
