//
//  NEXSituation.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#include "NESituation.h"

/**
 * Contains a NESituation value which represents the overall situation of the user, comprising a major and minor type.
 *
 * The major type is the high-level situation of the user.
 * The minor type is a more granular situation.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXSituation : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NESituation value;

+(NSString *)stringFromMajor:(NESituationMajor)major;
+(NSString *)stringFromMinor:(NESituationMinor)minor;

@end
NS_ASSUME_NONNULL_END
