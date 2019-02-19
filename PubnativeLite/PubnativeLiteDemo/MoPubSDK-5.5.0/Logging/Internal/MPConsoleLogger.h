//
//  MPConsoleLogger.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPLogger.h"

/**
 Console logging destination routes all log messages to @c NSLog.
 */
@interface MPConsoleLogger : NSObject<MPLogger>

/**
 Log level. By default, this is set to @c MPLogLevelInfo.
 */
@property (nonatomic, assign) MPLogLevel logLevel;

@end
