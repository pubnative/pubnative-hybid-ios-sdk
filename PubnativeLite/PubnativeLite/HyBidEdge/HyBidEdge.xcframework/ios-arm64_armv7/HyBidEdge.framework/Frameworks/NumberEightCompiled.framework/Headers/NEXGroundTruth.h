//
//  NEXGroundTruth.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 12/09/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEXEngine.h"

NS_ASSUME_NONNULL_BEGIN
@interface NEXGroundTruth : NSObject

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

+(NEXGroundTruth *)groundTruthForSituation:(NESituation) situ;
+(NEXGroundTruth *)groundTruthForActivity:(NEActivity) activity;
+(NEXGroundTruth *)groundTruthForIndoorOutdoor:(NEIndoorOutdoor) indoorOutdoor;
+(NEXGroundTruth *)groundTruthForPlace:(NEPlace) place;
+(NEXGroundTruth *)groundTruthForDevicePosition:(NEDevicePosition) devicePosition;
+(NEXGroundTruth *)groundTruthForAppdelegateMessage:(NSString *)message;

@property (nonatomic, readonly) NSString *topic;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *value;

@end
NS_ASSUME_NONNULL_END
