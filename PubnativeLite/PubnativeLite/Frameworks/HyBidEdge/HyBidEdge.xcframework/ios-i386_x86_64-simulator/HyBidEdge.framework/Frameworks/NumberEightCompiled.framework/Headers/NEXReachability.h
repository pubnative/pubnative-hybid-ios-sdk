//
//  NEXReachability.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 21/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSensorItem.h"

#import "NEReachability.h"

#import <Foundation/Foundation.h>

/**
 * Contains a NEReachability value which represents the reachability of the device's radios: cellular and WiFi.
 *
 * This does not guarantee that the user has network access, but rather whether
 * the device has service.
 */
NS_ASSUME_NONNULL_BEGIN
@interface NEXReachability : NEXSensorItem

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NEReachability value;

@end
NS_ASSUME_NONNULL_END
