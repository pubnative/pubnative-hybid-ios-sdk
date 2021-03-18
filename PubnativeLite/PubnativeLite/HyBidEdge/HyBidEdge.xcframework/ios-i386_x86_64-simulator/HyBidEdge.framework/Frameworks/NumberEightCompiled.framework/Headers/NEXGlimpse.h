//
//  NEXGlimpse.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 18/10/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @interface NEXGlimpse
 A snapshot of a user's current context.
 
 A Glimpse contains a list of possibilities orderred by their confidence
 along with when it was first recorded.
 */
NS_SWIFT_NAME(Glimpse)
@interface NEXGlimpse<__covariant NEXSensorItemType> : NSObject

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

/**
 The most probable value from the list of possibilities.
 */
@property (nonatomic, readonly) NEXSensorItemType mostProbable;

/**
 A list of value and their confidence level from 0.0 to 1.0.
 The list is sorted from most to least probable.
 This is akin to a distribution over all possible states, and where
 there are multiple values, the probabilities add up to 1.0.
 
 N.B. NESituation will give its confidence as 1 / accuracy_in_metres
 */
@property (nonatomic, readonly) NSArray<NEXSensorItemType> *possibilities;

/**
 A time interval in fractional seconds of the sensor's reported uptime.
 If unavailable, the time will be -Inf.
 */
@property (nonatomic, readonly) NSTimeInterval sensorUptime;

/**
 A timestamp at which the Glimpse was created.
 */
@property (nonatomic, readonly) NSDate *createdAt;

/**
 The topic string that the Glimpse was originally published on.
 */
@property (nonatomic, readonly) NSString *topicName;

@end

NS_ASSUME_NONNULL_END
