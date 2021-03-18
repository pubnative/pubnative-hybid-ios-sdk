
//
//  NEXScreenBrightness.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 28/08/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface NEXAmbientLight : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) double value;

@end
NS_ASSUME_NONNULL_END
