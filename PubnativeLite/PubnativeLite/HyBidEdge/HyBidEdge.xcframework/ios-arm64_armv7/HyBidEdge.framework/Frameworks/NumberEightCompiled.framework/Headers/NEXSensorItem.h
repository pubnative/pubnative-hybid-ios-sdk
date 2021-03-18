//
//  NEXSensorItem.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 28/08/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NEXSensorItem : NSObject

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) double confidence;

// description property is garanteed to be implemented by subclasses,
// calling the related toString functions, in the related NETyoe

@end
NS_ASSUME_NONNULL_END
