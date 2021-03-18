//
//  NEXSensorItem.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 28/08/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEXSensorItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface NEXSensorItem(forInternalUsage)

@property (nonatomic, readonly) NSString *underlyingNETypeName;
@property (nonatomic, readonly) void * underlyingNEValue; // abstract

-(NSString *)serialize; //abstract

@end
NS_ASSUME_NONNULL_END
