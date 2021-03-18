//
//  NEXGlimpseHandler.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 19/10/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEXGlimpse.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GlimpseHandler)
@interface NEXGlimpseHandler<__covariant NEXSensorItemType> : NSObject

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

-(instancetype)initWithBlock:(void(^)(NEXGlimpse<NEXSensorItemType> *))block;
+(instancetype)handlerWithBlock:(void(^)(NEXGlimpse<NEXSensorItemType> *))block;

@end

NS_ASSUME_NONNULL_END
