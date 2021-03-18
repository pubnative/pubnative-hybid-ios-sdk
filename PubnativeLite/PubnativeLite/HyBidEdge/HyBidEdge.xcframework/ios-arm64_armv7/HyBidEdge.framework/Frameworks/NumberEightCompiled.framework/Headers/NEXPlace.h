//
//  NEXPlace.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"
#include "NEPlace.h"

/**
 * Contains a NEPlace value which represents abstract information about a place, including a semantic name, major, and minor type.
 *
 * The name is a semantic name relevant to the user for the place: currently either home or work.
 * The major type represents a high-level category for the type of place.
 * The minor type gives a more granular category representation of the place.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXPlace : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NEPlace value;

+(NSString *)stringFromContextIndex:(NEPlaceContextIndex)contextIndex;
+(NSString *)stringFromContextKnowledge:(NEPlaceContextKnowledge)contextKnowledge;
+(NSString *)stringFromMajor:(NEPlaceMajor)major;
+(NSString *)stringFromMinor:(NEPlaceMinor)minor;

@end
NS_ASSUME_NONNULL_END
