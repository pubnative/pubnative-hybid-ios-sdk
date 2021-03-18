//
//  NEXSensor.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 04/09/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "Consentable.h"

#import <Foundation/Foundation.h>

@protocol NEXBaseSensor<NSObject>
@required
@property (nonatomic, readonly) BOOL isAvailable;
@property (nonatomic, readonly) BOOL canQuery;
@property (nonatomic, readonly) BOOL canStart;

@end

NS_ASSUME_NONNULL_BEGIN
@interface NEXSensor : NSObject

@property (atomic, strong) NSUUID *sessionIdOrNil;

@property (nonatomic, strong, readonly) dispatch_queue_t messageQueue;

@property (atomic) BOOL isRunning;

@property (nonatomic, readonly, nullable) NSDate *startDate;
@property (nonatomic, readonly, nullable) NSDate *stopDate;

@property (nonatomic, readonly) NSTimeInterval uptime;

-(void)sensorDidStart; //to be overridden
-(void)sensorDidStop; //to be overridden

@end

@interface NEXSensor() <Consentable>

@end
NS_ASSUME_NONNULL_END
