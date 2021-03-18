//
//  NEXMagnetometerData.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 28/08/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXVector3DData.h"
#import <CoreMotion/CMMagnetometer.h>

NS_ASSUME_NONNULL_BEGIN
@interface NEXMagnetometerData : NEXVector3DData

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) CMMagneticField cmMagneticField;

@end
NS_ASSUME_NONNULL_END
