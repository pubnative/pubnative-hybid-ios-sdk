//
//  LocationEncoding.h
//  HyBid
//
//  Created by Fares Ben Hamouda on 02.04.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationEncoding : NSObject

+ (CLLocation *)decodeLocation:(NSString *)enc;
+ (NSString *)encodeLocation:(CLLocation *)loc;

@end

NS_ASSUME_NONNULL_END
